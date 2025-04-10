#!/bin/sh
if pgrep "picom" >/dev/null 2>&1;then
	polybar-msg action "#blur-toggle.hook.-0"
	picom-session stop
	notify-send -u low 'picom' "Blur Disabled"
else
	polybar-msg action "#blur-toggle.hook.1"
	picom-session
	notify-send -u low 'picom' "Blur Enabled"
fi
