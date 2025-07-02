my_stuff_display_manager_lib_path="/usr/share/my_stuff/display_server/X11"
usr_autostart="$usr_confdir/openbox/autostart"
usr_envfile="$usr_confdir/openbox/environment"
default_autostart="${OBPATH_SKEL}"

# include my_stuff/bin/openbox in PATH
if [ -d "/usr/share/my_stuff/bin/openbox" ];then
   	PATH="/usr/share/my_stuff/bin/openbox:$PATH"
fi
	
if [ -d "/usr/share/my_stuff/bin/pipemenu" ];then
   	PATH="/usr/share/my_stuff/bin/pipemenu:$PATH"
fi

if [ -d "/usr/share/my_stuff/system_files/binX11" ];then
	PATH="/usr/share/my_stuff/system_files/binX11:$PATH"
else
	echo "ERROR: /usr/share/my_stuff/system_files/bin Does not exist."
fi

# Clean up after GDM (GDM sets the number of desktops to one).
xprop -root -remove _NET_NUMBER_OF_DESKTOPS \
	-remove _NET_DESKTOP_NAMES \
	-remove _NET_CURRENT_DESKTOP 2> /dev/null

# At least try to ensure user has an autostart file.
[ -e "$usr_autostart" ] || {
	echo "$0: ERROR $usr_autostart does not exist, copying in $default_autostart" >&2
	cp -r "$default_autostart" "$usr_confdir"
}

# Set up the specific environment.
test -r "$usr_envfile" && . "$usr_envfile" || echo "$0: cannot source $usr_envfile" >&2

# Run Openbox, and have it run the autostart stuff
exec /usr/bin/openbox --config-file "${usr_confdir}/openbox/rc.xml" --startup "/usr/share/my_stuff/lib/xsessions/openbox_files/openbox-autostart OPENBOX" "$@"	
