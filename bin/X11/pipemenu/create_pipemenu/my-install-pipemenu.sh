#!/bin/sh

installation_script_name="popup_terminal"

. "$__distro_path_lib"
. "${__distro_path_root}/lib/common/DB"
. "${__distro_path_root}/lib/common/pipemenu"
. "${__distro_path_root}/lib/common/my_installer_and_DB_dir"

X11_apps_2_remove="$(grep -rI "# X11 only package remove it from my-installer" "$_APPS_LIBDIR" | awk -F: '{print $1}' | xargs -n1 basename | tr '\n' '|' | sed 's/|$//')"
wayland_apps_2_remove="$(grep -rI "# wayland only package remove it from my-installer" "$_APPS_LIBDIR" | awk -F: '{print $1}' | xargs -n1 basename | tr '\n' '|' | sed 's/|$//')"

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
	for dir in *;do
		apps_dir_name=$(echo "$dir" | sed 's/_/ /')
		apps_in_dir="$(cat "$dir" 2>/dev/null)"
		[ -n "$apps_in_dir" ] && apps_in_dir="$(echo "$apps_in_dir" | grep -vE "$wayland_apps_2_remove" || echo "$apps_in_dir")"
		[ -n "$apps_in_dir" ] && generate_installmenu "$dir" "$apps_dir_name" "${apps_in_dir}"
	done
    menuEnd
} | my-superuser tee "${my_installer_pipemenu_X11_file}" >/dev/null 2>&1
