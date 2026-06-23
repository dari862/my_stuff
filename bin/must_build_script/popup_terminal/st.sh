install_app(){
	st -T "Installing App ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

install_game(){
	st -T "Installing ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

deploy_distrobox_container(){
	st -T "Deploying ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

deploy_container(){
	st -T "Deploying ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

run_commands(){
	st -T "Running ${file_name_}." -e bash -c "${file_name_}"
}

run_chroot(){
	st -T "Create ${file_name_} Chroot." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

run_tweek(){
	st -T "${file_name_}." -e bash -c "${my_tweaker_script_name} --tweek ${file_name_}"
}

run_fullenv(){
	st -T "${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

run_man(){
	st -T "${file_name_} man page." -e man ${file_name_}
}

run_editor(){	
	st -T "${file_name_} - CLI Editor" -e $CLI_EDITER "${file_name_}"
}

run_editor_with_super_user(){	
	CLI_EDITER_PATH="$(which $CLI_EDITER)"
	st -T "${file_name_} - CLI Editor" -e my-superuser $CLI_EDITER_PATH "${file_name_}"
}

run_popup_fullscreen_mode(){
	st --start-as fullscreen --config /etc/xdg/kitty/kitty.conf -T "${arg_}" -e bash -c "${file_name_}"
}

run_popup_normal_mode(){
	st -T "${arg_}" -e bash -c "${file_name_}"
}

run_popup_normal_mode_geometry(){
	st -T "${Title}" -e bash -c "${file_name_}"
}

run_popup_normal_normal_superuser_mode(){
	st -T "${arg_}" -e my-superuser bash -c "export __distro_path_lib=\"${__distro_path_lib}\" ; ${file_name_}"
}
