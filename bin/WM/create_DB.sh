#!/bin/sh
set -e

# Default to empty string if no option is provided
opt="${1-}"

# Import necessary libraries
. "/usr/share/my_stuff/lib/common/WM"
. "/usr/share/my_stuff/lib/common/DB"
. "/usr/share/my_stuff/lib/common/openbox"
. "/usr/share/my_stuff/lib/common/my_installer_and_DB_dir"

# Helper function to check if a command is installed
is_installed() {
  command -v "$1" >/dev/null 2>&1 || dpkg -s "$1" >/dev/null 2>&1
}

# Helper function to create a database from directories
create_db_from_dirs() {
  dir="$1"
  db_path="$2"
  remove_this="$3"	
  # Ensure db_path exists
  mkdir -p "$db_path"

  # Iterate over subdirectories in the specified directory
	for d in "$dir"/*/; do
    	# Extract the base name of the directory (e.g., last part of the path)
    	dir_name=$(basename "$d")
	
    	# If the corresponding file already exists in the db_path, remove it
    	if [ -f "${db_path}/$dir_name" ];then
      		rm "${db_path}/$dir_name"
    	fi
	
    	# Create the db file for the directory
    	touch "${db_path}/$dir_name"
	
    	# Iterate over the files in the subdirectory (ignoring directories)
    	for app in "$d"/*; do
      		if [ -f "$app" ] && ! is_installed "$(basename "$app")";then
        		echo "$(basename "$app")" >> "$db_path/$dir_name"
      		fi
    	done
    	[ ! -s "$db_path/$dir_name" ] && rm -f "$db_path/$dir_name"
	done
	if [ -n "$remove_this" ];then
		for d in $remove_this; do
			rm -rdf "${db_path}/$d"
		done
	fi
}

# Create the Tweeks database
create_tweeks_db() {
  # Check if _TWEEKS_LIBDIR is valid and not empty
  if [ -z "$(ls -A "${_TWEEKS_LIBDIR}")" ];then
    rm -rdf "${_TWEEKS_LIBDIR}"
  fi
  
  if [ ! -d "${_TWEEKS_LIBDIR}" ];then
    mkdir -p "${_TWEEKS_LIBDIR}"
  fi
  
  # Loop over files in _TWEEKS_LIBDIR
  for tweek in "${_TWEEKS_LIBDIR}"/*; do
    # Skip if it's not a file (can be a subdirectory or something else)
    if [ -f "$tweek" ];then
      # Check if the tweek is not enabled
      if ! ${tweek} --is-enable;then
        echo "$(basename "$tweek")" >> "${tweeks_db_path}"
      fi
    fi
  done
}

# Create apps and gaming database
create_apps_db_and_gaming_db() {
  create_db_from_dirs "${_APPS_LIBDIR}" "${apps_db_path}" "Gaming"
  create_db_from_dirs "${_APPS_LIBDIR}/Gaming" "${gaming_db_path}"
}

# Create distrobox deploy database
create_distrobox_deploy_db() {
  cd "${_DISTROBOX_LIBDIR}"
  list_of_deploys=$(find . -maxdepth 1 -type f -exec basename {} \;)

  if [ -f '/usr/share/my_stuff/system_files/Distrobox_ready' ];then
    for deploy in $list_of_deploys; do
      if ! distrobox list | grep -q " ${deploy} ";then
        echo "$deploy" >> "${distrobox_deploy_db_path}"
      fi
    done
  else
    for deploy in $list_of_deploys; do
      echo "$deploy" >> "${distrobox_deploy_db_path}"
    done
  fi
}

# Create containers deploy database
create_containers_deploy_db() {
  cd "${_CONTAINERS_LIBDIR}"
  list_of_containers=$(find . -maxdepth 1 -type f -exec basename {} \;)

  if [ -f '/usr/share/my_stuff/system_files/bin/CONTAINER_RT' ];then
    for container in $list_of_containers; do
      if [ ! -f "${_DEPLOYED_CONTAINERS_LIBDIR}/${container}" ];then
        echo "$container" >> "${containers_deploy_db_path}"
      fi
    done
  else
    for container in $list_of_containers; do
      echo "$container" >> "${containers_deploy_db_path}"
    done
  fi
}

# Create chroots deploy database
create_chroots_deploy_db() {
  list_of_chroots=$(find "${_CHROOTS_LIBDIR}" -maxdepth 1 -type f -exec basename {} \;)
  if [ -d "${ROOT_CHROOT_DIR}" ];then
    for chroot in $list_of_chroots; do
      if [ ! -f "${_CHROOTS_INSTALLED_LIBDIR}/${chroot}" ];then
        echo "$chroot" >> "${chroots_deploy_db_path}"
      fi
    done
  else
    for chroot in $list_of_chroots; do
      echo "$chroot" >> "${chroots_deploy_db_path}"
    done
  fi
}

# Create the FULL ENVIRONMENT database
create_full_environment_db() {
  # Check if _FULL_ENVIRONMENT_LIBDIR is not valid or empty
  if [ -z "$(ls -A "${_FULL_ENVIRONMENT_LIBDIR}")" ];then
    rm -rdf "${_FULL_ENVIRONMENT_LIBDIR}"
  fi
  
  if [ ! -d "${_FULL_ENVIRONMENT_LIBDIR}" ];then
    mkdir -p "${_FULL_ENVIRONMENT_LIBDIR}"
  fi
  
  # Loop over files in _FULL_ENVIRONMENT_LIBDIR
  for FE in "${_FULL_ENVIRONMENT_LIBDIR}"/*; do
    # Skip if it's not a file (can be a subdirectory or something else)
    if [ -f "$FE" ];then
      echo "$(basename "$FE")" >> "${full_environment_db_path}"
    fi
  done
}

# Create styles database
create_styles_db() {
	. "/usr/share/my_stuff/lib/common/panel"
	. "/usr/share/my_stuff/lib/common/openbox"

	if [ "$_panel_name_" = 'polybar' ];then
		dir="/usr/share/my_stuff/system_files/blob/polybar"
	else
		dir="/usr/share/my_stuff/system_files/blob/tint2"
	fi

	find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name "default" -exec basename {} \; | sort > "$styles_db_path"
}

# Create all databases except the styles database
create_all_db_except_style_db() {
  mkdir -p "${db_dir}"

  [ ! -f "${tweeks_db_path}" ] && create_tweeks_db
  [ ! -f "${full_environment_db_path}" ] && create_full_environment_db
  [ ! -f "${apps_db_path}" ] && create_apps_db_and_gaming_db
  [ ! -f "${distrobox_deploy_db_path}" ] && create_distrobox_deploy_db
  [ ! -f "${containers_deploy_db_path}" ] && create_containers_deploy_db
  [ ! -f "${chroots_deploy_db_path}" ] && create_chroots_deploy_db
}

# Case statement to trigger the appropriate function
case "$opt" in
  --tweeks) create_tweeks_db ;;
  --fullenv) create_full_environment_db ;;
  --apps) create_apps_db_and_gaming_db ;;
  --deploy) create_distrobox_deploy_db ;;
  --containers) create_containers_deploy_db ;;
  --chroots) create_chroots_deploy_db ;;
  --styles) create_styles_db ;;
  --all) create_all_db_except_style_db ;;
  *) echo "Invalid option"; exit 1 ;;
esac
