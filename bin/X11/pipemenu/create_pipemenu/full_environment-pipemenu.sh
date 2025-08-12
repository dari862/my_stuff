#!/bin/sh

run_full_environment_script_="popup_terminal"

. "/usr/share/my_stuff/lib/common/pipemenu"
. "/usr/share/my_stuff/lib/common/DB"
. "/usr/share/my_stuff/lib/common/my_installer_and_DB_dir"

full_environments="$(cat "${full_environment_db_path}")"

{
	menuStart "RunDebianTweeks" "Run Debian Tweeks"
	for fullenv in ${full_environments}; do
    	menuItem "install ${fullenv}" "${run_full_environment_script_} --fullenv ${fullenv}"
    done
    menuEnd
} | tee "${full_environment_pipemenu_file}" >/dev/null 2>&1
