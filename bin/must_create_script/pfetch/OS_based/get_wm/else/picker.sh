get_wm() {
	. "${__distro_display_manager_lib_path}"
	# Don't display window manager if X isn't running.
	[ "$DISPLAY" ] || return
	if [ "$Display_server_are" = "X11" ];then
		get_wm_X11
	elif [ "$Display_server_are" = "wayland" ];then
		get_wm_wayland
	fi
	
	log wm "$wm" >&6
}
