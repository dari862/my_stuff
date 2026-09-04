#!/usr/bin/env bash
set -ueo pipefail

# --- Inputs ---
root="${1:-}"
themes_style_name="${2:-}"
output_theme_name="${3:-}"
themes_output_dir="${4:-$HOME/.themes}"
theme_file="${5:-}"

SRC_PATH="$(readlink -f "$(dirname "$0")")/${themes_style_name}"

# ---    Clean up      ---
tmp_dir="$(mktemp -d)"
post_clean_up() {
    rm -rf "${tmp_dir}"
}
trap post_clean_up EXIT

error_m() {
	message="${1-}"
	printf '%b' "\n\033[1;97;41m ERROR \033[0m \033[1;31m${message}\033[0m\n\n" >&2
}

done_m() {
	message="${1-}"
	printf '%b' "\033[1;32m✔ ${message}\033[0m\n"
}

info_m() {
	message="${1-}"
	color="38;5;51"
	printf '%b' "\033[1;${color}m:: ${message} ...\033[0m\n"
}

sub_info_m() {
	message="${1-}"
	color="38;5;75"
	printf '%b' "\033[0;${color}m ↳ ${message} ...\033[0m\n"
}

# --- Helper Functions ---
check_var() {
    if [ -z "${2:-}" ]; then
        error_m "${1} is empty"
        exit 1
    fi
}

buid_materia_theme(){
	darker_channel() {
		value="$1"
		light_delta="$2"
		value_int="$(bc <<< "ibase=16; $value")"
		result="$(bc <<< "$value_int - $light_delta")"
		if [[ "$result" -lt 0 ]]; then
			result=0
		fi
		if [[ "$result" -gt 255 ]]; then
			result=255
		fi
		echo "$result"
	}
	
	darker() {
		hexinput="$(tr '[:lower:]' '[:upper:]' <<< "$1")"
		light_delta="${2-10}"
	
		a="$(cut -c-2 <<< "$hexinput")"
		b="$(cut -c3-4 <<< "$hexinput")"
		c="$(cut -c5-6 <<< "$hexinput")"
	
		r="$(darker_channel "$a" "$light_delta")"
		g="$(darker_channel "$b" "$light_delta")"
		b="$(darker_channel "$c" "$light_delta")"
	
		printf '%02x%02x%02x\n' "$r" "$g" "$b"
	}
	
	mix_channel() {
		value1="$(printf '%03d' "0x$1")"
		value2="$(printf '%03d' "0x$2")"
		ratio="$3"
		result="$(bc <<< "scale=0; ($value1 * 100 * $ratio + $value2 * 100 * (1 - $ratio)) / 100")"
		if [[ "$result" -lt 0 ]]; then
			result=0
		elif [[ "$result" -gt 255 ]]; then
			result=255
		fi
		echo "$result"
	}
	
	mix() {
		hexinput1="$(tr '[:lower:]' '[:upper:]' <<< "$1")"
		hexinput2="$(tr '[:lower:]' '[:upper:]' <<< "$2")"
		ratio="${3-0.5}"
	
		a="$(cut -c-2 <<< "$hexinput1")"
		b="$(cut -c3-4 <<< "$hexinput1")"
		c="$(cut -c5-6 <<< "$hexinput1")"
		d="$(cut -c-2 <<< "$hexinput2")"
		e="$(cut -c3-4 <<< "$hexinput2")"
		f="$(cut -c5-6 <<< "$hexinput2")"
	
		r="$(mix_channel "$a" "$d" "$ratio")"
		g="$(mix_channel "$b" "$e" "$ratio")"
		b="$(mix_channel "$c" "$f" "$ratio")"
	
		printf '%02x%02x%02x\n' "$r" "$g" "$b"
	}
	
	is_dark() {
		hexinput="$(tr '[:lower:]' '[:upper:]' <<< "$1")"
		half_darker="$(darker "$hexinput" 88)"
		[[ "$half_darker" == "000000" ]]
	}
	
	THEME="$theme_file"
	OPTION_GTK2_HIDPI="True"
	OUTPUT_THEME_NAME="$output_theme_name"
	TARGET_DIR="$themes_output_dir"

	if [[ -z "${THEME:-}" ]]; then
		echo "THEME are empty"
		exit 1
	fi
	
	PATHLIST=(
		'./src/_theme-color.scss'
		'./src/chrome'
		'./src/cinnamon'
		'./src/cinnamon/assets'
		'./src/gnome-shell'
		'./src/gtk-2.0/assets.svg'
		'./src/gtk-2.0/assets-dark.svg'
		'./src/gtk-2.0/gtkrc'
		'./src/gtk-2.0/gtkrc-dark'
		'./src/gtk-2.0/gtkrc-light'
		'./src/gtk-3.0/assets.svg'
		'./src/metacity-1'
		'./src/unity'
		'./src/xfwm4'
	)
	if [[ -n "${CUSTOM_PATHLIST:-}" ]]; then
		IFS=', ' read -r -a PATHLIST <<< "${CUSTOM_PATHLIST:-}"
	fi
	
	EXPORT_QT5CT=0
	for FILEPATH in "${PATHLIST[@]}"; do
		if [[ "$FILEPATH" == *qt5ct* ]]; then
			EXPORT_QT5CT=1
		fi
	done
	
	OPTION_GTK2_HIDPI=$(tr '[:upper:]' '[:lower:]' <<< "${OPTION_GTK2_HIDPI-False}")
	OPTION_FORCE_INKSCAPE=$(tr '[:upper:]' '[:lower:]' <<< "${OPTION_FORCE_INKSCAPE-True}")
	
	
	if [[ "$THEME" == */* ]] || [[ "$THEME" == *.* ]]; then
		source "$THEME"
		THEME=$(basename "$THEME")
	else
		if [[ -f "$SRC_PATH/../colors/$THEME" ]]; then
			source "$SRC_PATH/../colors/$THEME"
		else
			echo "Theme '$THEME' not found"
			exit 1
		fi
	fi
	if [[ $(date +"%m%d") = "0401" ]] && grep -q "no-jokes" <<< "$*"; then
		echo -e "\\n\\nError patching uxtheme.dll\\n\\n"
		BG=C0C0C0 MATERIA_SURFACE=C0C0C0 FG=000000 MATERIA_PANEL_OPACITY=1
		HDR_BG=C0C0C0 HDR_FG=000000 SEL_BG=000080 MATERIA_VIEW=FFFFFF
	fi
	
	# Migration:
	HDR_BG=${HDR_BG-$MENU_BG}
	HDR_FG=${HDR_FG-$MENU_FG}
	MATERIA_VIEW=${MATERIA_VIEW-$TXT_BG}
	MATERIA_SURFACE=${MATERIA_SURFACE-$BTN_BG}
	GNOME_SHELL_PANEL_OPACITY=${GNOME_SHELL_PANEL_OPACITY-0.6}
	MATERIA_PANEL_OPACITY=${MATERIA_PANEL_OPACITY-$GNOME_SHELL_PANEL_OPACITY}
	
	MATERIA_STYLE_COMPACT=$(tr '[:upper:]' '[:lower:]' <<< "${MATERIA_STYLE_COMPACT-False}")
	MATERIA_COLOR_VARIANT=$(tr '[:upper:]' '[:lower:]' <<< "${MATERIA_COLOR_VARIANT:-}")
	
	SPACING=${SPACING-3}
	ROUNDNESS=${ROUNDNESS-4}
	# shellcheck disable=SC2034 # will this be used in the future?
	ROUNDNESS_GTK2_HIDPI=$(( ROUNDNESS * 2 ))
	MATERIA_PANEL_OPACITY=${MATERIA_PANEL_OPACITY-0.6}
	MATERIA_SELECTION_OPACITY=${MATERIA_SELECTION_OPACITY-0.32}
	
	INACTIVE_FG=$(mix "$FG" "$BG" 0.75)
	INACTIVE_MATERIA_VIEW=$(mix "$MATERIA_VIEW" "$BG" 0.60)
	
	TERMINAL_COLOR4=${TERMINAL_COLOR4:-1E88E5}
	TERMINAL_COLOR5=${TERMINAL_COLOR5:-E040FB}
	TERMINAL_COLOR9=${TERMINAL_COLOR9:-DD2C00}
	TERMINAL_COLOR10=${TERMINAL_COLOR10:-00C853}
	TERMINAL_COLOR11=${TERMINAL_COLOR11:-FF6D00}
	TERMINAL_COLOR12=${TERMINAL_COLOR12:-66BB6A}
	
	TARGET_DIR=${TARGET_DIR-$HOME/.themes}
	OUTPUT_THEME_NAME=${OUTPUT_THEME_NAME-oomox-$THEME}
	DEST_PATH="$TARGET_DIR"
	
	if [[ "$SRC_PATH" == "$DEST_PATH" ]]; then
		echo "can't do that"
		exit 1
	fi
	
	
	tempdir=$(mktemp -d)
	post_clean_up() {
		rm -r "$tempdir" || :
	}
	trap post_clean_up EXIT SIGHUP SIGINT SIGTERM
	echo " copy temp theme to tempdir"
	cp -r "$SRC_PATH/"* "$tempdir/"
	cd "$tempdir"
	
	# autodetection which color variant to use
	if [[ -z "$MATERIA_COLOR_VARIANT" ]]; then
		if is_dark "$BG"; then
			echo "== Dark background color detected. Setting color variant to dark."
			MATERIA_COLOR_VARIANT="dark"
		elif is_dark "$HDR_BG"; then
			echo "== Dark headerbar background color detected. Setting color variant to default."
			MATERIA_COLOR_VARIANT="default"
		else
			echo "== Light background color detected. Setting color variant to light."
			MATERIA_COLOR_VARIANT="light"
		fi
	fi
	
	
	echo "== Converting theme into template..."
	
	for FILEPATH in "${PATHLIST[@]}"; do
		if [[ "$MATERIA_COLOR_VARIANT"	!= "dark" ]]; then
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
	
	#Not implemented yet:
				#-e 's/%SPACING%/'"$SPACING"'/g' \
	
	# shellcheck disable=SC2016
	sed -i -e 's/^$corner-radius: .px/$corner-radius: '"$ROUNDNESS"'px/g' ./src/_theme.scss
	
	if [[ "${DEBUG:-}" ]]; then
		echo "You can debug TEMP DIR: $tempdir, press [Enter] when finished"; read -r
	fi
	
	mv ./src/_theme-color.template.scss ./src/_theme-color.scss
	
	echo "== Filling the template with the new colorscheme..."
	for FILEPATH in "${PATHLIST[@]}"; do
		find "$FILEPATH" -type f -exec sed -i'' \
			-e 's/%BG%/#'"$BG"'/g' \
			-e 's/%BG2%/#'"$(darker $BG)"'/g' \
			-e 's/%FG%/#'"$FG"'/g' \
			-e 's/%SEL_BG%/#'"$SEL_BG"'/g' \
			-e 's/%SEL_BG2%/#'"$(darker $SEL_BG -20)"'/g' \
			-e 's/%MATERIA_VIEW%/#'"$MATERIA_VIEW"'/g' \
			-e 's/%HDR_BG%/#'"$HDR_BG"'/g' \
			-e 's/%HDR_BG2%/#'"$(darker $HDR_BG 10)"'/g' \
			-e 's/%HDR_BG3%/#'"$(darker $HDR_BG 20)"'/g' \
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
	
	if [[ "$MATERIA_COLOR_VARIANT" == "default" ]]; then
		COLOR_VARIANT="default"
		COLOR_SUFFIX=""
	fi
	if [[ "$MATERIA_COLOR_VARIANT" == "light" ]]; then
		COLOR_VARIANT="light"
		COLOR_SUFFIX="-light"
	fi
	if [[ "$MATERIA_COLOR_VARIANT" == "dark" ]]; then
		COLOR_VARIANT="dark"
		COLOR_SUFFIX="-dark"
	fi
	if [[ "$OPTION_GTK2_HIDPI" == "true" ]]; then
		mv ./src/gtk-2.0/main.rc.hidpi ./src/gtk-2.0/main.rc
	fi
	if [[ "$EXPORT_QT5CT" = 1 ]]; then
		config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
		qt5ct_colors_dir="$config_home/qt5ct/colors/"
		test -d "$qt5ct_colors_dir" || mkdir -p "$qt5ct_colors_dir"
		mv ./src/qt5ct_palette.conf "$qt5ct_colors_dir/$OUTPUT_THEME_NAME.conf"
	fi
	
	if [[ "$MATERIA_STYLE_COMPACT" == "true" ]]; then
		SIZE_VARIANT="compact"
		SIZE_SUFFIX="-compact"
	else
		SIZE_VARIANT="default"
		SIZE_SUFFIX=""
	fi
	
	if [[ ! "$(command -v inkscape || command -v rendersvg)" ]]; then
  		echo "'inkscape' or 'resvg' needs to be installed to generate the PNG."
  		exit 1
	fi
	
	if [[ ! "$(command -v optipng)" ]]; then
  		echo "'optipng' needs to be installed to optimize the resulting PNG."
	fi
	# NOTE we use the functions we already have in render-assets.sh
	echo "== Rendering GTK 2 assets..."
	
	cd "$tempdir"/src/gtk-2.0
	if [[ "$MATERIA_COLOR_VARIANT" != "dark" ]]; then
		FORCE_INKSCAPE="$OPTION_FORCE_INKSCAPE" GTK2_HIDPI="$OPTION_GTK2_HIDPI" ./render-assets.sh light
	else
		FORCE_INKSCAPE="$OPTION_FORCE_INKSCAPE" GTK2_HIDPI="$OPTION_GTK2_HIDPI" ./render-assets.sh light
		FORCE_INKSCAPE="$OPTION_FORCE_INKSCAPE" GTK2_HIDPI="$OPTION_GTK2_HIDPI" ./render-assets.sh dark
	fi
  	
	echo "== Rendering GTK 3 assets..."
	cd "$tempdir"/src/gtk-3.0
	FORCE_INKSCAPE="$OPTION_FORCE_INKSCAPE" ./render-assets.sh gtk
	
	cd "$tempdir"
	touch "$tempdir"/INSTALL_GDM_THEME.md
	touch "$tempdir"/COPYING
	
	meson _build -Dprefix="$tempdir" -Dcolors="$COLOR_VARIANT" -Dsizes="$SIZE_VARIANT"
	meson install -C _build
	GENERATED_PATH="$tempdir/share/themes/Materia$COLOR_SUFFIX$SIZE_SUFFIX"
	if [[ -d "$DEST_PATH" ]]; then
		rm -r "$DEST_PATH"
	elif [[ ! -d "$(dirname "$DEST_PATH")" ]]; then
		mkdir -p "$(readlink -f "$(dirname "$DEST_PATH")")"
	fi
	mv "$GENERATED_PATH" "$DEST_PATH"
	
	
	echo
	echo "== SUCCESS"
	echo "== The theme was installed to '$DEST_PATH'"
	exit 0
}

buid_oomox_theme(){
	darker_channel() {
		value="$1"
		light_delta="$2"
		value_int="$(bc <<< "ibase=16; $value")"
		result="$(bc <<< "$value_int - $light_delta")"
		if [[ "$result" -lt 0 ]]; then
			result=0
		fi
		if [[ "$result" -gt 255 ]]; then
			result=255
		fi
		echo "$result"
	}
	
	darker() {
		hexinput="$(tr '[:lower:]' '[:upper:]' <<< "$1")"
		light_delta="${2-10}"
	
		a="$(cut -c-2 <<< "$hexinput")"
		b="$(cut -c3-4 <<< "$hexinput")"
		c="$(cut -c5-6 <<< "$hexinput")"
	
		r="$(darker_channel "$a" "$light_delta")"
		g="$(darker_channel "$b" "$light_delta")"
		b="$(darker_channel "$c" "$light_delta")"
	
		printf '%02x%02x%02x\n' "$r" "$g" "$b"
	}
	
	mix_channel() {
		value1="$(printf '%03d' "0x$1")"
		value2="$(printf '%03d' "0x$2")"
		ratio="$3"
		result="$(bc <<< "scale=0; ($value1 * 100 * $ratio + $value2 * 100 * (1 - $ratio)) / 100")"
		if [[ "$result" -lt 0 ]]; then
			result=0
		elif [[ "$result" -gt 255 ]]; then
			result=255
		fi
		echo "$result"
	}
	
	mix() {
		hexinput1="$(tr '[:lower:]' '[:upper:]' <<< "$1")"
		hexinput2="$(tr '[:lower:]' '[:upper:]' <<< "$2")"
		ratio="${3-0.5}"
	
		a="$(cut -c-2 <<< "$hexinput1")"
		b="$(cut -c3-4 <<< "$hexinput1")"
		c="$(cut -c5-6 <<< "$hexinput1")"
		d="$(cut -c-2 <<< "$hexinput2")"
		e="$(cut -c3-4 <<< "$hexinput2")"
		f="$(cut -c5-6 <<< "$hexinput2")"
	
		r="$(mix_channel "$a" "$d" "$ratio")"
		g="$(mix_channel "$b" "$e" "$ratio")"
		b="$(mix_channel "$c" "$f" "$ratio")"
	
		printf '%02x%02x%02x\n' "$r" "$g" "$b"
	}
	
	MAKE_OPTS="gtk320 css_cinnamon gtk3"
	OPTION_GTK2_HIDPI="True"
	DEST_PATH_ROOT="$themes_output_dir"
	
	OUTPUT_THEME_NAME="${output_theme_name}"
	THEME="${theme_file}"

	if [[ -z "${THEME:-}" ]] ; then
		echo "THEME are empty"
		exit 1
	fi
	
	PATHLIST=(
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
	if [ -n "${CUSTOM_PATHLIST:-}" ] ; then
		IFS=', ' read -r -a PATHLIST <<< "${CUSTOM_PATHLIST:-}"
	fi
	SVG_PREVIEWS=(
		'./gtk-3.0/thumbnail.svg'
		'./gtk-3.20/thumbnail.svg'
		'./metacity-1/thumbnail.svg'
	)
	
	MAKE_GTK3=0
	for FILEPATH in "${PATHLIST[@]}"; do
		if [[ ${FILEPATH} == *Makefile* ]] ;then
			MAKE_GTK3=1
		fi
	done
	MAKE_OPTS="${MAKE_OPTS-all}"
	
	OPTION_GTK2_HIDPI=$(echo "${OPTION_GTK2_HIDPI-False}" | tr '[:upper:]' '[:lower:]')
	
	
	if [[ ${THEME} == */* ]] || [[ ${THEME} == *.* ]] ; then
		source "$THEME"
		THEME=$(basename "${THEME}")
	else
		if [[ -f "$SRC_PATH/../colors/$THEME" ]] ; then
			source "$SRC_PATH/../colors/$THEME"
		else
			echo "Theme '${THEME}' not found"
			exit 1
		fi
	fi
	if [[ $(date +"%m%d") = "0401" ]] && [[ -z "${no_jokes:-}" ]] ; then
		echo -e "\n\nError patching uxtheme.dll\n\n"
		ACCENT_BG=30a55c BG=ECE9D8 BTN_BG=f8f8f8 BTN_FG=000000
		BTN_OUTLINE_OFFSET=-3 BTN_OUTLINE_WIDTH=1 FG=000000 GRADIENT=0.08
		GTK3_GENERATE_DARK=False HDR_BTN_BG=f8f8f8 HDR_BTN_FG=000000 HDR_BG=ECE9D8
		HDR_FG=000000 OUTLINE_WIDTH=1 ROUNDNESS=3 SEL_BG=3169C6 SEL_FG=FFFFFF
		SPACING=3 TXT_BG=FFFFFF TXT_FG=000000 WM_BORDER_FOCUS=3169C6 WM_BORDER_UNFOCUS=ECE9D8
	fi
	
	# Migration:
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
	
	if [ "$(echo "$GRADIENT < 2" | bc)" ]; then
		GTK2_GRAD=$(echo "scale=2; $GRADIENT/2" | bc)
	else
		GTK2_GRAD=1
	fi
	GTK2_GRAD_1=$(echo "1+$GTK2_GRAD" | bc)
	GTK2_GRAD_2=$(echo "1-$GTK2_GRAD" | bc)
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
	
	OUTPUT_THEME_NAME="${OUTPUT_THEME_NAME-oomox-$THEME}"
	
	DEST_PATH_ROOT="${DEST_PATH_ROOT-$HOME/.themes}"
	DEST_PATH="${DEST_PATH_ROOT}"
	test "$SRC_PATH" = "$DEST_PATH" && echo "can't do that" && exit 1
	
	
	rm -fr "${DEST_PATH}/"{assets,cinnamon,gtk-2.0,gtk-3.0,gtk-3.20,index.theme,metacity-1,openbox-3,unity,xfwm4}
	mkdir -p "$DEST_PATH"
	echo -e "\nBuilding theme at $DEST_PATH\n"
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
		if [[ -f ./gtk-3.0/scss/gtk-dark.scss ]] ; then
			rm ./gtk-3.0/scss/gtk-dark.scss
		fi
		if [[ -f ./gtk-3.20/scss/gtk-dark.scss ]] ; then
			rm ./gtk-3.20/scss/gtk-dark.scss
		fi
	fi
	if [[ ${OPTION_GTK2_HIDPI} == "true" ]] ; then
		mv ./gtk-2.0/gtkrc.hidpi ./gtk-2.0/gtkrc
	fi
	if [[ ${UNITY_DEFAULT_LAUNCHER_STYLE} == "true" ]] ; then
		rm ./unity/launcher*.svg
	fi
	
	if [[ ${MAKE_GTK3} = 1 ]]; then
		# shellcheck disable=SC2086
		env MAKEFLAGS= make --jobs="$(nproc)" ${MAKE_OPTS}
	fi
	
	config_home=${XDG_CONFIG_HOME:-}
	if [[ -z "${config_home}" ]] ; then
		config_home="${HOME}/.config"
	fi
	
	rm -fr ./Makefile gtk-3.*/scss
	
	for FILEPATH in "${SVG_PREVIEWS[@]}"; do
		# shellcheck disable=SC2001
		if [[ -f "$FILEPATH" ]] ; then
			rsvg-convert --format=png -o "$(sed -e 's/svg$/png/' <<< "${FILEPATH}")" "${FILEPATH}"
			rm "${FILEPATH}"
		fi
	done
	
	if [[ ${MAKE_OPTS} = "gtk320" ]]; then
		rm -fr ./gtk-3.0/
	elif [[ ${MAKE_OPTS} = "gtk3" ]]; then
		rm -fr ./gtk-3.20/
	fi
	
	exit 0
}

# --- Initialization & Validation ---
check_var "output_theme_name" "$output_theme_name"
info_m "building ${output_theme_name}"
check_var "theme_file" "$theme_file"

source "$theme_file"

# --- Theme Processing Styles ---
case "$themes_style_name" in
    materia)
    	info_m "Using $themes_style_name"
    	buid_materia_theme
        ;;
    oomox)
    	info_m "Using $themes_style_name"
    	buid_oomox_theme
        ;;
    arc)
    	info_m "Using $themes_style_name"
        ;;
esac
