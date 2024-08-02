run_ascii_art
echo "Choose package to uninstall:"
UNINSTALLERS=()

for package in $(ls $DEV_PATH/uninstall);do
	package=$(echo "$package" | sed 's/app-//' | sed 's/.sh//' | sed 's/.*/\u&/' )
	UNINSTALLERS+=("$package")
done

UNINSTALLERS+=("<< Back")
bash_active_select -i "${UNINSTALLERS[@]}"
UNINSTALLER=$(echo "${UNINSTALLERS[${UI_WIDGET_RC}]}" | tr '[:upper:]' '[:lower:]')

[ "$UNINSTALLER" = "<< Back"* ] && [ -n "$UNINSTALLER" ] && echo "Run uninstaller?" && run_confirmtion && source $UNINSTALLER && echo "Uninstall completed!" && sleep 3
clear
source $DEV_PATH/Dev-menu
