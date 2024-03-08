#!/bin/bash
opt="${1-}"
run_tweeks_script_name="my-tweeks"
source "/usr/share/DmDmDmdMdMdM/lib/common/DB"

create_tweeks_db(){
	_TWEEKS_DIR="/usr/share/DmDmDmdMdMdM/bin/not_add_2_path/tweeks_center"
	LS_TWEEKS=($(ls ${_TWEEKS_DIR}))
	mkdir -p "${db_dir}"
	for tweek in "${LS_TWEEKS[@]}"; do
		[[ "$(${run_tweeks_script_name} --check ${tweek})" != "enabled" ]] && echo "${tweek}" >> "${tweeks_db_path}"
	done
}

create_apps_db(){
	_SCRIPTS_LIBDIR="/usr/share/DmDmDmdMdMdM/bin/not_add_2_path/apps_center"
	GAMING_SCRIPTS_Dir_Name="Gaming"
	cd "${_SCRIPTS_LIBDIR}"
	LIST_OF_APPS_SCRIPTS_=($(ls | grep -v "${GAMING_SCRIPTS_Dir_Name}" ))
	mkdir -p "${apps_db_path}"
	for d in "${LIST_OF_APPS_SCRIPTS_[@]}";do
		if [ -d "$d" ];then
			[ -f "${apps_db_path}/$d" ] && rm "${apps_db_path}/$d"
			cd "$d"
			for app in *;do
				hash "${app}" 2>/dev/null || echo "${app}" >> "${apps_db_path}/$d"
			done
			cd ..
		fi
	done
	# gaming db
	cd "${GAMING_SCRIPTS_Dir_Name}"
	LIST_OF_GAMING_SCRIPTS_=($(ls))
	mkdir -p "${gaming_db_path}"
	for d in "${LIST_OF_GAMING_SCRIPTS_[@]}";do
		if [ -d "$d" ];then
			[ -f "${gaming_db_path}/$d" ] && rm "${gaming_db_path}/$d"
			cd "$d"
			for Gapp in *;do
				hash "${Gapp}" 2>/dev/null || echo "${Gapp}" >> "${gaming_db_path}/$d"
			done
			cd ..
		fi
	done
}

create_styles_db(){
	source "/usr/share/DmDmDmdMdMdM/lib/common/panel"
	OBPATH="$HOME/.config/openbox"
	rc_file_name="$(cat "${OBPATH}/rc_name")"
	# Dir
	if [ "$_panel_name_" == "tint2" ] && [ "$rc_file_name" != "DmDmDmdMdMdM_rc.xml" ]; then
		dir="/usr/share/DmDmDmdMdMdM/blob/tint2"
	else
		dir="/usr/share/DmDmDmdMdMdM/blob/${_panel_name_}"
	fi

	cd $dir && ls -I Default -I "*-Bitmap" -I "*.jpg" 2>/dev/null > "${styles_db_path}"
	cd $dir && ls *-Bitmap 2>/dev/null > "${bit_styles_db_path}"
}

create_all_db(){
	if [ ! -f "${tweeks_db_path}" ] ; then
		create_tweeks_db
	fi 
		
	if [ ! -f "${apps_db_path}" ] ; then
		create_apps_db
	fi 
		
	if [ ! -f "${styles_db_path}" ] ; then
		create_styles_db
	fi
}

case $opt in
		--tweeks) create_tweeks_db ;;
		--apps) create_apps_db ;;
		--styles) create_styles_db ;;
		*) create_all_db ;;
esac
