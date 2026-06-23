Remote_Repo="Genymobile/scrcpy"
repobinMODE="full"
File_to_link="scrcpy"
link_all_bin=true

. "${__distro_path_root}/lib/common/common"

extra_bins() {
	$_SUPERUSER ln -sf "${__distro_path_root}/bin/not_add_2_path/ScrcpyGUI" "${__distro_path_root}/system_files/bin"
	if [ "$user_root_dir" = true ];then
		generate_applicationsdotdesktop_link "${File_to_link}" "ScrcpyGUI" "Android"
	else
		generate_userlevel_applicationsdotdesktop_link "${File_to_link}" "ScrcpyGUI" "Android"
	fi
}
