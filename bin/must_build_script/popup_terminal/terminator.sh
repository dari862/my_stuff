install_app(){
	terminator -T "Installing App ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

install_game(){
	terminator -T "Installing ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

deploy_distrobox_container(){
	terminator -T "Deploying ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

deploy_container(){
	terminator -T "Deploying ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

run_commands(){
	terminator -T "Running ${file_name_}." -e bash -c "${file_name_}"
}

run_chroot(){
	terminator -T "Create ${file_name_} Chroot." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

run_tweek(){
	terminator -T "${file_name_}." -e bash -c "${my_tweaker_script_name} --tweek ${file_name_}"
}

run_fullenv(){
	terminator -T "${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

run_man(){
	terminator -T "${file_name_} man page." -e man ${file_name_}
}

run_editor(){	
	terminator -T "${file_name_} - CLI Editor" -e $CLI_EDITER "${file_name_}"
}

run_editor_with_super_user(){	
	CLI_EDITER_PATH="$(which $CLI_EDITER)"
	terminator -T "${file_name_} - CLI Editor" -e my-superuser $CLI_EDITER_PATH "${file_name_}"
}

run_popup_fullscreen_mode(){
	terminator --start-as fullscreen --config /etc/xdg/kitty/kitty.conf -T "${arg_}" -e bash -c "${file_name_}"
}

run_popup_normal_mode(){
	terminator -T "${arg_}" -e bash -c "${file_name_}"
}

run_popup_normal_mode_geometry(){
	terminator -T "${Title}" -e bash -c "${file_name_}"
}

run_popup_normal_normal_superuser_mode(){
	terminator -T "${arg_}" -e my-superuser bash -c "export __distro_path_lib=\"${__distro_path_lib}\" ; ${file_name_}"
}
