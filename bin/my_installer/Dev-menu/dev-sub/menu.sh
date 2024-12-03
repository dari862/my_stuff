run_ascii_art
options=("Font-size" "Update" "Install" "Uninstall" "Quit")
bash_active_select -i "${options[@]}"
SUB=$(echo "${options[${UI_WIDGET_RC}]}" | tr '[:upper:]' '[:lower:]')
[ -n "$SUB" ] && [ "$SUB" != "quit" ] && source $DEV_SUB_PATH/$SUB.sh
