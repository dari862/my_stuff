#!/usr/bin/env bash
set -ueo pipefail

# --- Setup & Cleanup ---
root="$(readlink -f "$(dirname "$0")")"
tmp_dir="$(mktemp -d)"

post_clean_up() {
    rm -rf "${tmp_dir}"
}
trap post_clean_up EXIT SIGHUP SIGINT SIGTERM

# --- Inputs ---
icons_style_name="${1:-}"
OUTPUT_THEME_NAME="${2:-}"
output_dir="${3:-$HOME/.icons/$OUTPUT_THEME_NAME}"
THEME="${4:-}"

# --- Helper Functions ---
check_var() {
    if [ -z "${2:-}" ]; then
        echo "Error: ${1} is empty" >&2
        exit 1
    fi
}

copying_theme_template() {
    echo ":: Copying ${1} theme template..."
    cp -R "$root"/${1} "$tmp_dir/"
}

export_theme() {
    local template_name="$1"
    echo ":: Exporting theme..."
    sed -i "s/Name=.*/Name=$OUTPUT_THEME_NAME/g" "$tmp_dir/${template_name}/index.theme"
    
    rm -rf "$output_dir"
    mkdir -p "$output_dir"
    mv "$tmp_dir/${template_name}"/* "$output_dir/"
    echo "== Theme was generated in $output_dir"
}

replace_svg_colors() {
    local search_pattern="$1" hex_find="$2" hex_replace="$3" hex_fallover="$4"
    if [ -z "$hex_replace" ]; then
    	hex_replace="$hex_fallover"
    fi
    echo ":: Replacing colors ($hex_find -> $hex_replace)..."
    for icon_path in ${targets[@]}; do
    	sed -i'' -e "s/$hex_find/$hex_replace/g" "${icon_path}"
    done
}

replace_accent_colors(){
	local suffix="$1" pat_light="$2" pat_medium="$3" pat_dark="$4"
	for icon_path in ${targets[@]}; do
        local new_icon_path="${icon_path/$suffix/-oomox}"
        
        sed -e "s|replacecolour1|$ICONS_LIGHT_FOLDER|g" \
            -e "s|replacecolour2|$ICONS_MEDIUM|g" \
            -e "s|replacecolour3|$ICONS_DARK|g" "$icon_path" > "$new_icon_path"
		
		sed -i'' \
			-e "s|replacecolour1|$pat_light|g" \
            -e "s|replacecolour2|$pat_medium|g" \
            -e "s|replacecolour3|$pat_dark|g" "$icon_path"
            
        ln -sf "${new_icon_path##*/}" "${new_icon_path/-oomox/}"
    done
}

replacing_gradient_colors(){
	if [ -z "${SURUPLUS_GRADIENT1}" ] || [ "$SURUPLUS_GRADIENT_ENABLED" = false ]; then
		SURUPLUS_GRADIENT1="efefe7"
	fi
	
	if [ -z "${SURUPLUS_GRADIENT2}" ] || [ "$SURUPLUS_GRADIENT_ENABLED" = false ]; then
		SURUPLUS_GRADIENT2="8f8f8b"
	fi
	
	if [ "$SURUPLUS_GRADIENT_ENABLED" = false ]; then
		replacecolour_gradient="currentColor"
	else
		replacecolour_gradient="url(#oomox)"
	fi
	echo ":: Replacing gradient colors..."
   	for icon_path in ${targets[@]}; do
   		sed -i'' \
       		-e "s/replacecolour_gradient/$replacecolour_gradient/g" \
       		-e "s/replacecolour6/$SURUPLUS_GRADIENT1/g" \
       		-e "s/replacecolour7/$SURUPLUS_GRADIENT2/g" "$icon_path"
	done
}

# --- Initialization & Validation ---
check_var "OUTPUT_THEME_NAME" "$OUTPUT_THEME_NAME"
check_var "THEME" "$THEME"

source "$THEME"
SURUPLUS_GRADIENT_ENABLED=$(echo "${SURUPLUS_GRADIENT_ENABLED-False}" | tr '[:upper:]' '[:lower:]')
targets=()

# --- Theme Processing Styles ---
case "$icons_style_name" in
    archdroid)
        check_var "ICONS_ARCHDROID" "${ICONS_ARCHDROID:-}"
        copying_theme_template "archdroid-icon-theme"
        targets=($(find "$tmp_dir/archdroid-icon-theme" -type f))
        replace_svg_colors "*" "replacecolour1" "$ICONS_ARCHDROID" "CDDC39"
        export_theme "archdroid-icon-theme"
        ;;
    papirus_icons)
        copying_theme_template "Papirus"
        
        for size in 22x22 24x24 32x32 48x48 64x64; do
			for icon_path in \
				"$tmp_dir/Papirus/$size/places/folder-red"{-*,}.svg \
				"$tmp_dir/Papirus/$size/places/user-red"{-*,}.svg
			do
				[ -f "$icon_path" ] || continue  # it's a file
				[ -L "$icon_path" ] && continue  # it's not a symlink
				targets+=("$icon_path")
			done
		done
		replace_accent_colors "-red" "e25252" "bf4b4b" "4f1d1d"
		
		targets=($(find "$tmp_dir"/Papirus/{16x16,22x22,24x24}/{symbolic,actions} \
		"$tmp_dir"/Papirus/16x16/{devices,places} \
		-type f -name '*.svg'))
        replace_svg_colors "*.svg" "replacecolour4" "${ICONS_SYMBOLIC_ACTION}" "444444"
        
        targets=($(find "$tmp_dir"/Papirus/{16x16,22x22,24x24}/panel \
		"$tmp_dir"/Papirus/{22x22,24x24}/animations \
		-type f -name '*.svg'))
        replace_svg_colors "*.svg" "replacecolour5" "${ICONS_SYMBOLIC_PANEL}" "dfdfdf"
        export_theme "Papirus"
        ;;
    numix_icons)
        NUMIX_SHAPE="${ICONS_NUMIX_SHAPE-normal}"
        copying_theme_template "numix-icon-theme/Numix"
        copying_theme_template "numix-icon-theme/numix-folders/${ICONS_NUMIX_STYLE}/*"
        
        echo ":: Replacing colors..."
        find "${tmp_dir}"/Numix/*/{actions,places}/*custom* -type f -exec sed -i --follow-symlinks \
            -e "s/replacecolour1/#${ICONS_LIGHT_FOLDER}/g" \
            -e "s/replacecolour2/#${ICONS_MEDIUM}/g" \
            -e "s/replacecolour3/#${ICONS_DARK}/g" {} +

        echo ":: Creating symlinks..."
        currentcolour=$(readlink "${tmp_dir}"/Numix/16/places/folder.svg | cut -d '-' -f 1)
        while IFS= read -r -d '' link; do
            [[ $link == *folder_color* ]] && continue
            newlink=$(readlink "${link}")
            if [[ $newlink == *"$currentcolour"* ]]; then
                ln -sf "${newlink/${currentcolour}/custom}" "${link}"
            fi
        done < <(find -L "${tmp_dir}"/Numix/*/{actions,places} -xtype l -print0)

        echo ":: Applying style..."
        if [[ ${NUMIX_SHAPE} == 'circle' || ${NUMIX_SHAPE} == 'square' ]] ; then
            cp -rH "${tmp_dir}/Numix-${NUMIX_SHAPE^}/"* "${tmp_dir}"/Numix/
        fi
        export_theme "Numix"
        ;;
    suruplus_aspromauros_icons)
        copying_theme_template "Suru++-Asprómauros"        
        targets=($(find "$tmp_dir"/Suru++-Asprómauros/actions/{16,22,24,symbolic} \
		"$tmp_dir"/Suru++-Asprómauros/apps/{16,symbolic} \
		"$tmp_dir"/Suru++-Asprómauros/devices/{16,symbolic} \
		"$tmp_dir"/Suru++-Asprómauros/emblems/symbolic \
		"$tmp_dir"/Suru++-Asprómauros/emotes/symbolic \
		"$tmp_dir"/Suru++-Asprómauros/mimetypes/16 \
		"$tmp_dir"/Suru++-Asprómauros/panel/{16,22,24} \
		"$tmp_dir"/Suru++-Asprómauros/places/{16,symbolic} \
		"$tmp_dir"/Suru++-Asprómauros/status/symbolic \
		-type f -name '*.svg'))
        
        replace_svg_colors "*.svg" "replacecolour4" "${ICONS_SYMBOLIC_ACTION}" "ececec"
		replacing_gradient_colors 
		
		targets=($(find "$tmp_dir"/Suru++-Asprómauros/animations/{22,24} -type f -name '*.svg'))
		replace_svg_colors "*.svg" "replacecolour5" "${ICONS_SYMBOLIC_PANEL}" "d3dae3"
        export_theme "Suru++-Asprómauros"
        ;;
    suruplus_icons)
        copying_theme_template "Suru++"
        
        for icon_path in \
			"$tmp_dir/Suru++/places/64/folder-custom"{-*,}.svg \
			"$tmp_dir/Suru++/places/64/user-custom"{-*,}.svg
		do
			[ -f "$icon_path" ] || continue  # it's a file
			[ -L "$icon_path" ] && continue  # it's not a symlink
		
			new_icon_path="${icon_path/-custom/-oomox}"
			icon_name="${new_icon_path##*/}"
			symlink_path="${new_icon_path/-oomox/}"  # remove color suffix
			targets+=("$icon_path")
		done
		replace_accent_colors "-custom" "value_light" "value_dark" "323232"
		
		targets=($(find "$tmp_dir"/Suru++/actions/{16,22,24,symbolic} \
		"$tmp_dir"/Suru++/apps/{16,symbolic} \
		"$tmp_dir"/Suru++/devices/{16,symbolic} \
		"$tmp_dir"/Suru++/mimetypes/16 \
		"$tmp_dir"/Suru++/places/{16,symbolic} \
		"$tmp_dir"/Suru++/status/symbolic \
		-type f -name '*.svg'))
        replace_svg_colors "*.svg" "replacecolour4" "${ICONS_SYMBOLIC_ACTION}" "5c616c"
               
        targets=($(find "$tmp_dir"/Suru++/panel/{16,22,24} "$tmp_dir"/Suru++/animations/{22,24} -type f -name '*.svg'))
        replace_svg_colors "*.svg" "replacecolour5" "${ICONS_SYMBOLIC_PANEL}" "d3dae3"

		targets=($(find "$tmp_dir"/Suru++/apps/16 \
		"$tmp_dir"/Suru++/devices/16 \
		"$tmp_dir"/Suru++/mimetypes/16 \
		"$tmp_dir"/Suru++/places/16 \
		-type f -name '*.svg'))
		replacing_gradient_colors 
        export_theme "Suru++"
        ;;
    gnome_colors)
        theme_color_file_temp_dir="/tmp/gnome_colors_script"
        cp -r "${root}/gnome-colors/"* "${tmp_dir}/"
        mkdir -p "${theme_color_file_temp_dir}"
        
        cat > "${theme_color_file_temp_dir}/${OUTPUT_THEME_NAME}" <<-EOF
		Name=${OUTPUT_THEME_NAME}
		Distribution=gnome-colors
		LightFolderBase=#${ICONS_LIGHT_FOLDER}
		LightBase=#${ICONS_LIGHT}
		MediumBase=#${ICONS_MEDIUM}
		DarkStroke=#${ICONS_DARK}
		EOF

        (
            cd "${tmp_dir}"
            make -j "$(nproc)" "${OUTPUT_THEME_NAME}"
            rm -rf "${output_dir}"
            mkdir -p "${output_dir}"
            cp -r ./gnome-colors-common/* "${output_dir}"/
            cp -r ./"${OUTPUT_THEME_NAME}"/* "${output_dir}"/
        )
        ;;
esac
