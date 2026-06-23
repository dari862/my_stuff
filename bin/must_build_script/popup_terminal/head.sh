#!/bin/sh
# need superuser : use my-superuser
#===================================================================================
. "$__distro_path_lib"
my_installer_script_name="${__distro_path_installers_and_tweaks}/my-installer"
my_tweaker_script_name="${__distro_path_installers_and_tweaks}/my-tweaker"
fullscreen_mode=""
Title=""

arg_="${1-}"

if [ "${arg_}" = "--geometry" ];then
	Title="${2-}"
	geometry="${3-}"
	shift 3
else
	shift 1
fi

file_name_="$@"
if [ -z "${file_name_}" ];then
	file_name_="${arg_}"
	arg_="st"
fi

