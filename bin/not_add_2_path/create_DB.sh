#!/bin/bash
set -e
opt="${1-}"
source "/usr/share/DmDmDmdMdMdM/lib/common/DB"

_SCRIPTS_LIBDIR="/usr/share/DmDmDmdMdMdM/bin/not_add_2_path/apps_center"
_DISTROBOX_SCRIPTS_LIBDIR="/usr/share/DmDmDmdMdMdM/bin/not_add_2_path/distrobox_center"
_CONTAINERS_SCRIPTS_LIBDIR="/usr/share/DmDmDmdMdMdM/bin/not_add_2_path/containers_center"

create_tweeks_db(){
	_TWEEKS_DIR="/usr/share/DmDmDmdMdMdM/bin/not_add_2_path/tweeks_center"
	LS_TWEEKS=($(ls ${_TWEEKS_DIR}))
	for tweek in "${LS_TWEEKS[@]}"; do
		[[ "$(${_TWEEKS_DIR}/${tweek} --check)" != "enabled" ]] && echo "${tweek}" >> "${tweeks_db_path}"
	done
}

create_apps_db_and_gaming_db(){
	GAMING_SCRIPTS_Dir_Name="Gaming"
	create_apps_db(){
		cd "${_SCRIPTS_LIBDIR}"
		LIST_OF_APPS_SCRIPTS_=($(ls | grep -v "${GAMING_SCRIPTS_Dir_Name}" ))
		if ((${#LIST_OF_APPS_SCRIPTS_[@]} > 0));then
			mkdir -p "${apps_db_path}"
			for d in "${LIST_OF_APPS_SCRIPTS_[@]}";do
				if [ -d "$d" ];then
					[ -f "${apps_db_path}/$d" ] && rm "${apps_db_path}/$d"
					cd "$d"
					for app in *;do
						if ! hash "${app}" 2>/dev/null && ! dpkg -s "${app}" &>/dev/null;then
							app_name2=$(echo "$app" | awk -F_ '{print $1}')
							if ! hash "${app_name2}" 2>/dev/null && ! dpkg -s "${app_name2}" &>/dev/null;then
								if grep 'app_name=\$' "${app}" &>/dev/null;then
									app_name3="${app}"
								else
									if grep 'app_name="' "${app}" &>/dev/null;then
										app_name3="$(grep 'app_name="' "${app}" | awk -F'"' '{print $2}')"
									elif grep 'app_name=(' "${app}" &>/dev/null;then
										tempapps=($(grep 'app_name=(' "${app}" | awk -F'(' '{print $2}' | sed 's/)//'))
										for tempapp in "${tempapps[@]}";do
											app_name3="${tempapp}"
											if ! hash "${tempapp}" 2>/dev/null && ! dpkg -s "${tempapp}" &>/dev/null;then
												break
											fi
										done
									fi
								fi
								if ! hash "${app_name3}" 2>/dev/null && ! dpkg -s "${app_name3}" &>/dev/null;then
									echo "${app}" >> "${apps_db_path}/$d"
								fi
							fi
						fi
					done
					cd ..
				fi
			done
		fi
	}
	create_gaming_db(){
		cd "${_SCRIPTS_LIBDIR}"/"${GAMING_SCRIPTS_Dir_Name}"
		LIST_OF_GAMING_SCRIPTS_=($(ls))
		if ((${#LIST_OF_GAMING_SCRIPTS_[@]} > 0));then
			mkdir -p "${gaming_db_path}"
			for d in "${LIST_OF_GAMING_SCRIPTS_[@]}";do
				if [ -d "$d" ];then
					[ -f "${gaming_db_path}/$d" ] && rm "${gaming_db_path}/$d"
					cd "$d"
					for Gapp in *;do
						if ! hash "${Gapp}" 2>/dev/null && ! dpkg -s "${Gapp}" &>/dev/null;then
							gapp_name2=$(echo "$Gapp" | awk -F_ '{print $1}')
							if ! hash "${gapp_name2}" 2>/dev/null && ! dpkg -s "${gapp_name2}" &>/dev/null;then
								if grep 'app_name=\$' "${Gapp}" &>/dev/null;then
									gapp_name3="${Gapp}"
								else
									if grep 'app_name="' "${Gapp}" &>/dev/null;then
										gapp_name3="$(grep 'app_name="' "${Gapp}" | awk -F'"' '{print $2}')"
									elif grep 'app_name=(' "${app}" &>/dev/null;then
										tempapps=($(grep 'app_name=(' "${Gapp}" | awk -F'(' '{print $2}' | sed 's/)//'))
										for tempapp in "${tempapps[@]}";do
											gapp_name3="${tempapp}"
											if ! hash "${tempapp}" 2>/dev/null && ! dpkg -s "${tempapp}" &>/dev/null;then
												break
											fi
										done
									fi
								fi
								if ! hash "${gapp_name3}" 2>/dev/null && ! dpkg -s "${gapp_name3}" &>/dev/null;then
									echo "${Gapp}" >> "${gaming_db_path}/$d"
								fi
							fi
						fi
					done
					cd ..
				fi
			done
		fi
	}
	create_apps_db
	create_gaming_db
}

create_distrobox_deploy_db(){
	_DISTROBOX_DEPLOY_SCRIPTS_Dir_Name="deploy"
	cd "${_DISTROBOX_SCRIPTS_LIBDIR}"/"${_DISTROBOX_DEPLOY_SCRIPTS_Dir_Name}"
	DISTROBOX_LIST_OF_DEPLOYS_SCRIPTS_=($(ls | grep -v "gaming"))
	for deploy in "${DISTROBOX_LIST_OF_DEPLOYS_SCRIPTS_[@]}"; do
		if [[ "$(my-installer --chech-distrobox)" = "ready" ]];then
			[[ "$(my-installer --deploy-check "${deploy}")" != "true" ]] && echo "${deploy}" >> "${distrobox_deploy_db_path}"
		else
			echo "${deploy}" >> "${distrobox_deploy_db_path}"
		fi
	done
}

create_distrobox_gaming_db_and_distrobox_apps_db(){
	_DISTROBOX_APPS_SCRIPTS_Dir_Name="Apps"
	_DISTROBOX_GAMING_SCRIPTS_Dir_Name="Gaming"
	
	create_distrobox_apps_db(){
		cd "${_DISTROBOX_SCRIPTS_LIBDIR}"/"${_DISTROBOX_APPS_SCRIPTS_Dir_Name}"
		DISTROBOX_LIST_OF_APPS_SCRIPTS_=($(ls))
		if ((${#DISTROBOX_LIST_OF_APPS_SCRIPTS_[@]} > 0));then
			mkdir -p "${distrobox_apps_db_path}"
			for d in "${DISTROBOX_LIST_OF_APPS_SCRIPTS_[@]}";do
				if [ -d "$d" ];then
					[ -f "${distrobox_apps_db_path}/$d" ] && rm "${distrobox_apps_db_path}/$d"
					cd "$d"
					for app in *;do
						echo "${app}" >> "${distrobox_apps_db_path}/$d"
					done
					cd ..
				fi
			done
		fi
	}
	
	create_distrobox_gaming_db(){
		cd "${_DISTROBOX_SCRIPTS_LIBDIR}"/"${_DISTROBOX_GAMING_SCRIPTS_Dir_Name}"
		DISTROBOX_LIST_OF_GAMING_SCRIPTS_=($(ls))
		if ((${#DISTROBOX_LIST_OF_GAMING_SCRIPTS_[@]} > 0));then
			mkdir -p "${distrobox_gaming_db_path}"
			for d in "${DISTROBOX_LIST_OF_GAMING_SCRIPTS_[@]}";do
				if [ -d "$d" ];then
					[ -f "${distrobox_gaming_db_path}/$d" ] && rm "${distrobox_gaming_db_path}/$d"
					cd "$d"
					for Gapp in *;do
						echo "${Gapp}" >> "${distrobox_gaming_db_path}/$d"
					done
					cd ..
				fi
			done
		fi
	}
	#create_distrobox_apps_db
	create_distrobox_gaming_db
}

create_containers_deploy_db(){
	_CONTAINERS_DEPLOY_SCRIPTS_Dir_Name="deploy"
	cd "${_CONTAINERS_SCRIPTS_LIBDIR}"/"${_CONTAINERS_DEPLOY_SCRIPTS_Dir_Name}"
	CONTAINERS_LIST_OF_DEPLOYS_SCRIPTS_=($(ls || :))
	for container in "${CONTAINERS_LIST_OF_DEPLOYS_SCRIPTS_[@]}"; do
		if [[ "$(my-installer --chech-container-software)" = "ready" ]];then
			[[ "$(my-installer --container-check "${container}")" != "true" ]] && echo "${container}" >> "${containers_deploy_db_path}"
		else
			echo "${container}" >> "${containers_deploy_db_path}"
		fi
	done
}

create_styles_db(){
	source "/usr/share/DmDmDmdMdMdM/lib/common/panel"
	source "/usr/share/DmDmDmdMdMdM/lib/common/openbox"
	
	rc_file_name="$(cat "${OBPATH}/rc_name")"
	# Dir
	if [ "$rc_file_name" == "DmDmDmdMdMdM_rc.xml" ] || [ "$_panel_name_" == "polybar" ]; then
		dir="/usr/share/DmDmDmdMdMdM/blob/polybar"
	else
		dir="/usr/share/DmDmDmdMdMdM/blob/tint2"
	fi

	cd $dir && ls -d */ 2>/dev/null | cut -f1 -d'/' | grep -v "Default" | grep -v "*-Bitmap" > "${styles_db_path}"
	cd $dir && ls -d *-Bitmap/ 2>/dev/null | cut -f1 -d'/' > "${bit_styles_db_path}"
}

create_all_db_execpt_style_db(){
	mkdir -p "${db_dir}"
	
	if [ ! -f "${tweeks_db_path}" ] ; then
		create_tweeks_db
	fi 
		
	if [ ! -f "${apps_db_path}" ] ; then
		create_apps_db_and_gaming_db
	fi 
	
	if [ ! -f "${distrobox_deploy_db_path}" ] ; then
		create_distrobox_deploy_db
	fi
	
	if [ ! -f "${containers_deploy_db_path}" ] ; then
		create_containers_deploy_db
	fi
	
	if [ ! -f "${distrobox_gaming_db_path}" ] ; then
		create_distrobox_gaming_db_and_distrobox_apps_db
	fi 
}

case $opt in
		--tweeks) create_tweeks_db ;;
		--apps) create_apps_db_and_gaming_db ;;
		--deploy) create_distrobox_deploy_db ;;
		--containers) create_containers_deploy_db ;;
		--distrobox-apps) create_distrobox_gaming_db_and_distrobox_apps_db ;;
		--styles) create_styles_db ;;
		--all) create_all_db_execpt_style_db ;;
		*) : ;;
esac
