#!/bin/sh
# if this line exist script will be part of hub script.

set -e

err(){
	__message=""
	yad --image="dialog-question" \
			--title "Alert" \
			--text-align=center \
			--text="Somthing went wrong!!" \
			--entry --entry-label=Label \
			--entry-text="${__message}" 
			exit 1
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
