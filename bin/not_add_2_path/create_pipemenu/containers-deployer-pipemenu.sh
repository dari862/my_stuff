#!/bin/sh

installation_script_name="popup_terminal"

. "/usr/share/my_stuff/lib/common/DB"
. "/usr/share/my_stuff/lib/common/my_installer_and_DB_dir"

DEPLOYS="$(cat "${distrobox_deploy_db_path}")"
CONTAINERS="$(cat "${containers_deploy_db_path}")"
CHROOTS="$(cat "${chroots_deploy_db_path}")"

. "/usr/share/my_stuff/lib/common/pipemenu"

{
	menuStart "DeployFavouriteContainers" "Deploy containers using Distrobox and Containers softwares"
	if [ ! -f "/usr/share/my_stuff/system_files/Gaming_ready" ];then
		if [ ! -f "/usr/share/my_stuff/system_files/GPU_Drivers_ready" ];then
			menuItem "GPU Driver (GamingEss after install)" "${installation_script_name} --install GPU"
		else
			menuItem "Gaming Box" "${installation_script_name} --deploy gaming"
		fi
	fi
	
	if [ -n "${DEPLOYS}" ];then
		menuSeparator "Distrobox to Deploy."
		for deploy in ${DEPLOYS}; do
   			menuItem "${deploy} Box" "${installation_script_name} --deploy ${deploy}"
		done
	fi
	
	if [ -n "${CONTAINERS}" ];then
		menuSeparator "Containers to Deploy."
		for container in ${CONTAINERS}; do
   			menuItem "${container} container" "${installation_script_name} --container ${container}"
		done
	fi
	
	if [ -n "${CHROOTS}" ];then
		menuSeparator "Chroots to Deploy."
		for chroot in ${CHROOTS}; do
   			menuItem "${chroot} Chroot" "${installation_script_name} --chroot ${chroot}"
		done
	fi
	
    menuEnd
} | tee "${containers_deployer_pipemenu_file}" >/dev/null 2>&1
