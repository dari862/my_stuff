export my_stuff_display_manager_lib_path="/usr/share/my_stuff/display_server/X11"

if [ -d "/usr/share/my_stuff/bin/X11/bspwm" ];then
   	PATH="/usr/share/my_stuff/bin/X11/bspwm:$PATH"
fi

if [ -d "/usr/share/my_stuff/bin/X11/pipemenu" ] && command -v jgmenu >/dev/null 2>&1;then
   	PATH="/usr/share/my_stuff/bin/X11/pipemenu:$PATH"
fi

if [ -d "/usr/share/my_stuff/system_files/binX11" ];then
	PATH="/usr/share/my_stuff/system_files/binX11:$PATH"
else
	echo "ERROR: /usr/share/my_stuff/system_files/bin Does not exist."
fi

usr_autostart="$usr_confdir/dwm/dwmrc"
default_autostart='/usr/share/my_stuff/system_files/skel/.config/dwm'

# At least try to ensure user has an autostart file.
[ -e "$usr_autostart" ] || {
	echo "$0: ERROR $usr_autostart does not exist, copying in $default_autostart" >&2
	cp -r "$default_autostart" "$usr_confdir"
}

. "$usr_autostart"

exec dwm
