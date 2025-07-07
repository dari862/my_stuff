############################################
#	amixer
############################################

# print Volume
set_volume() {
	current_volume="$(amixer get Master | tail -n1 | awk -F ' ' '{print $5}' | tr -d '[]')"
	current_volume="${current_volume%%%}"
}
print_volume() {
	echo "$current_volume"
}

# Increase Volume
inc_volume() {
	amixer -Mq set Master,0 5%+ unmute
}

# Decrease Volume
dec_volume() {
	amixer -Mq set Master,0 5%- unmute
}

am_muted() {
   	if amixer get Master | tail -n1 | grep -woq 'on';then
		return 0
	else
		return 1
	fi
}

# Toggle Mute
toggle_mute() {
	amixer set Master toggle
}
