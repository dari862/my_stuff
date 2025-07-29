#!/bin/sh

run_tweeks_script_="popup_terminal"

. "/usr/share/my_stuff/lib/common/pipemenu"
. "/usr/share/my_stuff/lib/common/DB"
. "/usr/share/my_stuff/lib/common/my_installer_and_DB_dir"
. "/usr/share/my_stuff/Distro_Specific/info"

TWEEKS="$(cat "${tweeks_db_path}")"

{
	menuStart "Run${distro_name_}Tweeks" "Run ${distro_name_} Tweeks"
	for tweek in ${TWEEKS}; do
    	menuItem "run ${tweek}" "${run_tweeks_script_} --tweek ${tweek}"
    done
    menuEnd
} | tee "${my_tweeks_pipemenu_file}" >/dev/null 2>&1
