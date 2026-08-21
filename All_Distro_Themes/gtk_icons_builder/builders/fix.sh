#!/usr/bin/env bash
set -ueo pipefail

current_path="$(dirname "$(realpath "$0")")"
out_put_dir="$current_path/baseIcons"

if [ -d "$out_put_dir" ];then
	exit
fi

copy_files_theme(){
	mkdir -p "$out_put_dir"
	
	cd "$HOME/Desktop/my_stuff_installer/workonNow/oomox_files/oomox_gui/plugins/"
	
	cp -r "icons_archdroid/archdroid-icon-theme/archdroid-icon-theme/" "$out_put_dir"
	
	cp -r "icons_gnomecolors/gnome-colors-icon-theme/gnome-colors/" "$out_put_dir"
	
	cp -r "icons_numix/numix-icon-theme/" "$out_put_dir"
	
	rm -rdf "icons_numix/numix-icon-theme/Numix-Light" "icons_numix/numix-icon-theme/license" "icons_numix/numix-icon-theme/readme.md"
	
	mkdir -p "${out_put_dir}/numix-icon-theme/numix-folders"
	
	cp -r "icons_numix/numix-folders/styles"/* "${out_put_dir}/numix-icon-theme/numix-folders"
	
	cp -r "icons_papirus/papirus-icon-theme/Papirus/" "${out_put_dir}"
	
	cp -r "icons_suruplus/suru-plus/Suru++/" "${out_put_dir}"
	
	cp -r "icons_suruplus_aspromauros/suru-plus-aspromauros/Suru++-Asprómauros" "${out_put_dir}"
	
	cp -r "${current_path}/theme_builder.sh" "$out_put_dir"
	
	cd "$out_put_dir"
}

replace_svg_colors() {
    local search_pattern="$1" hex_find="$2" hex_replace="$3"
        echo ":: Replacing colors ($hex_find -> $hex_replace)..."
        find ${targets[@]} -type f -name "$search_pattern" \
            -exec sed -i'' -e "s/$hex_find/$hex_replace/g" '{}' +
}

replace_accent_colors(){
	local suffix="$1" pat_light="$2" pat_medium="$3" pat_dark="$4"
	for icon_path in ${targets[@]}; do
        # Ensure file exists and isn't a symlink (handles unexpanded globs gracefully)
        [ -f "$icon_path" ] && [ ! -L "$icon_path" ] || continue

        local new_icon_path="${icon_path/$suffix/-oomox}"
        
        sed -i'' -e "s|$pat_light|replacecolour1|g" \
            -e "s|$pat_medium|replacecolour2|g" \
            -e "s|$pat_dark|replacecolour3|g" "$icon_path"
    done
}

replacing_gradient_colors(){
		echo ":: Replacing gradient colors..."
            find ${targets[@]} -type f -name '*.svg' -exec sed -i'' \
                -e "s/efefe7/replacecolour6/g" \
                -e "s/8f8f8b/replacecolour7/g" '{}' \;
}

copy_files_theme

###################################
targets=(archdroid-icon-theme)
replace_svg_colors "*" "CDDC39" "replacecolour1"
###################################
targets=(Papirus/{22x22,24x24,32x32,48x48,64x64}"/places/"{folder,user}"-red"{-*,}.svg)
replace_accent_colors "-red" "e25252" "bf4b4b" "4f1d1d"
		
targets=(Papirus/{16x16,22x22,24x24}/{symbolic,actions} Papirus/16x16/{devices,places})
replace_svg_colors "*.svg" "444444" "replacecolour4"
        
targets=(Papirus/{16x16,22x22,24x24}/panel Papirus/{22x22,24x24}/animations)
replace_svg_colors "*.svg" "dfdfdf" "replacecolour5"
###################################    
targets=(Suru++-Asprómauros/actions/{16,22,24,symbolic}
	Suru++-Asprómauros/apps/{16,symbolic}
	Suru++-Asprómauros/devices/{16,symbolic}
	Suru++-Asprómauros/emblems/symbolic
	Suru++-Asprómauros/emotes/symbolic
	Suru++-Asprómauros/mimetypes/16
	Suru++-Asprómauros/panel/{16,22,24}
	Suru++-Asprómauros/places/{16,symbolic}
	Suru++-Asprómauros/status/symbolic)
        
replace_svg_colors "*.svg" "ececec" "replacecolour4"
replace_svg_colors "*.svg" "d3dae3" "replacecolour5"
replacing_gradient_colors
find ${targets[@]} -type f -name '*.svg' -exec sed -i'' \
	-e 's/fill="currentColor" class="ColorScheme-Text"/fill="replacecolour_gradient" class="ColorScheme-Text"/g' \
	-e 's/stroke="currentColor" class="ColorScheme-Text"/stroke="replacecolour_gradient" class="ColorScheme-Text"/g' '{}' \;
###################################
targets=(Suru++/places/64/{folder,user}"-custom"{-*,}.svg)
replace_accent_colors "-custom" "value_light" "value_dark" "323232"
		
targets=(Suru++/actions/{16,22,24,symbolic}
		Suru++/apps/{16,symbolic}
		Suru++/devices/{16,symbolic}
		Suru++/mimetypes/16
		Suru++/places/{16,symbolic}
		Suru++/status/symbolic)

replace_svg_colors "*.svg" "5c616c" "replacecolour4"
               
targets=(Suru++/panel/{16,22,24} Suru++/animations/{22,24})
replace_svg_colors "*.svg" "d3dae3" "replacecolour5"

targets=(Suru++/apps/16
		Suru++/devices/16
		Suru++/mimetypes/16
		Suru++/places/16)

replacing_gradient_colors
find ${targets[@]} -type f -name '*.svg' -exec sed -i'' \
	-e 's/currentColor/replacecolour_gradient/g' '{}' \;

echo "done done done"
