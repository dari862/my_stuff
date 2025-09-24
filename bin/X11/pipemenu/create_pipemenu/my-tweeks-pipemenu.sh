#!/bin/sh

run_tweeks_script_="popup_terminal"

. "$__distro_path_lib"
. "${__distro_path_root}/lib/common/pipemenu"
. "${__distro_path_root}/lib/common/DB"
. "${__distro_path_root}/lib/common/my_installer_and_DB_dir"
. "${__distro_path_root}/Distro_Specific/info"

TWEEKS="$(cat "${tweeks_db_path}")"
_SUPERUSER="my-superuser"
[ "$(id -u)" -eq 0 ] && _SUPERUSER=""

{
	menuStart "Run${distro_name_}Tweeks" "Run ${distro_name_} Tweeks"
	for tweek in ${TWEEKS}; do
    	menuItem "run ${tweek}" "${run_tweeks_script_} --tweek ${tweek}"
    done
    menuEnd
} | $_SUPERUSER tee "${my_tweeks_pipemenu_file}" >/dev/null 2>&1
