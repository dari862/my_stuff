#!/bin/sh
check_icon_exists() {
    icon_name="$1"
    icon_path=$(find /usr/share/icons ~/.icons ~/.local/share/icons \
                  -type f -name "${icon_name}*.png" -o -name "${icon_name}*.svg" 2>/dev/null | head -n 1)

    if [ -n "$icon_path" ]; then
        return 0  # icon found
    else
        return 1  # icon not found
    fi
}

send_notification() {
	if am_muted;then
		icon_string=""
		icon_gtk='notification-audio-volume-muted'
		is_muted=true
	else
		if [ "$current_volume" -le 30 ];then
			icon_string=""
			icon_gtk='notification-audio-volume-low'
		elif [ "$current_volume" -le 60 ];then
			icon_string=""
			icon_gtk='notification-audio-volume-medium'
		elif [ "$current_volume" -le 100 ];then
			icon_string=""
			icon_gtk='notification-audio-volume-high'
		fi
	fi
	
	if ! check_icon_exists "$icon_gtk"; then
		icon="$icon_string"
	else
		icon="$icon_gtk"
	fi
	
	if [ "$is_muted" = true ]; then
    	dunstify "Volume: Muted" \
        	-h string:synchronous:audio-volume \
        	-i "$icon" \
        	-t 1000
	else
    	dunstify "Volume: ${current_volume}%" \
        	-h "int:value:$current_volume" \
        	-h string:synchronous:audio-volume \
        	-i "$icon" \
        	-t 1000
	fi
}
