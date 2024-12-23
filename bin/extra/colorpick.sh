#!/bin/sh
# if this line exist script will be part of hub script.

set -e

# Function to copy to clipboard with different tools depending on the display server
cp2cb() {
  case "$XDG_SESSION_TYPE" in
    'x11') xclip -selection clipboard;;
    'wayland') wl-copy -n;; 
    *) err "Unknown display server";; 
  esac
}

if command -v colorpicker >/dev/null
then
	colorpicker --short --one-shot --preview | cp2cb
else
	if command -v gpick >/dev/null
	then
		color=$(gpick -so 2>/dev/null)
	elif command -v xcolor >/dev/null
	then
		color=$(xcolor)
	else
		echo "please install gpick or xcolor"
		exit 1
	fi
	
	if [ -n "$color" ]; then
    	random_file=$(mktemp --suffix ".png")
    	# generate preview
    	convert -size 100x100 xc:"$color" "$random_file"
    	# notify about it
		dunstify -u low --replace=69 -i "$random_file" -a ColorPicker -u normal "$color"
	fi
fi
