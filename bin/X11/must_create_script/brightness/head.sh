#!/bin/sh

# Graphics card

screens="$(xrandr -q | grep -v "HDMI" | grep " connected")"

if [ -z "$screens" ];then
	echo "$0: screens var is empty"
	exit 0
fi

#####################################################################################
# software to use
