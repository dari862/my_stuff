#!/bin/bash
set -e
opt="${1-}"
source "/usr/share/my_stuff/lib/common/WM"
source "/usr/share/my_stuff/lib/common/DB"
source "/usr/share/my_stuff/lib/common/openbox"

_SCRIPTS_LIBDIR="/usr/share/my_stuff/bin/not_add_2_path/apps_center"
_DISTROBOX_SCRIPTS_LIBDIR="/usr/share/my_stuff/bin/not_add_2_path/distrobox_center"
_CONTAINERS_SCRIPTS_LIBDIR="/usr/share/my_stuff/bin/not_add_2_path/containers_center"

create_tweeks_db(){
	_TWEEKS_DIR="/usr/share/my_stuff/bin/not_add_2_path/tweeks_center"
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
								if grep -q 'app_name=\$' "${app}";then
									app_name3="${app}"
								else
									if grep -q 'app_name="' "${app}";then
										app_name3="$(grep 'app_name="' "${app}" | awk -F'"' '{print $2}')"
									elif grep -q 'app_name=(' "${app}";then
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
								if grep -q 'app_name=\$' "${Gapp}";then
									gapp_name3="${Gapp}"
								else
									if grep -q 'app_name="' "${Gapp}";then
										gapp_name3="$(grep 'app_name="' "${Gapp}" | awk -F'"' '{print $2}')"
									elif grep -q 'app_name=(' "${app}";then
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
	cd "${_DISTROBOX_SCRIPTS_LIBDIR}"
	DISTROBOX_LIST_OF_DEPLOYS_SCRIPTS_=($(ls -p | grep -v / || :))
	if [ -f '/usr/share/my_stuff/system_files/Distrobox_ready' ];then
		for deploy in "${DISTROBOX_LIST_OF_DEPLOYS_SCRIPTS_[@]}"; do
			[[ "$(distrobox list | grep " ${deploy} " && echo true)" != "true" ]] && echo "${deploy}" >> "${distrobox_deploy_db_path}"
		done
	else
		for deploy in "${DISTROBOX_LIST_OF_DEPLOYS_SCRIPTS_[@]}"; do
			echo "${deploy}" >> "${distrobox_deploy_db_path}"
		done
	fi
}

create_containers_deploy_db(){
	cd "${_CONTAINERS_SCRIPTS_LIBDIR}"
	CONTAINERS_LIST_OF_DEPLOYS_SCRIPTS_=($(ls -p | grep -v / || :))
	if [ -f '/usr/share/my_stuff/system_files/bin/CONTAINER_RT' ];then
		for container in "${CONTAINERS_LIST_OF_DEPLOYS_SCRIPTS_[@]}"; do
			[ ! -f "${_DEPLOYED_CONTAINERS_LIBDIR}/${container}" ] && echo "${container}" >> "${containers_deploy_db_path}"
		done
	else
		for container in "${CONTAINERS_LIST_OF_DEPLOYS_SCRIPTS_[@]}"; do
			echo "${container}" >> "${containers_deploy_db_path}"	
		done
	fi
}

create_styles_db(){
	source "/usr/share/my_stuff/lib/common/panel"
	source "/usr/share/my_stuff/lib/common/openbox"

	# Dir
	if [ -f "$OB_STYLE_NORMAL" ]; then
		dir="/usr/share/my_stuff/blob/polybar"
	else
		dir="/usr/share/my_stuff/blob/tint2"
	fi

	cd $dir && ls -d */ 2>/dev/null | cut -f1 -d'/' | grep -v "Default" > "${styles_db_path}"
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
}

case $opt in
		--tweeks) create_tweeks_db ;;
		--apps) create_apps_db_and_gaming_db ;;
		--deploy) create_distrobox_deploy_db ;;
		--containers) create_containers_deploy_db ;;
		--styles) create_styles_db ;;
		--all) create_all_db_execpt_style_db ;;
		*) : ;;
esac
