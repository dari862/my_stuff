
case $arg_ in
		--install) install_app ;;
		--game) install_game ;;
		--deploy) deploy_distrobox_container ;;
		--container) deploy_container ;;
		--commands) run_commands ;;
		--chroot) run_chroot ;;
		--tweek) run_tweek ;;
		--fullenv) run_fullenv ;;
		--man) run_man ;;
		--editor) run_editor ;;
		--super-user-editor) run_editor_with_super_user ;;
		--full) run_popup_fullscreen_mode ;;
		--geometry) run_popup_normal_mode_geometry ;;
		--superuser) run_popup_normal_normal_superuser_mode ;;
		*) run_popup_normal_mode;;
esac
