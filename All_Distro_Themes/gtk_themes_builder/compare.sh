#!/usr/bin/env bash

set -uo pipefail

# =============================================================================
# Configuration
# =============================================================================


GEN_DIR="${GEN_DIR:-generated_themes}"
ORG_DIR="${ORG_DIR:-org_generated_themes}"

if diff -rq "${GEN_DIR}"/ "${ORG_DIR}"/ | grep -vE "\.png|\.svg|: COPYING$|: INSTALL_GDM_THEME.md$";then
	diff_files=true
else
	diff_files=false
fi

if [ "$diff_files" = false ];then
	diff_files_msg="no files diffrence excludeing PNG"
	command_2_run=""
else
	diff_files_msg="there are files diffrence"
	command_2_run="run below command to show diffrent files: \n\t diff -rq \"${GEN_DIR}\"/ \"${ORG_DIR}\"/ | grep -vE \"\\.png|\\.svg|: COPYING\$|: INSTALL_GDM_THEME.md\$\""
fi

echo "$diff_files_msg"

echo "Checking PNGs."

# Percentage of differing pixels allowed before an image is considered failed.
#THRESHOLD=7
THRESHOLD=0

#DIMENSION_TOLERANCE=1
# Maximum allowed dimension difference.
# Example:
#   1624x1889 vs 1624x1888 -> allowed
#   1624x1888 vs 1623x1888 -> allowed
#   1624x1890 vs 1624x1888 -> NOT allowed
DIMENSION_TOLERANCE=0


# =============================================================================
# Check ImageMagick
# =============================================================================

if command -v magick >/dev/null 2>&1; then
    COMPARE_CMD=(magick compare)
    IDENTIFY_CMD=(magick identify)
    CONVERT_CMD=(magick)
elif command -v compare >/dev/null 2>&1 && \
     command -v identify >/dev/null 2>&1 && \
     command -v convert >/dev/null 2>&1; then

    COMPARE_CMD=(compare)
    IDENTIFY_CMD=(identify)
    CONVERT_CMD=(convert)
else
    echo "Error: ImageMagick is required."
    echo "Install it with:"
    echo "  sudo apt install imagemagick"
    exit 1
fi


# =============================================================================
# Validate configuration
# =============================================================================

if [[ ! "$THRESHOLD" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Error: THRESHOLD must be a number."
    exit 1
fi

if [[ ! -d "$GEN_DIR" ]]; then
    echo "Error: Generated directory does not exist: $GEN_DIR"
    exit 1
fi

if [[ ! -d "$ORG_DIR" ]]; then
    echo "Error: Original directory does not exist: $ORG_DIR"
    exit 1
fi


# =============================================================================
# Counters
# =============================================================================

total_files=0
passed_files=0
failed_files=0
missing_files=0
invalid_files=0
dimension_tolerated=0


# =============================================================================
# Process PNG files
# =============================================================================

while IFS= read -r -d '' gen_file; do

    ((total_files++))

    # -------------------------------------------------------------------------
    # Get relative path
    # -------------------------------------------------------------------------

    rel_path="${gen_file#"$GEN_DIR"/}"
    org_file="$ORG_DIR/$rel_path"


    # -------------------------------------------------------------------------
    # Check original exists
    # -------------------------------------------------------------------------

    if [[ ! -f "$org_file" ]]; then
        echo "Missing original: $rel_path"
        ((missing_files++))
        continue
    fi


    # -------------------------------------------------------------------------
    # Get generated image dimensions
    # -------------------------------------------------------------------------

    gen_dimensions=$(
        "${IDENTIFY_CMD[@]}" \
            -format '%wx%h' \
            "$gen_file" 2>/dev/null
    )

    if [[ ! "$gen_dimensions" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        echo "Could not determine dimensions: $rel_path"
        ((invalid_files++))
        continue
    fi

    gen_width="${BASH_REMATCH[1]}"
    gen_height="${BASH_REMATCH[2]}"


    # -------------------------------------------------------------------------
    # Get original image dimensions
    # -------------------------------------------------------------------------

    org_dimensions=$(
        "${IDENTIFY_CMD[@]}" \
            -format '%wx%h' \
            "$org_file" 2>/dev/null
    )

    if [[ ! "$org_dimensions" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        echo "Could not determine original dimensions: $rel_path"
        ((invalid_files++))
        continue
    fi

    org_width="${BASH_REMATCH[1]}"
    org_height="${BASH_REMATCH[2]}"


    # -------------------------------------------------------------------------
    # Calculate dimension differences
    # -------------------------------------------------------------------------

    width_diff=$((gen_width - org_width))
    height_diff=$((gen_height - org_height))

    # Absolute values
    (( width_diff < 0 )) && width_diff=$((-width_diff))
    (( height_diff < 0 )) && height_diff=$((-height_diff))


    # -------------------------------------------------------------------------
    # Reject if dimensions differ by more than tolerance
    # -------------------------------------------------------------------------

    if (( width_diff > DIMENSION_TOLERANCE ||
          height_diff > DIMENSION_TOLERANCE )); then

        echo "Dimension mismatch: $rel_path | generated=${gen_dimensions} | original=${org_dimensions}"

        ((invalid_files++))
        continue
    fi


    # -------------------------------------------------------------------------
    # Determine comparison dimensions
    #
    # If:
    #   generated = 1624x1889
    #   original  = 1624x1888
    #
    # Compare:
    #   1624x1888
    #
    # The extra 1-pixel row is ignored.
    # -------------------------------------------------------------------------

    compare_width=$gen_width
    compare_height=$gen_height

    if (( org_width < compare_width )); then
        compare_width=$org_width
    fi

    if (( org_height < compare_height )); then
        compare_height=$org_height
    fi


    # -------------------------------------------------------------------------
    # Check whether dimensions had to be tolerated
    # -------------------------------------------------------------------------

    if (( width_diff > 0 || height_diff > 0 )); then
        ((dimension_tolerated++))

        echo "Dimension tolerance: $rel_path | generated=${gen_dimensions} | original=${org_dimensions} | comparing=${compare_width}x${compare_height}"
    fi


    # -------------------------------------------------------------------------
    # Create temporary cropped images only when necessary
    # -------------------------------------------------------------------------

    temp_gen=""
    temp_org=""

    cleanup() {
        [[ -n "$temp_gen" && -f "$temp_gen" ]] && rm -f "$temp_gen"
        [[ -n "$temp_org" && -f "$temp_org" ]] && rm -f "$temp_org"
    }

    trap cleanup EXIT


    if (( gen_width != compare_width || gen_height != compare_height )); then

        temp_gen=$(mktemp --suffix=".png")
        temp_org=$(mktemp --suffix=".png")

        # Crop generated image to common dimensions
        if ! "${CONVERT_CMD[@]}" \
            "$gen_file" \
            -crop "${compare_width}x${compare_height}+0+0" \
            +repage \
            "$temp_gen" 2>/dev/null; then

            echo "Failed to crop generated image: $rel_path"
            cleanup
            trap - EXIT
            ((invalid_files++))
            continue
        fi

        # Crop original image to common dimensions
        if ! "${CONVERT_CMD[@]}" \
            "$org_file" \
            -crop "${compare_width}x${compare_height}+0+0" \
            +repage \
            "$temp_org" 2>/dev/null; then

            echo "Failed to crop original image: $rel_path"
            cleanup
            trap - EXIT
            ((invalid_files++))
            continue
        fi

        compare_gen="$temp_gen"
        compare_org="$temp_org"

    else
        compare_gen="$gen_file"
        compare_org="$org_file"
    fi


    # -------------------------------------------------------------------------
    # Calculate total pixels
    # -------------------------------------------------------------------------

    total_pixels=$((compare_width * compare_height))

    if (( total_pixels <= 0 )); then
        echo "Invalid image dimensions: $rel_path"
        cleanup
        trap - EXIT
        ((invalid_files++))
        continue
    fi


    # -------------------------------------------------------------------------
    # Compare images
    #
    # AE = Absolute Error.
    #
    # The number returned represents the number of pixels that differ.
    # -------------------------------------------------------------------------

    diff_pixels=$(
        "${COMPARE_CMD[@]}" \
            -metric AE \
            "$compare_gen" \
            "$compare_org" \
            null: 2>&1
    )

    # ImageMagick returns exit code 1 when differences are detected,
    # so we intentionally don't check the command's exit status here.


    # -------------------------------------------------------------------------
    # Extract numeric result
    #
    # Depending on ImageMagick version/output, we may get:
    #
    #   123
    #
    # or:
    #
    #   123 (some additional information)
    # -------------------------------------------------------------------------

    diff_pixels="${diff_pixels%%[^0-9]*}"


    # -------------------------------------------------------------------------
    # Validate comparison result
    # -------------------------------------------------------------------------

    if [[ ! "$diff_pixels" =~ ^[0-9]+$ ]]; then
        echo "Invalid comparison output: $rel_path"
        cleanup
        trap - EXIT
        ((invalid_files++))
        continue
    fi


    # -------------------------------------------------------------------------
    # No differences
    # -------------------------------------------------------------------------

    if (( diff_pixels == 0 )); then

        ((passed_files++))

        cleanup
        trap - EXIT

        continue
    fi


    # -------------------------------------------------------------------------
    # Calculate percentage
    # -------------------------------------------------------------------------

    percentage=$(
        awk \
            -v diff="$diff_pixels" \
            -v total="$total_pixels" \
            'BEGIN {
                printf "%.4f", (diff / total) * 100
            }'
    )


    # -------------------------------------------------------------------------
    # Compare against threshold
    # -------------------------------------------------------------------------

    is_above_threshold=$(
        awk \
            -v percentage="$percentage" \
            -v threshold="$THRESHOLD" \
            'BEGIN {
                print (percentage > threshold) ? 1 : 0
            }'
    )


    # -------------------------------------------------------------------------
    # Report result
    # -------------------------------------------------------------------------

    if (( is_above_threshold == 1 )); then

        echo "FAIL: $rel_path | Mismatched pixels: $diff_pixels / $total_pixels | Difference: ${percentage}%"

        ((failed_files++))

    else

        ((passed_files++))

    fi


    # -------------------------------------------------------------------------
    # Cleanup temporary files
    # -------------------------------------------------------------------------

    cleanup
    trap - EXIT

done < <(
    find "$GEN_DIR" \
        -type f \
        -iname '*.png' \
        -print0
)


# =============================================================================
# Summary
# =============================================================================

echo
echo "============================================================"
echo "Image comparison summary"
echo "============================================================"
echo "Generated files       : $total_files"
echo "Passed                : $passed_files"
echo "Failed                : $failed_files"
echo "Missing originals     : $missing_files"
echo "Invalid images        : $invalid_files"
echo "Dimension tolerated   : $dimension_tolerated"
echo "Pixel threshold       : ${THRESHOLD}%"
echo "Dimension tolerance   : ${DIMENSION_TOLERANCE} pixel"
echo "Other files           : ${diff_files_msg}"
echo "============================================================"
echo "$command_2_run"

# =============================================================================
# Exit status
# =============================================================================
#
# Return 1 if any image exceeds the pixel-difference threshold.
# This makes the script useful in CI/CD pipelines.
# =============================================================================

if (( failed_files > 0 )); then
    exit 1
fi

exit 0
