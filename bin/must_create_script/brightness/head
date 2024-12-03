#!/bin/sh

# Graphics card

screens="$(xrandr -q | grep -v "HDMI" | grep " connected")"

[ -z "$screens" ] && echo "$0: screens var is empty" &&exit 0

#####################################################################################
# software to use
