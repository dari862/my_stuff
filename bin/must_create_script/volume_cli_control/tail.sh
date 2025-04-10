# Execute accordingly
if [ "$1" = "--get" ];then
	get_volume
elif [ "$1" = "--inc" ];then
	inc_volume
elif [ "$1" = "--dec" ];then
	dec_volume
elif [ "$1" = "--toggle" ];then
	toggle_mute
elif [ "$1" = "--toggle-mic" ];then
	toggle_mic
else
	get_volume
fi
