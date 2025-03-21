
# Get icons
get_icon() {
	backlight="$(get_backlight)"
	current="${backlight%%%}"
	if [[ ("$current" -ge "0") && ("$current" -le "25") ]];then
		icon=''
	elif [[ ("$current" -ge "25") && ("$current" -le "50") ]];then
		icon=''
	elif [[ ("$current" -ge "50") && ("$current" -le "75") ]];then
		icon=''
	elif [[ ("$current" -ge "75") && ("$current" -le "100") ]];then
		icon=''
	fi
}

#####################################################################################
# Get status
get_status() {
	get_icon
	echo "$icon $(get_backlight)"
}

# Execute accordingly
if [[ "$1" == "--get" ]];then
	get_status
elif [[ "$1" == "--inc" ]];then
	inc_backlight
elif [[ "$1" == "--dec" ]];then
	dec_backlight
else
	get_status
fi
