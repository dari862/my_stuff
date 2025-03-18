# Get Volume
get_volume() {
	pulsemixer --get-volume | cut -d' ' -f1
}

# Get icons
get_icon() {
	current="$(get_volume)"
	if [ "$current" -ge 0 ] && [ "$current" -le 30 ];then
		icon=""
	elif [ "$current" -ge 30 ] && [ "$current" -le 60 ];then
		icon=""
	elif [ "$current" -ge 60 ] && [ "$current" -le 100 ];then
		icon=""
	fi
}

# Get status
get_status() {
	get_icon
	if [ "$(pulsemixer --get-mute)" -eq 1 ];then
		echo ' Mute'
	else
		echo "$icon $(get_volume)%"
	fi
}

# Increase Volume
inc_volume() {
	[ "$(pulsemixer --get-mute)" -eq 1 ] && pulsemixer --unmute
	pulsemixer --max-volume 100 --change-volume +10
}

# Decrease Volume
dec_volume() {
	[ "$(pulsemixer --get-mute)" -eq 1 ] && pulsemixer --unmute
	pulsemixer --max-volume 100 --change-volume -10
}

# Toggle Mute
toggle_mute() {
	pulsemixer --toggle-mute
}

# Toggle Mic
toggle_mic() {
	ID="$(pulsemixer --list-sources | grep 'Default' | cut -d',' -f1 | cut -d' ' -f3)"
	pulsemixer --id ${ID} --toggle-mute
}
