get_backlight() {
	LIGHT=$(printf "%.0f\n" $(light -G))
	echo "${LIGHT}%"
}
	
# Increase brightness
inc_backlight() {
	light -A 5 && get_icon && dunstify -u low --replace=69 -i "$icon" "Brightness : $(get_backlight)"
}
	
# Decrease brightness
dec_backlight() {
	light -U 5 && get_icon && dunstify -u low --replace=69 -i "$icon" "Brightness : $(get_backlight)"
}
