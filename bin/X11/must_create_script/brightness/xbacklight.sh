get_backlight() {
	BNESS="$(xbacklight -get)"
	LIGHT="${BNESS%.*}"
	echo "${LIGHT}%"
}

inc_backlight() {
	xbacklight -inc 10 && get_icon && dunstify -u low --replace=69 -i "$icon" "Brightness : $(get_backlight)"
}

dec_backlight() {
	xbacklight -dec 10 && get_icon && dunstify -u low --replace=69 -i "$icon" "Brightness : $(get_backlight)"
}
