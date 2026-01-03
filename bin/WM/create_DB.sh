#!/bin/sh
# need superuser : var (_SUPERUSER)
set -e

# Default to empty string if no option is provided
opt="${1-}"

if [ "$(id -u)" -eq 0 ];then
	_SUPERUSER=""
else
	_SUPERUSER="my-superuser"
fi
# Import necessary libraries
. "$__distro_path_lib"
. "${__distro_path_root}/lib/common/WM"
. "${__distro_path_root}/lib/common/DB"
. "${__distro_path_root}/lib/common/openbox"
. "${__distro_path_root}/lib/common/my_installer_and_DB_dir"
. "${__distro_path_root}/lib/common/common"
. "${__distro_path_root}/Distro_Specific/Package-manager.sh"

# Helper function to check if a command is installed
is_installed() {
	command -v "$1" >/dev/null 2>&1 || dpkg -s "$1" >/dev/null 2>&1
}

# Helper function to create a database from directories
create_db_from_dirs() {
	dirs="${1:-}"
	dirs2="${2:-}"
	db_path="${3:-}"
	
	if [ -z "$dirs" ] || [ -z "$db_path" ];then
		exit 1
	fi

	if [ -z "$4" ];then
		remove_this=""
	else
		remove_this="! -name $4"
	fi

	[ -d "$db_path" ] && rm -rdf "$db_path"
	$_SUPERUSER mkdir -p "$db_path"
	if [ -n "$dirs2" ];then
		find "${dirs}" "${dirs2}" -mindepth 1 -maxdepth 1 -type d $remove_this | while read -r d;do
			dir_name=$(basename "$d")
			
			$_SUPERUSER touch "${db_path}/$dir_name"
		
			find "${d}" -mindepth 1 -maxdepth 1 -type f | while read -r app;do
				if ! is_installed "$(basename "$app")" && ! grep -q "#hide_it#" "$app";then
					basename "$app" | $_SUPERUSER tee -a "$db_path/$dir_name" >/dev/null 2>&1
				fi
			done
		done
	else
		find "${dirs}" -mindepth 1 -maxdepth 1 -type d $remove_this | while read -r d;do
			dir_name=$(basename "$d")
			
			$_SUPERUSER touch "${db_path}/$dir_name"
		
			find "${d}" -mindepth 1 -maxdepth 1 -type f | while read -r app;do
				if ! is_installed "$(basename "$app")" && ! grep -q "#hide_it#" "$app";then
					basename "$app" | $_SUPERUSER tee -a "$db_path/$dir_name" >/dev/null 2>&1
				fi
			done
		done
	fi
}

# Create apps and gaming database
create_apps_db() {
	say "create DB for apps."
	create_db_from_dirs "${_APPS_LIBDIR}" "${_APPS_EXTRA_LIBDIR}" "${apps_db_path}" "Gaming"
}

create_gaming_db() {
	say "create DB for gaming."
	create_db_from_dirs "${_GAMING_EXTRA_LIBDIR}" "" "${gaming_db_path}"
}

create_tweeks_db() {
	say "create DB for tweeks."
	
	check_tweek=true
	
	[ -f "${tweeks_db_path}" ] && $_SUPERUSER rm -rf "${tweeks_db_path}"
	$_SUPERUSER touch "${tweeks_db_path}"

	find "${_TWEEKS_LIBDIR}" "${_TWEEKS_EXTRA_LIBDIR}" -mindepth 1 -maxdepth 1 -type f | while read -r tweek;do
		tweek_enabled=false
		tweek_basename="$(basename "$tweek")"
		. "${tweek}"
		if [ "$tweek_enabled" = false ];then
			echo "$tweek_basename" | $_SUPERUSER tee -a "${tweeks_db_path}" >/dev/null 2>&1
		else
			echo "$tweek_basename are enabled." 
		fi
	done
}

create_full_environment_db() {
	say "create DB for full_environment."

	[ -f "${full_environment_db_path}" ] && $_SUPERUSER rm -rf "${full_environment_db_path}"
	$_SUPERUSER touch "${full_environment_db_path}"
	
	find "${_FULL_ENVIRONMENT_LIBDIR}" "${_FULL_ENVIRONMENT_EXTRA_LIBDIR}" -mindepth 1 -maxdepth 1 -type f | while read -r FE;do
		basename "$FE" | $_SUPERUSER tee -a "${full_environment_db_path}" >/dev/null 2>&1
	done
}

# Create distrobox deploy database
create_distrobox_deploy_db() {
	say "create DB for distrobox."
	list_of_deploys=$(find "${_DISTROBOX_LIBDIR}" -mindepth 1 -maxdepth 1 -type f -exec basename {} \;)

	if [ -f "${__distro_path_system_ready}/Distrobox_ready" ];then
		for deploy in $list_of_deploys; do
			if ! distrobox list | grep -q " ${deploy} ";then
				echo "$deploy" | $_SUPERUSER tee -a "${distrobox_deploy_db_path}" >/dev/null 2>&1
			fi
		done
	else
		for deploy in $list_of_deploys; do
			echo "$deploy" | $_SUPERUSER tee -a "${distrobox_deploy_db_path}" >/dev/null 2>&1
		done
	fi
}

# Create containers deploy database
create_containers_deploy_db() {
	say "create DB for containers."
	list_of_containers=$(find "${_CONTAINERS_LIBDIR}" -mindepth 1 -maxdepth 1 -type f -exec basename {} \;)

	if [ -L "${__distro_path_root}/system_files/bin/CONTAINER_RT" ];then
		for container in $list_of_containers; do
			if [ ! -f "${_DEPLOYED_CONTAINERS_LIBDIR}/${container}" ];then
				echo "$container" | $_SUPERUSER tee -a "${containers_deploy_db_path}" >/dev/null 2>&1
			fi
		done
	else
		for container in $list_of_containers; do
			echo "$container" | $_SUPERUSER tee -a "${containers_deploy_db_path}" >/dev/null 2>&1
		done
	fi
}

# Create chroots deploy database
create_chroots_deploy_db() {
	say "create DB for chroots."
	list_of_chroots=$(find "${_CHROOTS_LIBDIR}" -mindepth 1 -maxdepth 1 -type f -exec basename {} \;)
	if [ -d "${ROOT_CHROOT_DIR}" ];then
		for chroot in $list_of_chroots; do
			if [ ! -f "${_CHROOTS_INSTALLED_LIBDIR}/${chroot}" ];then
				echo "$chroot" | $_SUPERUSER tee -a "${chroots_deploy_db_path}" >/dev/null 2>&1
			fi
		done
	else
		for chroot in $list_of_chroots; do
			echo "$chroot" | $_SUPERUSER tee -a "${chroots_deploy_db_path}" >/dev/null 2>&1
		done
	fi
}

# Create all databases except the styles database
create_all_db_except_style_db() {
	$_SUPERUSER mkdir -p "${db_dir}"

	[ ! -f "${tweeks_db_path}" ] && create_tweeks_db
	[ ! -f "${full_environment_db_path}" ] && create_full_environment_db
	[ ! -d "${apps_db_path}" ] && create_apps_db
	[ ! -d "${gaming_db_path}" ] && create_gaming_db
	[ ! -f "${distrobox_deploy_db_path}" ] && create_distrobox_deploy_db
	[ ! -f "${containers_deploy_db_path}" ] && create_containers_deploy_db
	[ ! -f "${chroots_deploy_db_path}" ] && create_chroots_deploy_db
	check_4_envycontrol
	create_pipemenu
	say "DBs creation completed"
}

remove_from_DB() {
	:
}

check_4_envycontrol() {
	lspci_output=$(lspci | grep -i 'vga')
		
	if echo "$lspci_output" | grep -iq VMware;then
		number_of_gpus=1
	else
		number_of_gpus=0
		if echo "$lspci_output" | grep -iq nvidia;then
			number_of_gpus=$((number_of_gpus + 1))
		fi
		
		if echo "$lspci_output" | grep -iq intel;then
			number_of_gpus=$((number_of_gpus + 1))
		fi
		
		if echo "$lspci_output" | grep -iq amd;then
			number_of_gpus=$((number_of_gpus + 1))
		fi
	fi
	
	if [ "$number_of_gpus" -le 1 ] && grep -rq "envycontrol" "${db_dir}";then
		say "number of gpus = $number_of_gpus removing envycontrol from DB."
		$_SUPERUSER find "${db_dir}" -type f -exec sed -i "/^envycontrol$/d" {} +
	else
		say "number of gpus = $number_of_gpus keeping envycontrol in DB."
		
	fi
}

create_pipemenu(){
	say "Running script for creating preferences pipemenu."
	. "${pipemenu_creater}"/preferences.sh || failed_to_run "failed to run create_pipemenu/preferences.sh"
	
	say "Running script for creating full_environment pipemenu."
	. "${pipemenu_creater}"/full_environment-pipemenu.sh || failed_to_run "failed to run create_pipemenu/full_environment-pipemenu.sh"
	
	say "Running script for creating preferences pipemenu."
	. "${pipemenu_creater}"/my-tweeks-pipemenu.sh || failed_to_run "failed to run create_pipemenu/my-tweeks-pipemenu.sh"
	
	say "Running script for creating install pipemenu."
	. "${pipemenu_creater}"/my-install-pipemenu.sh|| failed_to_run "failed to run create_pipemenu/my-install-pipemenu.sh"
	
	say "Running script for creating gaming pipemenu."
	. "${pipemenu_creater}"/gaming-pipemenu.sh || failed_to_run "failed to run create_pipemenu/gaming-pipemenu.sh"
	
	say "Running script for creating containers and others pipemenu."
	. "${pipemenu_creater}"/containers-deployer-pipemenu.sh || failed_to_run "failed to run create_pipemenu/containers-deployer-pipemenu.sh"
}

# Case statement to trigger the appropriate function
case "$opt" in
	--tweeks) create_tweeks_db ;;
	--fullenv) create_full_environment_db ;;
	--apps) create_apps_db ;;
	--games) create_gaming_db ;;
	--deploy) create_distrobox_deploy_db ;;
	--containers) create_containers_deploy_db ;;
	--chroots) create_chroots_deploy_db ;;
	--all) create_all_db_except_style_db ;;
	--remove) remove_from_DB ;;
	*) echo "Invalid option"; exit 1 ;;
esac
