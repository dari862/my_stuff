#!/bin/sh
. "/usr/share/my_stuff/lib/common/pipemenu"
. "/usr/share/my_stuff/lib/common/openbox"
. "/usr/share/my_stuff/lib/common/WM"
. "${Distro_config_file}"

if [ "$_panel_name_" = 'polybar' ];then
	dir="/usr/share/my_stuff/system_files/blob/polybar"
else
	dir="/usr/share/my_stuff/system_files/blob/tint2"
fi

styles="$(find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name "default" ! -name "dynamic" -exec basename {} \; | sort)"

{
count=1
menuItem "Default" "style_changer default"
menuItem "Dynamic" "style_changer dynamic"
menuSeparator "| Simple |"
for style in ${styles}; do
	better_style_name="$(echo "$styles" | tr '[:upper:]' '[:lower:]')"
	better_style_name="$(echo "$style" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"
	menuItem "${count}. ${better_style_name}" "style_changer ${style}"
	count=$(($count+1))
done
} > "${style_pipemenu_file}"
