############################################
#	pulsemixer
############################################

# print Volume
set_volume() {
	current_volume="$(pulsemixer --get-volume | cut -d' ' -f1)"
}

print_volume() {
	echo "$current_volume"
}

print_icon() {
	echo "$icon_string"
}

# Get status
am_muted() {
	if [ "$(pulsemixer --get-mute)" -eq 1 ];then
		return 0
	else
		return 0
	fi
}

# Increase Volume
inc_volume() {
	am_muted && pulsemixer --unmute
	pulsemixer --max-volume 100 --change-volume +10
}

# Decrease Volume
dec_volume() {
	am_muted && pulsemixer --unmute
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
