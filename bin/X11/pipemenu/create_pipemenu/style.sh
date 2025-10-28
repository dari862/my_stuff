#!/bin/sh
. "$__distro_path_lib"
. "${__distro_path_root}/lib/common/pipemenu"
. "${__distro_path_root}/lib/common/openbox"
. "${__distro_path_root}/lib/common/WM"

if [ "$(id -u)" -ne 0 ];then
	for _panel_name_ in polybar tint2;do
		dir="${__distro_path_root}/system_files/blob/${_panel_name_}"	
		styles="$(find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name "default" ! -name "dynamic" -exec basename {} \; | sort)"
		
		{
		count=1
		menuItem "Default" "${__distro_path_root}/bin/X11/WM/style_changer $_panel_name_ default"
		menuItem "Dynamic" "${__distro_path_root}/bin/X11/WM/style_changer $_panel_name_ dynamic"
		menuSeparator "| Simple |"
		for style in ${styles}; do
			better_style_name="$(echo "$styles" | tr '[:upper:]' '[:lower:]')"
			better_style_name="$(echo "$style" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"
			menuItem "${count}. ${better_style_name}" "${__distro_path_root}/bin/X11/WM/style_changer $_panel_name_ ${style}"
			count=$(($count+1))
		done
		menuSeparator "| Menus |"
		menuItem "Rofi" "RiceSelector"
		menuItem "yad" "style_picker"
		} > "${style_pipemenu_file}_${_panel_name_}"
		
		{
		count=1
		menuItem "Default" "${__distro_path_root}/bin/X11/WM/style_changer $_panel_name_ default"
		menuItem "Dynamic" "${__distro_path_root}/bin/X11/WM/style_changer $_panel_name_ dynamic"
		menuSeparator "| Simple |"
		for style in ${styles}; do
			better_style_name="$(echo "$styles" | tr '[:upper:]' '[:lower:]')"
			better_style_name="$(echo "$style" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"
			menuItem "${count}. ${better_style_name}" "${__distro_path_root}/bin/X11/WM/style_changer $_panel_name_ ${style}"
			count=$(($count+1))
		done
		menuSeparator "| Menus |"
		menuItem "Rofi" "RiceSelector"
		menuItem "yad" "style_picker"
		} > "${style_pipemenu_file}_${_panel_name_}"
	done
fi
