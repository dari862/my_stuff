#!/bin/sh

installation_script_name="popup_terminal"

. "/usr/share/my_stuff/lib/common/DB"

LIST_OF_APPS_SCRIPTS_="$(cd "${apps_db_path}" && ls 2>/dev/null)"

. "/usr/share/my_stuff/lib/common/pipemenu"
. "/usr/share/my_stuff/lib/common/my_installer_and_DB_dir"

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
        	for App in ${menu_content}; do
        		App_name=$(echo "${App}" | awk -F"_" '{print $1}')
                menuItem "Install ${App_name}" "${installation_script_name} --install ${App}"
        	done
        	menuSubmenuEnd
        fi
    }
	menuStart "installfavouritepackages" "Install Favourite Packages"
	cd "${apps_db_path}"
	for dir in ${LIST_OF_APPS_SCRIPTS_};do
		apps_dir_name=$(echo "$dir" | sed 's/_/ /')
		apps_in_dir="$(cat "$dir" 2>/dev/null)"
		[ -n "$apps_in_dir" ] && generate_installmenu "$dir" "$apps_dir_name" "${apps_in_dir}"
	done
    menuEnd
} | tee "${my_installer_pipemenu_file}" >/dev/null 2>&1
