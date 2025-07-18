#!/bin/sh
# if this line exist script will be part of hub script.

set -e

err(){
	. "/usr/share/my_stuff/lib/common/WM"
	. "${Distro_config_file}"
	__message="${1:-}"
	rofi -e "Alert (Somthing went wrong!!):\n ${__message}" -theme "$HOME/.config/rofi/$ROFI_STYLE"/askpass.rasi && exit 1		
}

# Function to copy to clipboard with different tools depending on the display server
case "$XDG_SESSION_TYPE" in
	'x11') cp2cb(){ xclip -selection clipboard; };;
	'wayland') cp2cb(){ wl-copy -n; };; 
	*) err "Unknown display server";; 
esac

if command -v colorpicker >/dev/null;then
	colorpicker --short --one-shot --preview | cp2cb
else
	if command -v gpick >/dev/null;then
		color=$(gpick -so 2>/dev/null)
	else
		err "please install colorpicker or gpick ."
	fi
	
	if [ -n "$color" ];then
    	random_file=$(mktemp --suffix ".png")
    	# generate preview
    	convert -size 100x100 xc:"$color" "$random_file"
    	# notify about it
		dunstify -u low --replace=69 -i "$random_file" -a ColorPicker -u normal "$color"
		echo "$color" | cp2cb
	fi
fi
