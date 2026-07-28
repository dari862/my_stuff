#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status, 
set -eo pipefail

############################### Configuration ##################################
SIZES=("16x16" "22x22" "24x24" "32x32")
LINKS_FILE="links"

tmp_dir="${1:-}"
OUTPUT_THEME_NAME="${2:-}"
ICONS_LIGHT_FOLDER="${3:-}"
ICONS_LIGHT="${4:-}"
ICONS_MEDIUM="${5:-}"
ICONS_DARK="${6:-}"
default_sed="s/\#8fb3d9/#${ICONS_LIGHT_FOLDER}/g;s/\#729fcf/#${ICONS_LIGHT}/g;s/\#3465a4/#${ICONS_MEDIUM}/g;s/\#204a87/#${ICONS_DARK}/g"
############################# Helper Functions #################################

# Handles the PNG rendering logic with fallback pipelines
render_png() {
    local src_svg="$1"
    local dest_png="$2"

    mkdir -p "$(dirname "$dest_png")"
	sed "$default_sed" "$src_svg" | magick svg:- -format png "$(pwd)/$dest_png"
}

# Handles the basic SVG color substitution and creation
render_svg() {
    local src_svg="$1"
    local dest_svg="$2"

    mkdir -p "$(dirname "$dest_svg")"
    sed "$default_sed" "$src_svg" > "$dest_svg"
}

link_template() {
    local outdir="$1"
    local src="$2"
    local dst="$3"

    local target="$outdir/$dst"
    local dir
    dir=$(dirname "$target")

    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo "mkdir -p $dir"
    fi

    ln -sf "$src" "$target"
}

################################ Find Files ####################################

# Gather static target asset lists up front (replaces $(shell find ...))
FIXED_FILES=()
while IFS= read -r line; do FIXED_FILES+=("$line"); done < <(find src/*x* ! -wholename '*/.*' -type f -name '*.svg' 2>/dev/null)

SCALABLE_FILES=()
while IFS= read -r line; do SCALABLE_FILES+=("$line"); done < <(find src/scalable ! -wholename '*/.*' -type f -name '*.svg' 2>/dev/null)

LINK_LIST=()
while IFS= read -r line; do LINK_LIST+=("${line/ /-->}");done < "$LINKS_FILE"

ICON_FILES=()
while IFS= read -r line; do ICON_FILES+=("$line"); done < <(find src ! -wholename '*/.*' -type f -name '*.icon' 2>/dev/null)

################################ Core Logic ####################################

build_all() {
    
        echo "Building theme: ${OUTPUT_THEME_NAME}..."
	
        # 1. Index Creation (theme_template)
        mkdir -p "${OUTPUT_THEME_NAME}"
        
        if [ -f "src/index.theme" ]; then
            sed "s/@NAME@/${OUTPUT_THEME_NAME}/" src/index.theme > "${OUTPUT_THEME_NAME}/index.theme"
        fi

        # 4. Evaluate Baseline Configurations (Non-alternative iterations)
        # Process Fixed defaults
        for src_path in "${FIXED_FILES[@]}"; do
            local rel_path="${src_path#src/}"
            local rel_path_no_ext="${rel_path%.svg}"
             
            local dest_file="${OUTPUT_THEME_NAME}/${rel_path_no_ext}.png"
            render_png "$src_path" "$dest_file"
        done

        # Process Scalable defaults
        for src_path in "${SCALABLE_FILES[@]}"; do
            local rel_path="${src_path#src/}"
            local rel_path_no_ext="${rel_path%.svg}"

            local dest_file="${OUTPUT_THEME_NAME}/${rel_path}"
            render_svg "$src_path" "$dest_file"
        done

        # 4. Up-scale 22x22 sizes to 24x24 (24_template)
        for src_path in "${SCALABLE_FILES[@]}"; do
            local rel_path="${src_path#src/scalable/}"
            local rel_path_png="${rel_path%.svg}.png"

            local src_22="${OUTPUT_THEME_NAME}/22x22/${rel_path_png}"
            local dest_24="${OUTPUT_THEME_NAME}/24x24/${rel_path_png}"

            if [ -f "$src_22" ]; then
                mkdir -p "$(dirname "$dest_24")"
                convert -bordercolor Transparent -border 1x1 "$src_22" "$dest_24" || true
            fi
        done

		 # 4. create link Files (icon_template)
		for link in "${LINK_LIST[@]}"; do
    		local first=$(printf '%s\n' "${link%%-->*}")
    		local last=$(printf '%s\n' "${link##*-->}")
    		local file_ext=$(printf '%s\n' "${last##*.}")
			for size in "${SIZES[@]}"; do
        		link_template "$OUTPUT_THEME_NAME/${size}" "${first}" "${last}"
    		done
    		if [ "$last" = "$file_ext" ] || [ "$file_ext" = "xpm" ];then
    			first="${first%.*}.svg"
    			link_template "$OUTPUT_THEME_NAME/scalable" "${first}" "${last}"
    		elif [ "$file_ext" = "png" ];then
    			first=$(printf '%s.svg\n' "${first%%.png*}")
    			last="${last%.*}.svg"
    			link_template "$OUTPUT_THEME_NAME/scalable" "${first}" "${last}"
    		else
    			link_template "$OUTPUT_THEME_NAME/scalable" "${first}" "${last}"
    		fi
		done
		
        # 6. Copy Icon Configuration Files (icon_template)
        for src_icon in "${ICON_FILES[@]}"; do
            local rel_icon="${src_icon#src/}"
            local dest_icon="${OUTPUT_THEME_NAME}/${rel_icon}"
            mkdir -p "$(dirname "$dest_icon")"
            cp "$src_icon" "$dest_icon"
        done

    echo "Build complete."
}

build_all
