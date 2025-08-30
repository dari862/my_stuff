#!/bin/sh
. "/usr/share/my_stuff/lib/common/Distro_path"
installation_script_name="popup_terminal"

. "${__distro_path_root}/lib/common/DB"

picked_gaming_db_path="${gaming_db_path}"
LIST_OF_GAMES_SCRIPTS_="$(cd "${picked_gaming_db_path}" && ls 2>/dev/null)"

. "${__distro_path_root}/lib/common/pipemenu"
. "${__distro_path_root}/lib/common/my_installer_and_DB_dir"

{
	# This function is specific to this script.
    # It generates an install submenu for a group of packages.
    # Usage: generate_installmenu tag label list (of packages)
    generate_installmenu() {
        tag=$1
        label=$2
        menu_content="$3"
        if [ -n "${tag}" ] && [ -n "${label}" ];then
        	menuSubmenu "$tag" "$label"
        	for game in ${menu_content}; do
        		Game_name=$(echo "${game}" | awk -F"_" '{print $1}')
                menuItem "Install ${Game_name}" "${installation_script_name} --game ${game}"
        	done
        	menuSubmenuEnd
        fi
    }
    menuStart
	if [ ! -f "${__distro_path_root}/system_files/Gaming_ready" ];then
		if [ ! -f "${__distro_path_root}/system_files/GPU_Drivers_ready" ];then
			menuItem "GPU Driver (GamingEss after install)" "${installation_script_name} --install GPU"
		else
			menuItem "Gaming Essential (GamingMenu after install)" "${installation_script_name} --game Gaming_Essential_"
		fi
	else
		cd "${picked_gaming_db_path}"
		for gd in ${LIST_OF_GAMES_SCRIPTS_};do
			Gaming_dir_name=$(echo "$gd" | sed 's/_/ /')
			Gaming_in_dir="$(cat "$gd" 2>/dev/null)"
			[ -n "$Gaming_in_dir" ] && generate_installmenu "$gd" "$Gaming_dir_name" "${Gaming_in_dir}"
		done
	fi
    menuEnd
} | tee "${gaming_pipemenu_file}" >/dev/null 2>&1
