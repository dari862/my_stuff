#!/bin/sh

run_full_environment_script_="popup_terminal"

. "$__distro_path_lib"
. "${__distro_path_root}/lib/common/pipemenu"
. "${__distro_path_root}/lib/common/DB"
. "${__distro_path_root}/lib/common/my_installer_and_DB_dir"

full_environments="$(cat "${full_environment_db_path}")"
_SUPERUSER="my-superuser"
[ "$(id -u)" -eq 0 ] && _SUPERUSER=""

{
	menuStart "RunDebianTweeks" "Run Debian Tweeks"
	for fullenv in ${full_environments}; do
    	menuItem "install ${fullenv}" "${run_full_environment_script_} --fullenv ${fullenv}"
    done
    menuEnd
} | $_SUPERUSER tee "${full_environment_pipemenu_file}" >/dev/null 2>&1
