#!/bin/sh
# Get Volume
get_volume() {
	volume="$(amixer get Master | tail -n1 | awk -F ' ' '{print $5}' | tr -d '[]')"
	echo "$volume"
}

# Get icons
get_icon() {
	vol="$(get_volume)"
	current="${vol%%%}"
	if [ "$current" -eq 0 ];then
		icon='/usr/share/my_stuff/icons/dunst/volume-mute.png'
	elif [ "$current" -ge 0 ] && [ "$current" -le 30 ];then
		icon='/usr/share/my_stuff/icons/dunst/volume-low.png'
	elif [ "$current" -ge 30 ] && [ "$current" -le 60 ];then
		icon='/usr/share/my_stuff/icons/dunst/volume-mid.png'
	elif [ "$current" -ge 60 ] && [ "$current" -le 100 ];then
		icon='/usr/share/my_stuff/icons/dunst/volume-high.png'
	fi
}

# Increase Volume
inc_volume() {
	amixer -Mq set Master,0 5%+ unmute && get_icon && dunstify -u low --replace=69 -i "$icon" "Volume : $(get_volume)"
}

# Decrease Volume
dec_volume() {
	amixer -Mq set Master,0 5%- unmute && get_icon && dunstify -u low --replace=69 -i "$icon" "Volume : $(get_volume)"
}

# Toggle Mute
toggle_mute() {
	status="$(amixer get Master | tail -n1 | grep -wo 'on')"

	if [ "$status" = "on" ];then
		amixer set Master toggle && dunstify -u low --replace=69 -i '/usr/share/my_stuff/icons/dunst/volume-mute.png' "Mute"
	else
		amixer set Master toggle && get_icon && dunstify -u low --replace=69 -i "$icon" "Unmute"
	fi
}
