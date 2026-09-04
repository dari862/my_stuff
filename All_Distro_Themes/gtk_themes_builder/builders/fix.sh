#!/usr/bin/env bash
set -ueo pipefail

current_path="$(dirname "$(realpath "$0")")"
out_put_dir="$current_path/baseGTK"
plugins_path="$HOME/Desktop/my_stuff_installer/workon/oomox_files/oomox_gui/plugins/"

if [ -d "$out_put_dir" ];then
	exit
fi
	
set_colors_placeholder() {
    local -a PATHLIST=(
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
        './src/gtk-2.0/assets.svg'
		'./src/gtk-2.0/assets-dark.svg'
		'./src/gtk-3.0/assets.svg'
    )

    echo "Converting theme into template"
    for FILEPATH in "${PATHLIST[@]}"; do
            find "$FILEPATH" -type f -not -name '_color-palette.scss' -exec sed -i'' \
                -e 's/#8ab4f8/%SEL_BG_new1%/g' \
                -e 's/#1967d2/%SEL_BG_new2%/g' \
                -e 's/#000000/%FG_new1%/g' \
                -e 's/#212121/%FG_new2%/g' \
                -e 's/#f9f9f9/%BG_new1%/g' \
                -e 's/#ffffff/%WHITE_COLOR_PLACEHOLDER%/g' \
                -e 's/#424242/%HDR_BG_new1%/g' \
                -e 's/#303030/%HDR_BG2_new1%/g' \
                -e 's/#c1c1c1/%INACTIVE_FG_new1%/g' \
                -e 's/#f0f0f0/%HDR_BG_new2%/g' \
                -e 's/#ebebeb/%HDR_BG2_new2%/g' \
                -e 's/#1d1d1d/%HDR_FG_new1%/g' \
                -e 's/#565656/%INACTIVE_FG_new2%/g' \
                -e 's/#ffffff/%WHITE_COLOR_PLACEHOLDER%/g' \
                -e 's/#eeeeee/%FG_new3%/g' \
                -e 's/#121212/%BG_new2%/g' \
                -e 's/#2e2e2e/%MATERIA_SURFACE_new1%/g' \
                -e 's/#1e1e1e/%MATERIA_VIEW_new1%/g' \
                -e 's/#272727/%HDR_BG_new3%/g' \
                -e 's/#1e1e1e/%HDR_BG2_new3%/g' \
                -e 's/#e4e4e4/%HDR_FG_new2%/g' \
                -e 's/#a7a7a7/%INACTIVE_FG_new3%/g' \
                -e 's/Materia/%OUTPUT_THEME_NAME%/g' \
                {} \; ;
    done
 	 	
    mv ./src/_theme-color.template.scss ./src/_theme-color.scss 
}

render_assets_old() {
	local i	
    while IFS= read -r i; do
        inkscape \
        	--export-id="$i" \
        	--export-id-only \
        	--export-filename="$assets_dir/${i}.svg" \
        	"$src_file" >/dev/null
    done < assets.txt
}

render_assets() {
	local i actions="file-open:$src_file;"
	while IFS= read -r i; do
		actions+="export-id:${i}; export-id-only; export-overwrite;"
		actions+="export-filename:${assets_dir}/${i}.svg; export-do;"
	done < assets.txt
	inkscape --shell <<< "$actions" >/dev/null
}

render_all_assets(){
	cd "$out_put_dir/materia/src/gtk-2.0"
	src_file="assets.svg"
    assets_dir="assets"
    render_assets
    rm -rdf "$src_file"
    
	src_file="assets-dark.svg"
    assets_dir="assets-dark"
	render_assets
    rm -rdf "$src_file"
     
    cd "$out_put_dir/materia/src/gtk-3.0"
    src_file="assets.svg"
    assets_dir="assets"
	render_assets
	rm -rdf "$src_file"
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
	
	cd "$out_put_dir/materia"
	set_colors_placeholder
	
	render_all_assets
	
	cd "$out_put_dir/materia"
	find . -type f \( \
    	-name '*.meson*' -o \
    	-name 'meson.build' -o \
    	-name 'meson_options.txt' -o \
    	-name 'render-asset.sh' -o \
    	-name 'render-assets.sh' -o \
    	-name 'assets.txt' \
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
