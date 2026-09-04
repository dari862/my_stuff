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
	cp -r "theme_materia/materia-theme" "$out_put_dir/materia"
	cp -r "theme_oomox" "$out_put_dir/oomox"
	cp -r "${current_path}/theme_builder.1.old.sh" "$out_put_dir/theme_builder.sh"
	
	cd "$out_put_dir"
}

copy_files_theme

echo "done done done"
