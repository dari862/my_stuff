install_app(){
	kitty -T "Installing App ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

install_game(){
	kitty -T "Installing ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

deploy_distrobox_container(){
	kitty -T "Deploying ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

deploy_container(){
	kitty -T "Deploying ${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

run_commands(){
	kitty -T "Running ${file_name_}." -e bash -c "${file_name_}"
}

run_chroot(){
	kitty -T "Create ${file_name_} Chroot." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

run_tweek(){
	kitty -T "${file_name_}." -e bash -c "${my_tweaker_script_name} --tweek ${file_name_}"
}

run_fullenv(){
	kitty -T "${file_name_}." -e bash -c "${my_installer_script_name} ${arg_}  ${file_name_}"
}

run_man(){
	kitty -T "${file_name_} man page." -e man ${file_name_}
}

run_editor(){	
	kitty -T "${file_name_} - CLI Editor" -e $CLI_EDITER "${file_name_}"
}

run_editor_with_super_user(){	
	CLI_EDITER_PATH="$(which $CLI_EDITER)"
	kitty -T "${file_name_} - CLI Editor" -e my-superuser $CLI_EDITER_PATH "${file_name_}"
}

run_popup_fullscreen_mode(){
	kitty --start-as fullscreen --config /etc/xdg/kitty/kitty.conf -T "${arg_}" -e bash -c "${file_name_}"
}

run_popup_normal_mode(){
	kitty -T "${arg_}" -e bash -c "${file_name_}"
}

run_popup_normal_mode_geometry(){
	kitty -T "${Title}" -e bash -c "${file_name_}"
}

run_popup_normal_normal_superuser_mode(){
	kitty -T "${arg_}" -e my-superuser bash -c "export __distro_path_lib=\"${__distro_path_lib}\" ; ${file_name_}"
}
