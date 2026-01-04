#!/bin/sh
set -e
[ -d "$HOME/.config/conky/syclo/images/" ] && cd "$HOME/.config/conky/syclo/images/"
[ -d "$HOME/Desktop/my_stuff/skel_extra/.config/conky/syclo/images/" ] && cd "$HOME/Desktop/my_stuff/skel_extra/.config/conky/syclo/images/"

make_colors_dir(){
	color_dir_name="${1:-}"
	color_pal="${2:-}"
	
	[ ! -d "$color_dir_name" ] && cp -r base "$color_dir_name"
	cd "$color_dir_name"
	for filename in *.svg; do
		sed -i "s/220,20,60/${color_pal}/g" "$filename"
	done
	cd ..
}

make_colors_dir orange "255,167,38"
make_colors_dir lime "124,252,0"
make_colors_dir froly "253,121,128"
make_colors_dir cyan "64,224,208"
make_colors_dir crimson "220,20,60"
make_colors_dir blue "82,148,226"
