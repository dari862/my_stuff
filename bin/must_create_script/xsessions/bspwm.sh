export my_stuff_display_manager_lib_path="${__distro_path_root}/display_server/X11"

if [ -d "${__distro_path_root}/bin/X11/bspwm" ];then
   	PATH="${__distro_path_root}/bin/X11/bspwm:$PATH"
fi

if [ -d "${__distro_path_root}/bin/X11/pipemenu" ] && command -v jgmenu >/dev/null 2>&1;then
   	PATH="${__distro_path_root}/bin/X11/pipemenu:$PATH"
fi

if [ -d "${__distro_path_root}/system_files/binX11" ];then
	PATH="${__distro_path_root}/system_files/binX11:$PATH"
else
	echo "ERROR: ${__distro_path_root}/system_files/bin Does not exist."
fi

usr_autostart="$usr_confdir/bspwm/bspwmrc"
default_autostart="${__distro_path_root}/system_files/skel/.config/bspwm"

# At least try to ensure user has an autostart file.
[ -e "$usr_autostart" ] || {
	echo "$0: ERROR $usr_autostart does not exist, copying in $default_autostart" >&2
	cp -r "$default_autostart" "$usr_confdir"
}

exec /usr/bin/bspwm
