#!/usr/bin/env bash
# remov bc inkscape optipng rsvg-convert sass dep
set -ueo pipefail

# --- Inputs ---
root="${1:-}"
themes_style_name="${2:-}"
output_theme_name="${3:-}"
themes_output_dir="${4:-$HOME/.themes}"
theme_file="${5:-}"

OPTION_GTK2_HIDPI="${OPTION_GTK2_HIDPI-true}"
OUTPUT_THEME_NAME="$output_theme_name"
DEST_PATH="$themes_output_dir"
SRC_PATH="$(readlink -f "$(dirname "$0")")/${themes_style_name}"

# --- Clean up ---
tmp_dir="$(mktemp -d)"
post_clean_up() {
    rm -rfd "${tmp_dir}" || :
}
trap post_clean_up EXIT SIGHUP SIGINT SIGTERM

# --- Common Logger Functions ---
error_m() {
    printf '%b' "\n\033[1;97;41m ERROR \033[0m \033[1;31m${1}\033[0m\n\n" >&2
    exit 1
}

done_m() {
    printf '%b' "\033[1;32m✔ ${1}\033[0m\n"
}

info_m() {
    printf '%b' "\033[1;38;5;51m:: ${1} ...\033[0m\n"
}

sub_info_m() {
    printf '%b' "\033[0;38;5;75m ↳ ${1} ...\033[0m\n"
}

# --- Helper Functions ---
check_var() {
    if [ -z "${2:-}" ]; then
        error_m "${1} is empty"
    fi
}

clamp()
{
    val=$1

    if [ "$val" -lt 0 ]; then
        printf '%s\n' 0
        return
    fi

    if [ "$val" -gt 255 ]; then
        printf '%s\n' 255
        return
    fi

    printf '%d\n' "$val"
}

hex_channel()
{
    printf '%d\n' "0x$1"
}

darker_channel()
{
    value=$(hex_channel "$1")
    delta=${2:-10}

    clamp $((value - delta))
}

mix_channel()
{
    value1=$(hex_channel "$1")
    value2=$(hex_channel "$2")
    ratio=${3:-0.5}

    awk -v v1="$value1" -v v2="$value2" -v r="$ratio" '
        BEGIN {
            result = v1 * r + v2 * (1 - r)

            if (result < 0) {
                result = 0
            }

            if (result > 255) {
                result = 255
            }

            printf "%d\n", result
        }
    '
}

valid_hex_color()
{
    hex=$1

    if [ "${#hex}" -ne 6 ]; then
        return 1
    fi

    case $hex in
        *[!0123456789abcdefABCDEF]*)
            return 1
            ;;
    esac

    return 0
}

darker()
{
    hex=${1#\#}
    delta=${2:-10}

    if ! valid_hex_color "$hex"; then
        printf 'darker: invalid color: %s\n' "$1" >&2
        return 2
    fi

    r=$(hex_channel "${hex%${hex#??}}")
    rest=${hex#??}

    g=$(hex_channel "${rest%${rest#??}}")
    b=$(hex_channel "${rest#??}")

    printf '%02x%02x%02x\n' \
        "$(clamp $((r - delta)))" \
        "$(clamp $((g - delta)))" \
        "$(clamp $((b - delta)))"
}

mix()
{
    hex1=${1#\#}
    hex2=${2#\#}
    ratio=${3:-0.5}

    if ! valid_hex_color "$hex1"; then
        printf 'mix: invalid first color: %s\n' "$1" >&2
        return 2
    fi

    if ! valid_hex_color "$hex2"; then
        printf 'mix: invalid second color: %s\n' "$2" >&2
        return 2
    fi

    r1=$(hex_channel "${hex1%${hex1#??}}")
    rest1=${hex1#??}
    g1=$(hex_channel "${rest1%${rest1#??}}")
    b1=$(hex_channel "${rest1#??}")

    r2=$(hex_channel "${hex2%${hex2#??}}")
    rest2=${hex2#??}
    g2=$(hex_channel "${rest2%${rest2#??}}")
    b2=$(hex_channel "${rest2#??}")

    awk \
        -v r1="$r1" \
        -v g1="$g1" \
        -v b1="$b1" \
        -v r2="$r2" \
        -v g2="$g2" \
        -v b2="$b2" \
        -v ratio="$ratio" '
        BEGIN {
            r = r1 * ratio + r2 * (1 - ratio)
            g = g1 * ratio + g2 * (1 - ratio)
            b = b1 * ratio + b2 * (1 - ratio)

            printf "%02x%02x%02x\n", r, g, b
        }
    '
}

is_dark()
{
    hex=${1#\#}

    if ! valid_hex_color "$hex"; then
        return 2
    fi

    r=$(hex_channel "${hex%${hex#??}}")
    rest=${hex#??}

    g=$(hex_channel "${rest%${rest#??}}")
    b=$(hex_channel "${rest#??}")

    if [ $((299 * r + 587 * g + 114 * b)) -lt 128000 ]; then
        return 0
    fi

    return 1
}

validate_paths() {
    if [[ "$SRC_PATH" == "$DEST_PATH" ]]; then
        error_m "can't do that (Source and Destination paths are identical)"
    fi
}

convert_2_png(){
	local src_file
	local assets_dir

	if "$inkscape" --help | grep -q -- "--export-filename"; then
		export_file_option="--export-filename"
   	elif "$inkscape" --help | grep -q -- "--export-file"; then
		export_file_option="--export-file"
    elif "$inkscape" --help | grep -q -- "--export-png"; then
		export_file_option="--export-png"
    fi

    render_svg() {
    	local id="$1"
    	local dpi="$2"
    	local output="$3"
    	local src="$4"
	
    	sub_info_m "Rendering '$output'"
	
    	"$inkscape" \
        	--export-id="$id" \
        	--export-id-only \
        	"$export_file_option=${output}.svg" \
        	"$src" >/dev/null
	}
    
    render_gtk2_asset() {
        render_svg "$i" 192 "$assets_dir/$i" "$src_file"    
    }
	
	render_gtk3_asset() {
		local i="${1:-}"
		render_svg "$i" 96 "assets/$i" "assets.svg"
	}
	local asset
	
	info_m "Rendering GTK 2 assets"
	  
    cd "$tmp_dir/src/gtk-2.0"
	src_file="assets.svg"
    assets_dir="assets"
    # Render light assets
    while IFS= read -r asset; do
        render_gtk2_asset "$asset"
    done < assets.txt

    # Render dark assets when requested
    if [[ "$MATERIA_COLOR_VARIANT" == "dark" ]]; then
    	src_file="assets-dark.svg"
        assets_dir="assets-dark"
		while IFS= read -r asset; do
        	render_gtk2_asset "$asset"
        done < assets.txt
    fi
    
    info_m "Rendering GTK 3 assets"
    cd "$tmp_dir/src/gtk-3.0"
    while IFS= read -r asset; do
        render_gtk3_asset "$asset"
    done < assets.txt
}

render_assets() {
    info_m "Rendering assets"
	PATHLIST2=("$tmp_dir/src/gtk-2.0/assets.svg" "$tmp_dir/src/gtk-2.0/assets-dark.svg" "$tmp_dir/src/gtk-3.0/assets.svg")
    info_m "Converting theme into template"
    if [[ "$MATERIA_COLOR_VARIANT" != "dark" ]]; then
    	for FILEPATH in ${PATHLIST2[@]}; do
            sed -i'' \
                -e '/color-surface/{n;s/#ffffff/%MATERIA_SURFACE%/g}' \
                -e '/color-base/{n;s/#ffffff/%MATERIA_VIEW%/g}' \
                -e 's/#8ab4f8/%SEL_BG%/g' \
                -e 's/#1967d2/%SEL_BG%/g' \
                -e 's/#000000/%FG%/g' \
                -e 's/#212121/%FG%/g' \
                -e 's/#f9f9f9/%BG%/g' \
                -e 's/#ffffff/%MATERIA_SURFACE%/g' \
                -e 's/#ffffff/%MATERIA_VIEW%/g' \
                -e 's/#424242/%HDR_BG%/g' \
                -e 's/#303030/%HDR_BG2%/g' \
                -e 's/#ffffff/%HDR_FG%/g' \
                -e 's/#c1c1c1/%INACTIVE_FG%/g' \
                -e 's/#f0f0f0/%HDR_BG%/g' \
                -e 's/#ebebeb/%HDR_BG2%/g' \
                -e 's/#1d1d1d/%HDR_FG%/g' \
                -e 's/#565656/%INACTIVE_FG%/g' \
                -e 's/Materia/%OUTPUT_THEME_NAME%/g' \
                "${FILEPATH}"
        done
    else
    	for FILEPATH in ${PATHLIST2[@]}; do
            sed -i'' \
                -e 's/#8ab4f8/%SEL_BG%/g' \
                -e 's/#ffffff/%FG%/g' \
                -e 's/#eeeeee/%FG%/g' \
                -e 's/#121212/%BG%/g' \
                -e 's/#2e2e2e/%MATERIA_SURFACE%/g' \
                -e 's/#1e1e1e/%MATERIA_VIEW%/g' \
                -e 's/#272727/%HDR_BG%/g' \
                -e 's/#1e1e1e/%HDR_BG2%/g' \
                -e 's/#e4e4e4/%HDR_FG%/g' \
                -e 's/#a7a7a7/%INACTIVE_FG%/g' \
                -e 's/Materia/%OUTPUT_THEME_NAME%/g' \
                "${FILEPATH}"
        done
    fi

    info_m "Filling the template with the new colorscheme"
    for FILEPATH in ${PATHLIST2[@]}; do
        sed -i'' \
            -e 's/%BG%/#'"$BG"'/g' \
            -e 's/%BG2%/#'"$BG2"'/g' \
            -e 's/%FG%/#'"$FG"'/g' \
            -e 's/%SEL_BG%/#'"$SEL_BG"'/g' \
            -e 's/%SEL_BG2%/#'"$SEL_BG2"'/g' \
            -e 's/%MATERIA_VIEW%/#'"$MATERIA_VIEW"'/g' \
            -e 's/%HDR_BG%/#'"$HDR_BG"'/g' \
            -e 's/%HDR_BG2%/#'"$HDR_BG2"'/g' \
            -e 's/%HDR_BG3%/#'"$HDR_BG3"'/g' \
            -e 's/%HDR_FG%/#'"$HDR_FG"'/g' \
            -e 's/%MATERIA_SURFACE%/#'"$MATERIA_SURFACE"'/g' \
            -e 's/%SPACING%/'"$SPACING"'/g' \
            -e 's/%INACTIVE_FG%/#'"$INACTIVE_FG"'/g' \
            -e 's/%INACTIVE_MATERIA_VIEW%/#'"$INACTIVE_MATERIA_VIEW"'/g' \
            -e 's/%TERMINAL_COLOR4%/#'"$TERMINAL_COLOR4"'/g' \
            -e 's/%TERMINAL_COLOR5%/#'"$TERMINAL_COLOR5"'/g' \
            -e 's/%TERMINAL_COLOR9%/#'"$TERMINAL_COLOR9"'/g' \
            -e 's/%TERMINAL_COLOR10%/#'"$TERMINAL_COLOR10"'/g' \
            -e 's/%TERMINAL_COLOR11%/#'"$TERMINAL_COLOR11"'/g' \
            -e 's/%TERMINAL_COLOR12%/#'"$TERMINAL_COLOR12"'/g' \
            -e 's/%MATERIA_SELECTION_OPACITY%/'"$MATERIA_SELECTION_OPACITY"'/g' \
            -e 's/%MATERIA_PANEL_OPACITY%/'"$MATERIA_PANEL_OPACITY"'/g' \
            -e 's/%OUTPUT_THEME_NAME%/'"$OUTPUT_THEME_NAME"'/g' \
            "${FILEPATH}"
    done
    
    convert_2_png
}

build_theme(){
	local THEME_NAME="${THEME_NAME:-Materia}"
	
	# Optional overrides:
	#   GNOME_SHELL_VERSION=46
	#   GTK4_VERSION=4.16
	local GNOME_SHELL_VERSION="${GNOME_SHELL_VERSION:-}"
	local GTK4_VERSION="${GTK4_VERSION:-}"
	
	local SRC_DIR="$tmp_dir/src"
	
	local COLOR_SUFFIX=""
	local DARK_THEME=false
	local LIGHT_TOPBAR=false
	local SIZE_SUFFIX=""
	local COMPACT=false
	local GNOME_SHELL_FULL_VERSION="3.38"
	local GNOME_MAJOR=""
	local GNOME_REST=""
	local GNOME_MINOR=""
	local GTK4_FULL_VERSION="4.0"
	local GTK4_MAJOR=""
	local GTK4_REST=""
	local GTK4_MINOR=""
	# --------------------------------------------------------------------
	# Validate options
	# --------------------------------------------------------------------
	
	case "$MATERIA_COLOR_VARIANT" in
    	default)
        	COLOR_SUFFIX=""
        	DARK_THEME=false
        	LIGHT_TOPBAR=false
        	;;
    	light)
        	COLOR_SUFFIX="-light"
        	DARK_THEME=false
        	LIGHT_TOPBAR=true
        	;;
    	dark)
        	COLOR_SUFFIX="-dark"
        	DARK_THEME=true
        	LIGHT_TOPBAR=false
        	;;
    	*)
        	error_m "ERROR: invalid color variant: $MATERIA_COLOR_VARIANT\nValid values: default, light, dark"
        	;;
	esac
	
	case "$MATERIA_STYLE_COMPACT" in
    	true)
        	SIZE_SUFFIX="-compact"
        	COMPACT=true
        	;;
    	false|"")
        	SIZE_SUFFIX=""
        	COMPACT=false
        	;;
    	*)
        	error_m "ERROR: invalid style variant: $MATERIA_STYLE_COMPACT\nValid values: true, false"
        	;;
	esac
	
	local THEME_NAME_FULL="${THEME_NAME}${COLOR_SUFFIX}${SIZE_SUFFIX}"
	local THEME_DIR="$tmp_dir/share/themes/${THEME_NAME}"
	
	# --------------------------------------------------------------------
	# Detect GNOME Shell version
	# --------------------------------------------------------------------
	
	if [[ -z "$GNOME_SHELL_VERSION" ]]; then
    	if command -v gnome-shell >/dev/null 2>&1; then
        	GNOME_SHELL_FULL_VERSION="$(
            	gnome-shell --version 2>/dev/null |
            	awk '{print $NF}'
        	)"
    	else
        	sub_info_m "gnome-shell not found; using ${GNOME_SHELL_FULL_VERSION} theme styles."
    	fi
	
    	GNOME_MAJOR="${GNOME_SHELL_FULL_VERSION%%.*}"
    	GNOME_REST="${GNOME_SHELL_FULL_VERSION#*.}"
    	GNOME_MINOR="${GNOME_REST%%.*}"
	
    	if (( GNOME_MAJOR >= 40 )); then
        	GNOME_SHELL_VERSION="$GNOME_MAJOR"
    	elif (( GNOME_MINOR % 2 == 0 )); then
        	GNOME_SHELL_VERSION="${GNOME_MAJOR}.${GNOME_MINOR}"
    	else
        	GNOME_SHELL_VERSION="${GNOME_MAJOR}.$((GNOME_MINOR + 1))"
    	fi
	fi
	
	sub_info_m "GNOME Shell version: $GNOME_SHELL_VERSION"
	
	# --------------------------------------------------------------------
	# Detect GTK 4 version
	# --------------------------------------------------------------------
	
	if [[ -z "$GTK4_VERSION" ]]; then
    	if command -v gtk4-launch >/dev/null 2>&1; then
        	GTK4_FULL_VERSION="$(
            	gtk4-launch --version 2>/dev/null |
            	awk '{print $NF}'
        	)"
    	else
        	sub_info_m "gtk4-launch not found; using 4.0 theme styles."
    	fi
	
    	GTK4_MAJOR="${GTK4_FULL_VERSION%%.*}"
    	GTK4_REST="${GTK4_FULL_VERSION#*.}"
    	GTK4_MINOR="${GTK4_REST%%.*}"
	
    	if (( GTK4_MINOR % 2 == 0 )); then
        	GTK4_VERSION="${GTK4_MAJOR}.${GTK4_MINOR}"
    	else
        	GTK4_VERSION="${GTK4_MAJOR}.$((GTK4_MINOR + 1))"
    	fi
	fi
	
	sub_info_m "GTK 4 version:       $GTK4_VERSION"
	
	# --------------------------------------------------------------------
	# Helpers
	# --------------------------------------------------------------------
	
	install_file()
	{
    	local source="$1"
    	local destination="$2"
	
    	mkdir -p "$(dirname "$destination")"
    	install -m 0644 "$source" "$destination"
	}
	
	install_dir()
	{
    	local source="$1"
    	local destination="$2"
	
    	mkdir -p "$destination"
    	cp -a "$source"/. "$destination"/
	}
	
	render_scss()
	{
    	local input="$1"
    	local output="$2"
    	local version="${3:-}"
	
    	local input_dir
    	input_dir="$(cd -- "$(dirname -- "$input")" && pwd)"
	
    	local tmp_scss
    	tmp_scss="$(mktemp --suffix=.scss)"
	
    	sed \
        	-e "s|@current_source_dir@|$input_dir|g" \
        	-e "s|@dark_theme@|$DARK_THEME|g" \
        	-e "s|@light_topbar@|$LIGHT_TOPBAR|g" \
        	-e "s|@compact@|$COMPACT|g" \
        	-e "s|@version@|$version|g" \
        	"$input" > "$tmp_scss"
	
    	mkdir -p "$(dirname "$output")"
	
    	/usr/local/bin/sass --no-source-map "$tmp_scss" "$output"
	
    	rm -f "$tmp_scss"
	}
	
	# --------------------------------------------------------------------
	# Start
	# --------------------------------------------------------------------
	
	sub_info_m "\nBuilding ${THEME_NAME} theme\n  name:       $THEME_NAME_FULL\n  color:      $MATERIA_COLOR_VARIANT\n  compact:    $COMPACT\n  destination: $THEME_DIR\n"
	
	mkdir -p "$THEME_DIR"
	
	# --------------------------------------------------------------------
	# Top-level files
	# --------------------------------------------------------------------
	# Generate index.theme
	sed \
    	-e "s|@theme_name@|$THEME_NAME_FULL|g" \
    	"$SRC_DIR/index.theme.in" \
    	> "$THEME_DIR/index.theme"
	
	# --------------------------------------------------------------------
	# Chrome
	# --------------------------------------------------------------------
	local CHROME_SCROLLBAR_SUFFIX=""
	local CHROME_DIR="$THEME_DIR/chrome"
	
	mkdir -p "$CHROME_DIR"
	
	if [[ "$MATERIA_COLOR_VARIANT" == "dark" ]]; then
    	CHROME_SCROLLBAR_SUFFIX="-dark"
	fi
	
	install_file \
    	"$SRC_DIR/chrome/chrome-scrollbar${CHROME_SCROLLBAR_SUFFIX}.crx" \
    	"$CHROME_DIR/chrome-scrollbar.crx"
	
	install_file \
    	"$SRC_DIR/chrome/chrome-theme${COLOR_SUFFIX}.crx" \
    	"$CHROME_DIR/chrome-theme.crx"
	
	# --------------------------------------------------------------------
	# Cinnamon
	# --------------------------------------------------------------------
	
	local CINNAMON_DIR="$THEME_DIR/cinnamon"
	
	install_dir \
    	"$SRC_DIR/cinnamon/assets" \
    	"$CINNAMON_DIR/assets"
	
	install_file \
    	"$SRC_DIR/cinnamon/thumbnail.png" \
    	"$CINNAMON_DIR/thumbnail.png"
	
	render_scss \
    	"$SRC_DIR/cinnamon/cinnamon.scss.in" \
    	"$CINNAMON_DIR/cinnamon.css"
	
	# --------------------------------------------------------------------
	# GNOME Shell
	# --------------------------------------------------------------------
	
	local GNOME_DIR="$THEME_DIR/gnome-shell"
	local GNOME_ASSETS="assets"
	
	if [[ "$MATERIA_COLOR_VARIANT" == "dark" ]]; then
    	GNOME_ASSETS="assets-dark"
	fi
	
	install_dir \
    	"$SRC_DIR/gnome-shell/$GNOME_ASSETS" \
    	"$GNOME_DIR/assets"
	
	install_dir \
    	"$SRC_DIR/gnome-shell/extensions" \
    	"$GNOME_DIR/extensions"
	
	install_dir \
    	"$SRC_DIR/gnome-shell/icons" \
    	"$GNOME_DIR/icons"
	
	file=""
	for file in \
    	gnome-shell-start.svg \
    	gnome-shell-theme.gresource.xml \
    	noise-texture.png \
    	pad-osd.css \
    	process-working.svg
	do
    	install_file \
        	"$SRC_DIR/gnome-shell/$file" \
        	"$GNOME_DIR/$file"
	done
	
	render_scss \
    	"$SRC_DIR/gnome-shell/gnome-shell.scss.in" \
    	"$GNOME_DIR/gnome-shell.css" \
    	"$GNOME_SHELL_VERSION"
	
	# --------------------------------------------------------------------
	# GTK 2
	# --------------------------------------------------------------------
	
	local GTK2_DIR="$THEME_DIR/gtk-2.0"
	local GTK2_ASSETS="assets"
	
	if [[ "$MATERIA_COLOR_VARIANT" == "dark" ]]; then
    	GTK2_ASSETS="assets-dark"
	fi
	
	install_dir \
    	"$SRC_DIR/gtk-2.0/$GTK2_ASSETS" \
    	"$GTK2_DIR/assets"
	
	install_file \
    	"$SRC_DIR/gtk-2.0/gtkrc${COLOR_SUFFIX}" \
    	"$GTK2_DIR/gtkrc"
	
	file=""
	for file in apps.rc hacks.rc main.rc; do
    	install_file \
        	"$SRC_DIR/gtk-2.0/$file" \
        	"$GTK2_DIR/$file"
	done
	
	# --------------------------------------------------------------------
	# GTK 3
	# --------------------------------------------------------------------
	
	local GTK3_DIR="$THEME_DIR/gtk-3.0"
	
	install_dir \
    	"$SRC_DIR/gtk-3.0/assets" \
    	"$GTK3_DIR/assets"
	
	install_dir \
    	"$SRC_DIR/gtk-3.0/icons" \
    	"$GTK3_DIR/icons"
	
	render_scss \
    	"$SRC_DIR/gtk-3.0/gtk.scss.in" \
    	"$GTK3_DIR/gtk.css"
	
	if [[ "$MATERIA_COLOR_VARIANT" != "dark" ]]; then
    	render_scss \
        	"$SRC_DIR/gtk-3.0/gtk-dark.scss.in" \
        	"$GTK3_DIR/gtk-dark.css"
	fi
	
	# --------------------------------------------------------------------
	# GTK 4
	# --------------------------------------------------------------------
	
	local GTK4_DIR="$THEME_DIR/gtk-4.0"
	
	install_dir \
    	"$SRC_DIR/gtk-3.0/assets" \
    	"$GTK4_DIR/assets"
	
	install_dir \
    	"$SRC_DIR/gtk-3.0/icons" \
    	"$GTK4_DIR/icons"
	
	render_scss \
    	"$SRC_DIR/gtk-4.0/gtk.scss.in" \
    	"$GTK4_DIR/gtk.css" \
    	"$GTK4_VERSION"
	
	if [[ "$MATERIA_COLOR_VARIANT" != "dark" ]]; then
    	render_scss \
        	"$SRC_DIR/gtk-4.0/gtk-dark.scss.in" \
        	"$GTK4_DIR/gtk-dark.css" \
        	"$GTK4_VERSION"
	fi
	
	# --------------------------------------------------------------------
	# Metacity
	# --------------------------------------------------------------------
	
	local METACITY_DIR="$THEME_DIR/metacity-1"
	
	install_dir \
    	"$SRC_DIR/metacity-1/assets" \
    	"$METACITY_DIR/assets"
	
	install_file \
    	"$SRC_DIR/metacity-1/metacity-theme-2${COLOR_SUFFIX}.xml" \
    	"$METACITY_DIR/metacity-theme-2.xml"
	
	install_file \
    	"$SRC_DIR/metacity-1/metacity-theme-3.xml" \
    	"$METACITY_DIR/metacity-theme-3.xml"
	
	# --------------------------------------------------------------------
	# Plank
	# --------------------------------------------------------------------
	
	local PLANK_DIR="$THEME_DIR/plank"
	
	install_file \
    	"$SRC_DIR/plank/dock.theme" \
    	"$PLANK_DIR/dock.theme"
	
	# --------------------------------------------------------------------
	# Unity
	# --------------------------------------------------------------------
	
	local UNITY_DIR="$THEME_DIR/unity"
	local UNITY_BUTTONS="window-buttons"
	
	if [[ "$MATERIA_COLOR_VARIANT" == "light" ]]; then
    	UNITY_BUTTONS="window-buttons-light"
	fi
	
	install_dir \
    	"$SRC_DIR/unity/$UNITY_BUTTONS" \
    	"$UNITY_DIR"
	
	install_dir \
    	"$SRC_DIR/unity/dash-buttons" \
    	"$UNITY_DIR"
	
	install_dir \
    	"$SRC_DIR/unity/launcher" \
    	"$UNITY_DIR"
	
	install_file \
    	"$SRC_DIR/unity/dash-widgets.json" \
    	"$UNITY_DIR/dash-widgets.json"
	
	# --------------------------------------------------------------------
	# XFWM4
	# --------------------------------------------------------------------
	
	local XFWM4_DIR="$THEME_DIR/xfwm4"
	
	install_dir \
    	"$SRC_DIR/xfwm4/xfwm4${COLOR_SUFFIX}" \
    	"$XFWM4_DIR"
	
	sub_info_m "\nTheme successfully built:\n  $THEME_DIR"
}

buid_materia_theme(){
    validate_paths

    inkscape="$(command -v inkscape)" || inkscape=""
    optipng="$(command -v optipng)" || optipng=""
        
    if [[ -z "$inkscape" ]]; then
		error_m "'inkscape' needs to be installed to generate the PNG."
    fi
    
    if [[ -z "$optipng" ]]; then
         sub_info_m "'optipng' is not installed; skipping PNG optimization"
    fi
      
    local -a PATHLIST=(
        './src/_theme-color.scss'
        './src/chrome'
        './src/cinnamon'
        './src/cinnamon/assets'
        './src/gnome-shell'
        './src/gtk-2.0/gtkrc'
        './src/gtk-2.0/gtkrc-dark'
        './src/gtk-2.0/gtkrc-light'
        './src/metacity-1'
        './src/unity'
        './src/xfwm4'
    )
    
    # Migration variables:
    HDR_BG=${HDR_BG-$MENU_BG}
    HDR_FG=${HDR_FG-$MENU_FG}
    MATERIA_VIEW=${MATERIA_VIEW-$TXT_BG}
    MATERIA_SURFACE=${MATERIA_SURFACE-$BTN_BG}
    GNOME_SHELL_PANEL_OPACITY=${GNOME_SHELL_PANEL_OPACITY-0.6}
    MATERIA_PANEL_OPACITY=${MATERIA_PANEL_OPACITY-$GNOME_SHELL_PANEL_OPACITY}
    
    MATERIA_STYLE_COMPACT=$(tr '[:upper:]' '[:lower:]' <<< "${MATERIA_STYLE_COMPACT-false}")
    MATERIA_COLOR_VARIANT=$(tr '[:upper:]' '[:lower:]' <<< "${MATERIA_COLOR_VARIANT:-}")
    
    SPACING=${SPACING-3}
    ROUNDNESS=${ROUNDNESS-4}
    MATERIA_SELECTION_OPACITY=${MATERIA_SELECTION_OPACITY-0.32}
    
    INACTIVE_FG=$(mix "$FG" "$BG" 0.75)
    INACTIVE_MATERIA_VIEW=$(mix "$MATERIA_VIEW" "$BG" 0.60)
    
    TERMINAL_COLOR4=${TERMINAL_COLOR4:-1E88E5}
    TERMINAL_COLOR5=${TERMINAL_COLOR5:-E040FB}
    TERMINAL_COLOR9=${TERMINAL_COLOR9:-DD2C00}
    TERMINAL_COLOR10=${TERMINAL_COLOR10:-00C853}
    TERMINAL_COLOR11=${TERMINAL_COLOR11:-FF6D00}
    TERMINAL_COLOR12=${TERMINAL_COLOR12:-66BB6A}
    
    sub_info_m "Copying temp theme to tmp_dir"
    cp -r "$SRC_PATH/"* "$tmp_dir/"
    cd "$tmp_dir"
    
    # Autodetection of color variant
    if [[ -z "$MATERIA_COLOR_VARIANT" ]]; then
        if is_dark "$BG"; then
            sub_info_m "Dark background color detected. Setting color variant to dark"
            MATERIA_COLOR_VARIANT="dark"
        elif is_dark "$HDR_BG"; then
            sub_info_m "Dark headerbar background color detected. Setting color variant to default"
            MATERIA_COLOR_VARIANT="default"
        else
            sub_info_m "Light background color detected. Setting color variant to light"
            MATERIA_COLOR_VARIANT="light"
        fi
    fi
    
    BG2="$(darker $BG)"
    SEL_BG2="$(darker "$SEL_BG" -20)"
	HDR_BG2="$(darker "$HDR_BG" 10)"
	HDR_BG3="$(darker "$HDR_BG" 20)"
	
    info_m "Converting theme into template"
    for FILEPATH in "${PATHLIST[@]}"; do
        if [[ "$MATERIA_COLOR_VARIANT" != "dark" ]]; then
            find "$FILEPATH" -type f -not -name '_color-palette.scss' -exec sed -i'' \
                -e '/color-surface/{n;s/#ffffff/%MATERIA_SURFACE%/g}' \
                -e '/color-base/{n;s/#ffffff/%MATERIA_VIEW%/g}' \
                -e 's/#8ab4f8/%SEL_BG%/g' \
                -e 's/#1967d2/%SEL_BG%/g' \
                -e 's/#000000/%FG%/g' \
                -e 's/#212121/%FG%/g' \
                -e 's/#f9f9f9/%BG%/g' \
                -e 's/#ffffff/%MATERIA_SURFACE%/g' \
                -e 's/#ffffff/%MATERIA_VIEW%/g' \
                -e 's/#424242/%HDR_BG%/g' \
                -e 's/#303030/%HDR_BG2%/g' \
                -e 's/#ffffff/%HDR_FG%/g' \
                -e 's/#c1c1c1/%INACTIVE_FG%/g' \
                -e 's/#f0f0f0/%HDR_BG%/g' \
                -e 's/#ebebeb/%HDR_BG2%/g' \
                -e 's/#1d1d1d/%HDR_FG%/g' \
                -e 's/#565656/%INACTIVE_FG%/g' \
                -e 's/Materia/%OUTPUT_THEME_NAME%/g' \
                {} \; ;
        else
            find "$FILEPATH" -type f -not -name '_color-palette.scss' -exec sed -i'' \
                -e 's/#8ab4f8/%SEL_BG%/g' \
                -e 's/#ffffff/%FG%/g' \
                -e 's/#eeeeee/%FG%/g' \
                -e 's/#121212/%BG%/g' \
                -e 's/#2e2e2e/%MATERIA_SURFACE%/g' \
                -e 's/#1e1e1e/%MATERIA_VIEW%/g' \
                -e 's/#272727/%HDR_BG%/g' \
                -e 's/#1e1e1e/%HDR_BG2%/g' \
                -e 's/#e4e4e4/%HDR_FG%/g' \
                -e 's/#a7a7a7/%INACTIVE_FG%/g' \
                -e 's/Materia/%OUTPUT_THEME_NAME%/g' \
                {} \; ;
        fi
    done
    
    sed -i -e 's/^$corner-radius: .px/$corner-radius: '"$ROUNDNESS"'px/g' ./src/_theme.scss
    
    if [[ "${DEBUG:-}" ]]; then
        sub_info_m "You can debug TEMP DIR: $tmp_dir, press [Enter] when finished"
        read -r
    fi
    
    mv ./src/_theme-color.template.scss ./src/_theme-color.scss
    
    info_m "Filling the template with the new colorscheme"
    for FILEPATH in "${PATHLIST[@]}"; do
        find "$FILEPATH" -type f -exec sed -i'' \
            -e 's/%BG%/#'"$BG"'/g' \
            -e 's/%BG2%/#'"$BG2"'/g' \
            -e 's/%FG%/#'"$FG"'/g' \
            -e 's/%SEL_BG%/#'"$SEL_BG"'/g' \
            -e 's/%SEL_BG2%/#'"$SEL_BG2"'/g' \
            -e 's/%MATERIA_VIEW%/#'"$MATERIA_VIEW"'/g' \
            -e 's/%HDR_BG%/#'"$HDR_BG"'/g' \
            -e 's/%HDR_BG2%/#'"$HDR_BG2"'/g' \
            -e 's/%HDR_BG3%/#'"$HDR_BG3"'/g' \
            -e 's/%HDR_FG%/#'"$HDR_FG"'/g' \
            -e 's/%MATERIA_SURFACE%/#'"$MATERIA_SURFACE"'/g' \
            -e 's/%SPACING%/'"$SPACING"'/g' \
            -e 's/%INACTIVE_FG%/#'"$INACTIVE_FG"'/g' \
            -e 's/%INACTIVE_MATERIA_VIEW%/#'"$INACTIVE_MATERIA_VIEW"'/g' \
            -e 's/%TERMINAL_COLOR4%/#'"$TERMINAL_COLOR4"'/g' \
            -e 's/%TERMINAL_COLOR5%/#'"$TERMINAL_COLOR5"'/g' \
            -e 's/%TERMINAL_COLOR9%/#'"$TERMINAL_COLOR9"'/g' \
            -e 's/%TERMINAL_COLOR10%/#'"$TERMINAL_COLOR10"'/g' \
            -e 's/%TERMINAL_COLOR11%/#'"$TERMINAL_COLOR11"'/g' \
            -e 's/%TERMINAL_COLOR12%/#'"$TERMINAL_COLOR12"'/g' \
            -e 's/%MATERIA_SELECTION_OPACITY%/'"$MATERIA_SELECTION_OPACITY"'/g' \
            -e 's/%MATERIA_PANEL_OPACITY%/'"$MATERIA_PANEL_OPACITY"'/g' \
            -e 's/%OUTPUT_THEME_NAME%/'"$OUTPUT_THEME_NAME"'/g' \
            {} \; ;
    done
    
    if [[ "$OPTION_GTK2_HIDPI" == "true" ]]; then
        mv ./src/gtk-2.0/main.rc.hidpi ./src/gtk-2.0/main.rc
    fi

    render_assets    
    #build_theme
    
    local GENERATED_PATH="$tmp_dir/src"
    if [[ -d "$DEST_PATH" ]]; then
        rm -r "$DEST_PATH"
    elif [[ ! -d "$(dirname "$DEST_PATH")" ]]; then
        mkdir -p "$(readlink -f "$(dirname "$DEST_PATH")")"
    fi
    mv "$GENERATED_PATH" "$DEST_PATH"
    
    done_m "The theme was successfully installed to '$DEST_PATH'"
    exit 0
}

buid_oomox_theme(){
    validate_paths

    local -a PATHLIST=(
        './src/openbox-3'
        './src/assets'
        './src/gtk-2.0'
        './src/gtk-3.0'
        './src/gtk-3.20'
        './src/xfwm4'
        './src/metacity-1'
        './src/unity'
        'Makefile'
        './src/index.theme'
        './src/cinnamon'
    )
    
    local -a SVG_PREVIEWS=(
        './gtk-3.0/thumbnail.svg'
        './gtk-3.20/thumbnail.svg'
        './metacity-1/thumbnail.svg'
    )
    
    HDR_BG=${HDR_BG-$MENU_BG}
    HDR_FG=${HDR_FG-$MENU_FG}
    ACCENT_BG=${ACCENT_BG-$SEL_BG}
    HDR_BTN_BG=${HDR_BTN_BG-$BTN_BG}
    HDR_BTN_FG=${HDR_BTN_FG-$BTN_FG}
    WM_BORDER_FOCUS=${WM_BORDER_FOCUS-$SEL_BG}
    WM_BORDER_UNFOCUS=${WM_BORDER_UNFOCUS-$HDR_BG}
    
    GTK3_GENERATE_DARK=$(echo "${GTK3_GENERATE_DARK-True}" | tr '[:upper:]' '[:lower:]')
    UNITY_DEFAULT_LAUNCHER_STYLE=$(echo "${UNITY_DEFAULT_LAUNCHER_STYLE-False}" | tr '[:upper:]' '[:lower:]')
    
    SPACING=${SPACING-3}
    GRADIENT=${GRADIENT-0}
    ROUNDNESS=${ROUNDNESS-2}
    CINNAMON_OPACITY=${CINNAMON_OPACITY-1}
    ROUNDNESS_GTK2_HIDPI=$(( ROUNDNESS * 2 ))
    
    local GTK2_GRAD
    if [ "$(echo "$GRADIENT < 2" | bc)" ]; then
        GTK2_GRAD=$(echo "scale=2; $GRADIENT/2" | bc)
    else
        GTK2_GRAD=1
    fi
    local GTK2_GRAD_1 GTK2_GRAD_2
    GTK2_GRAD_1=$(echo "1+$GTK2_GRAD" | bc)
    GTK2_GRAD_2=$(echo "1-$GTK2_GRAD" | bc)
    
    local GTK2_GRAD_TOP GTK2_GRAD_BOTTOM
    if expr "$GTK2_GRAD_1" : '-\?[0-9]\+$' >/dev/null; then
        GTK2_GRAD_TOP="$GTK2_GRAD_1".0
        GTK2_GRAD_BOTTOM="$GTK2_GRAD_2".0
    else
        GTK2_GRAD_TOP=$GTK2_GRAD_1
        GTK2_GRAD_BOTTOM=$GTK2_GRAD_2
    fi
    
    OUTLINE_WIDTH=${OUTLINE_WIDTH-1}
    BTN_OUTLINE_WIDTH=${BTN_OUTLINE_WIDTH-1}
    BTN_OUTLINE_OFFSET=${BTN_OUTLINE_OFFSET--3}
    
    INACTIVE_FG=$(mix "$FG" "$BG" 0.75)
    INACTIVE_HDR_FG=$(mix "$HDR_FG" "$HDR_BG" 0.75)
    INACTIVE_TXT_FG=$(mix "$TXT_FG" "$TXT_BG" 0.75)
    
    local light_folder_base_fallback medium_base_fallback dark_stroke_fallback
    light_folder_base_fallback="$(darker "$SEL_BG" -10)"
    medium_base_fallback="$(darker "$SEL_BG" 37)"
    dark_stroke_fallback="$(darker "$SEL_BG" 50)"
    
    ICONS_LIGHT_FOLDER="${ICONS_LIGHT_FOLDER-$light_folder_base_fallback}"
    ICONS_LIGHT="${ICONS_LIGHT-$SEL_BG}"
    ICONS_MEDIUM="${ICONS_MEDIUM-$medium_base_fallback}"
    ICONS_DARK="${ICONS_DARK-$dark_stroke_fallback}"
    
    CARET1_FG="${CARET1_FG-$TXT_FG}"
    CARET2_FG="${CARET2_FG-$TXT_FG}"
    CARET_SIZE="${CARET_SIZE-0.04}"
    
    TERMINAL_BACKGROUND=${TERMINAL_BACKGROUND:-$SEL_FG}
    TERMINAL_COLOR4=${TERMINAL_COLOR4:-3f51b5}
    TERMINAL_COLOR9=${TERMINAL_COLOR9:-f44336}
    TERMINAL_COLOR10=${TERMINAL_COLOR10:-4caf50}
    TERMINAL_COLOR11=${TERMINAL_COLOR11:-ef6c00}
    TERMINAL_COLOR12=${TERMINAL_COLOR12:-03a9f4}
        
    rm -fr "${DEST_PATH}/"{assets,cinnamon,gtk-2.0,gtk-3.0,gtk-3.20,index.theme,metacity-1,openbox-3,unity,xfwm4}
    mkdir -p "$DEST_PATH"
    sub_info_m "Building theme at $DEST_PATH"
    cp -r "$SRC_PATH/src/index.theme" "$DEST_PATH"
    for FILEPATH in "${PATHLIST[@]}"; do
        cp -r "$SRC_PATH/$FILEPATH" "$DEST_PATH"
    done
    
    cd "$DEST_PATH"
    for FILEPATH in "${PATHLIST[@]}"; do
        find "$(echo "${FILEPATH}" | sed -e 's/src\///g' )" -type f -exec sed -i'' \
            -e 's/%BG%/'"$BG"'/g' \
            -e 's/%FG%/'"$FG"'/g' \
            -e 's/%SEL_BG%/'"$SEL_BG"'/g' \
            -e 's/%SEL_FG%/'"$SEL_FG"'/g' \
            -e 's/%ACCENT_BG%/'"$ACCENT_BG"'/g' \
            -e 's/%TXT_BG%/'"$TXT_BG"'/g' \
            -e 's/%TXT_FG%/'"$TXT_FG"'/g' \
            -e 's/%HDR_BG%/'"$HDR_BG"'/g' \
            -e 's/%HDR_FG%/'"$HDR_FG"'/g' \
            -e 's/%BTN_BG%/'"$BTN_BG"'/g' \
            -e 's/%BTN_FG%/'"$BTN_FG"'/g' \
            -e 's/%HDR_BTN_BG%/'"$HDR_BTN_BG"'/g' \
            -e 's/%HDR_BTN_FG%/'"$HDR_BTN_FG"'/g' \
            -e 's/%WM_BORDER_FOCUS%/'"$WM_BORDER_FOCUS"'/g' \
            -e 's/%WM_BORDER_UNFOCUS%/'"$WM_BORDER_UNFOCUS"'/g' \
            -e 's/%ROUNDNESS%/'"$ROUNDNESS"'/g' \
            -e 's/%ROUNDNESS_GTK2_HIDPI%/'"$ROUNDNESS_GTK2_HIDPI"'/g' \
            -e 's/%OUTLINE_WIDTH%/'"$OUTLINE_WIDTH"'/g' \
            -e 's/%BTN_OUTLINE_WIDTH%/'"$BTN_OUTLINE_WIDTH"'/g' \
            -e 's/%BTN_OUTLINE_OFFSET%/'"$BTN_OUTLINE_OFFSET"'/g' \
            -e 's/%SPACING%/'"$SPACING"'/g' \
            -e 's/%GRADIENT%/'"$GRADIENT"'/g' \
            -e 's/%GTK2_GRAD_TOP%/'"$GTK2_GRAD_TOP"'/g' \
            -e 's/%GTK2_GRAD_BOTTOM%/'"$GTK2_GRAD_BOTTOM"'/g' \
            -e 's/%CINNAMON_OPACITY%/'"$CINNAMON_OPACITY"'/g' \
            -e 's/%INACTIVE_FG%/'"$INACTIVE_FG"'/g' \
            -e 's/%INACTIVE_TXT_FG%/'"$INACTIVE_TXT_FG"'/g' \
            -e 's/%INACTIVE_HDR_FG%/'"$INACTIVE_HDR_FG"'/g' \
            -e 's/%ICONS_DARK%/'"$ICONS_DARK"'/g' \
            -e 's/%ICONS_MEDIUM%/'"$ICONS_MEDIUM"'/g' \
            -e 's/%ICONS_LIGHT%/'"$ICONS_LIGHT"'/g' \
            -e 's/%ICONS_LIGHT_FOLDER%/'"$ICONS_LIGHT_FOLDER"'/g' \
            -e 's/%OUTPUT_THEME_NAME%/'"$OUTPUT_THEME_NAME"'/g' \
            -e 's/%CARET1_FG%/'"$CARET1_FG"'/g' \
            -e 's/%CARET2_FG%/'"$CARET2_FG"'/g' \
            -e 's/%CARET_SIZE%/'"$CARET_SIZE"'/g' \
            -e 's/%TERMINAL_BACKGROUND%/'"$TERMINAL_BACKGROUND"'/g' \
            -e 's/%TERMINAL_COLOR4%/'"$TERMINAL_COLOR4"'/g' \
            -e 's/%TERMINAL_COLOR9%/'"$TERMINAL_COLOR9"'/g' \
            -e 's/%TERMINAL_COLOR10%/'"$TERMINAL_COLOR10"'/g' \
            -e 's/%TERMINAL_COLOR11%/'"$TERMINAL_COLOR11"'/g' \
            -e 's/%TERMINAL_COLOR12%/'"$TERMINAL_COLOR12"'/g' \
            {} \; ;
    done
    
    if [[ ${GTK3_GENERATE_DARK} != "true" ]] ; then
        [[ -f ./gtk-3.0/scss/gtk-dark.scss ]] && rm ./gtk-3.0/scss/gtk-dark.scss
        [[ -f ./gtk-3.20/scss/gtk-dark.scss ]] && rm ./gtk-3.20/scss/gtk-dark.scss
    fi
    if [[ ${OPTION_GTK2_HIDPI} == "true" ]] ; then
        mv ./gtk-2.0/gtkrc.hidpi ./gtk-2.0/gtkrc
    fi
    if [[ ${UNITY_DEFAULT_LAUNCHER_STYLE} == "true" ]] ; then
        rm ./unity/launcher*.svg
    fi
    
    env MAKEFLAGS= make --jobs="$(nproc)" gtk320 css_cinnamon gtk3
    rm -fr ./Makefile gtk-3.*/scss
    
	for FILEPATH in "${SVG_PREVIEWS[@]}"; do
		if [[ -f "$FILEPATH" ]]; then
			#magick "$FILEPATH" "${FILEPATH%.svg}.png"
			rsvg-convert --format=png -o "$(sed -e 's/svg$/png/' <<< "${FILEPATH}")" "${FILEPATH}"
			rm "$FILEPATH"
		fi
	done
    
    done_m "Oomox theme built successfully"
    exit 0
}

# --- Initialization & Validation ---
check_var "output_theme_name" "$output_theme_name"
check_var "theme_file" "$theme_file"

info_m "building ${output_theme_name}"
source "$theme_file"

# --- Theme Processing Styles ---
info_m "Using $themes_style_name"
case "$themes_style_name" in
    materia)
        buid_materia_theme
        ;;
    oomox)
        buid_oomox_theme
        ;;
    arc)
        # No builder defined yet
        ;;
    *)
        error_m "Unknown theme style: $themes_style_name"
        ;;
esac
