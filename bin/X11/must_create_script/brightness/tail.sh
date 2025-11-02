check_icon_exists() {
    icon_name="$1"
    icon_path=$(find /usr/share/icons ~/.icons ~/.local/share/icons \
                  -type f -name "${icon_name}*.png" -o -name "${icon_name}*.svg" 2>/dev/null | head -n 1)

    if [ -n "$icon_path" ]; then
        return 0
    else
        return 1
    fi
}

get_icon() {
	backlight="$(get_backlight)"
	current="${backlight%%%}"
	if [ "$current" -eq 0 ]; then
		icon_string=''
		icon_gtk='notification-display-brightness-off'
	elif [ "$current" -lt "50" ];then
		icon_string=''
		icon_gtk='notification-display-brightness-low'
	elif [ "$current" -lt "75" ];then
		icon_string=''
		icon_gtk='notification-display-brightness-medium'
	elif [ "$current" -lt "100" ];then
		icon_string=''
		icon_gtk='notification-display-brightness-high'
	else
		icon_string=''
		icon_gtk='notification-display-brightness-full'
	fi
	
	if ! check_icon_exists "$icon_gtk"; then
		icon="$icon_string"
	else
		icon="$icon_gtk"
	fi
}

#####################################################################################
get_status() {
	get_icon
	echo "$icon $(get_backlight)"
}
case "$1" in
	"--get") get_status ;;
	"--inc") inc_backlight ;;
	"--dec") dec_backlight ;;
	*) get_status ;;
esac
