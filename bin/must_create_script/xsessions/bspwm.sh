# include my_stuff/bin/bspwm in PATH
if [ -d "/usr/share/my_stuff/bin/bspwm" ];then
   	PATH="/usr/share/my_stuff/bin/bspwm:$PATH"
fi

usr_autostart="$usr_confdir/bspwm/bspwmrc"
default_autostart='/usr/share/my_stuff/system_files/skel/.config/bspwm'

# At least try to ensure user has an autostart file.
[ -e "$usr_autostart" ] || {
	echo "$0: ERROR $usr_autostart does not exist, copying in $default_autostart" >&2
	cp -r "$default_autostart" "$usr_confdir"
}

exec /usr/bin/bspwm
