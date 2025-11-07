#!/bin/sh
. "${__distro_display_manager_lib_path}"
sleep 2
if [ "$Display_server_are" = "X11" ];then
	bash (((__distro_path_root)))/bin/X11/yad/welcome
elif [ "$Display_server_are" = "wayland" ];then
	bash (((__distro_path_root)))/bin/wayland/welcome
fi
