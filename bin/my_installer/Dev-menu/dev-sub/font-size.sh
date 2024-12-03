run_ascii_art
echo "Choose your terminal font size"
choice=(7 8 9 10 11 12 13 14 "<< Back")
bash_active_select -i "${choice[@]}"
choice=$(echo "${options[${UI_WIDGET_RC}]}" | tr '[:upper:]' '[:lower:]')
if [[ $choice =~ ^[0-9]+$ ]]; then
	sed -i "s/^size = .*$/size = $choice/g" ~/.config/alacritty/font-size.toml || :
	source $DEV_SUB_PATH/font-size.sh
else
	source $DEV_SUB_PATH/menu.sh
fi
