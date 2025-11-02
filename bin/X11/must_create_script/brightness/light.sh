get_backlight() {
	LIGHT=$(printf "%.0f\n" $(light -G))
	echo "${LIGHT}%"
}

inc_backlight() {
	light -A 5 && get_icon && dunstify -u low --replace=69 -i "$icon" "Brightness : $(get_backlight)"
}

dec_backlight() {
	light -U 5 && get_icon && dunstify -u low --replace=69 -i "$icon" "Brightness : $(get_backlight)"
}
