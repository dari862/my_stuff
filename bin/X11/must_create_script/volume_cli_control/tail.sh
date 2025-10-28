# main

is_muted=false
current_volume=""

# Execute accordingly
if [ "$1" = "--get" ];then
	set_volume
	print_volume
elif [ "$1" = "--icon" ];then
	set_volume
	print_icon
elif [ "$1" = "--inc" ];then
	inc_volume
	set_volume
	send_notification
elif [ "$1" = "--dec" ];then
	dec_volume
	set_volume
	send_notification
elif [ "$1" = "--toggle" ];then
	toggle_mute
	set_volume
	send_notification
elif [ "$1" = "--toggle-mic" ];then
	toggle_mic
	set_volume
	send_notification
elif [ "$1" = "--is-muted" ];then
	am_muted
else
	set_volume
	send_notification
fi
