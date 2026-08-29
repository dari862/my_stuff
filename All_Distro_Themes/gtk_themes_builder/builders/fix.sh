#!/usr/bin/env bash
set -ueo pipefail

current_path="$(dirname "$(realpath "$0")")"
out_put_dir="$current_path/baseGTK"
plugins_path="$HOME/Desktop/my_stuff_installer/workon/oomox_files/oomox_gui/plugins/"

if [ -d "$out_put_dir" ];then
	exit
fi

copy_files_theme(){
	mkdir -p "$out_put_dir"
	
	cd "$plugins_path"
	cp -r "theme_materia/materia-theme" "$out_put_dir"
	cd "$out_put_dir"
	mkdir -p "materia"
	mv "materia-theme/src" "materia"
	rm -rdf "materia-theme"
	find . -type f \( \
    	-name '*.meson*' -o \
    	-name 'meson.build' -o \
    	-name 'meson_options.txt' -o \
    	-name 'render-asset.sh' -o \
    	-name 'render-assets.sh' \
	\) -delete
	cd "$plugins_path"
	cp -r "theme_oomox" "$out_put_dir"
	cd "$out_put_dir"
	mkdir -p "oomox"
	mv "theme_oomox/src" "oomox"
	mv "theme_oomox/Makefile" "oomox"
	rm -rdf "theme_oomox"
	
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

echo "done done done"
