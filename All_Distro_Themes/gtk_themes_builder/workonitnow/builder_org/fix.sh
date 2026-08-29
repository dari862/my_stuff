#!/usr/bin/env bash
set -ueo pipefail

current_path="$(dirname "$(realpath "$0")")"
out_put_dir="$current_path/baseGTK"
plugins_path="$HOME/Desktop/my_stuff_installer/workon/oomox_files/oomox_gui/plugins/"

if [ -d "$out_put_dir" ];then
	exit
fi

render_svg() {
    local id="$1"
    local output="$2"
    local src="$3"

    inkscape \
        --export-id="$id" \
        --export-id-only \
        --export-filename="${output}.svg" \
        "$src" >/dev/null
}

render_gtk2_asset() {
	local i="$1"
	render_svg "$i" 96 "$assets_dir/${i}-generated" "$src_file"
    cp -rf "$assets_dir/${i}-generated.svg" "$assets_dir/${i}-generated.HIDPI.svg"
}
	
render_gtk3_asset() {
	local i="${1:-}"
	render_svg "$i" "assets/${i}-generated" "assets.svg"
	cp -rf "assets/${i}-generated.svg" "assets/${i}@2-generated.svg"
}

copy_files_theme(){
	local asset
	mkdir -p "$out_put_dir"
	sudo apt-get install -y inkscape
	cd "$plugins_path"
	cp -r "theme_materia/materia-theme" "$out_put_dir"
	cd "$out_put_dir"
	mkdir -p "materia"
	mv "materia-theme/src" "materia"
	rm -rdf "materia-theme"
	cd "$out_put_dir/materia/src/gtk-2.0"
	src_file="assets.svg"
    assets_dir="assets"
    while IFS= read -r asset; do
        render_gtk2_asset "$asset"
    done < assets.txt
	src_file="assets-dark.svg"
    assets_dir="assets-dark"
	while IFS= read -r asset; do
    	render_gtk2_asset "$asset"
    done < assets.txt
    rm -rf assets.txt
	cd "$out_put_dir/materia/src/gtk-3.0"
	while IFS= read -r asset; do
        render_gtk3_asset "$asset"
    done < assets.txt
	rm -rf assets.txt
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
	#sudo apt-get purge -y inkscape
}

copy_files_theme

echo "done done done"
