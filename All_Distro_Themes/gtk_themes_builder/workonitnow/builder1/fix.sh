#!/usr/bin/env bash
set -ueo pipefail

current_path="$(dirname "$(realpath "$0")")"
out_put_dir="$current_path/baseGTK"
plugins_path="$HOME/Desktop/my_stuff_installer/workon/oomox_files/oomox_gui/plugins/"

if [ -d "$out_put_dir" ];then
	exit
fi
	
set_colors_placeholder() {
	:
}

render_assets() {
	local i	
    while IFS= read -r i; do
        inkscape \
        	--export-id="$i" \
        	--export-id-only \
        	--export-filename="$assets_dir/${i}.svg" \
        	"$src_file" >/dev/null
    done < assets.txt
}

render_all_assets(){
	cd "$out_put_dir/materia/src/gtk-2.0"
	src_file="assets.svg"
    assets_dir="assets"
    render_assets
        
	src_file="assets-dark.svg"
    assets_dir="assets-dark"
	render_assets
    rm -rf assets.txt
    
    cd "$out_put_dir/materia/src/gtk-3.0"
    src_file="assets.svg"
    assets_dir="assets"
	render_assets
	rm -rf assets.txt
	
}

copy_files_theme_materia(){
	local asset
	mkdir -p "$out_put_dir"
	sudo apt-get install -y inkscape
	cd "$plugins_path"
	cp -r "theme_materia/materia-theme" "$out_put_dir"
	cd "$out_put_dir"
	mkdir -p "materia"
	mv "materia-theme/src" "materia"
	rm -rdf "materia-theme"
	
	cd "$out_put_dir/materia/src"
	set_colors_placeholder
	
	render_all_assets
	
	find . -type f \( \
    	-name '*.meson*' -o \
    	-name 'meson.build' -o \
    	-name 'meson_options.txt' -o \
    	-name 'render-asset.sh' -o \
    	-name 'render-assets.sh' \
	\) -delete
	#sudo apt-get purge -y inkscape
}

copy_files_theme_oomox(){	
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

copy_files_theme_materia
copy_files_theme_oomox

echo "done done done"
