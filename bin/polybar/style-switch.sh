#!/bin/sh
. "/usr/share/my_stuff/lib/common/WM"
. "${Distro_config_file}"
rofi_command() {
	rofi -no-config -no-lazy-grab  -dmenu -i -p '' -sep '|' -theme "$HOME/.config/rofi/$ROFI_STYLE/runner.rasi"
}
# Launch Rofi
if [ "$ROFI_STYLE" = "blocks" ]
then
	MENU="$(echo " Default| Nord| Gruvbox| Adapta| Cherry" | rofi_command)"
				case "$MENU" in
					*Default) style-switcher.sh --default ;;
					*Nord) style-switcher.sh --nord ;;
					*Gruvbox) style-switcher.sh --gruvbox ;;
					*Adapta) style-switcher.sh --adapta ;;
					*Cherry) style-switcher.sh --cherry ;;
				esac
elif [ "$ROFI_STYLE" = "forest" ] || [ "$ROFI_STYLE" = "forest_large" ]
then
	MENU="$(echo " Default| Nord| Gruvbox| Dark| Cherry" | rofi_command)"
				case "$MENU" in
					*Default) style-switcher.sh --default ;;
					*Nord) style-switcher.sh --nord ;;
					*Gruvbox) style-switcher.sh --gruvbox ;;
					*Dark) style-switcher.sh --dark ;;
					*Cherry) style-switcher.sh --cherry ;;
				esac
elif [ "$ROFI_STYLE" = "cuts" ]
then
	MENU="$(echo " Black| Adapta| Dark| Red| Green| Teal| Gruvbox| Nord| Solarized| Cherry" | rofi_command)"
				case "$MENU" in
					*Black) style-switcher.sh --mode1 ;;
					*Adapta) style-switcher.sh --mode2 ;;
					*Dark) style-switcher.sh --mode3 ;;
					*Red) style-switcher.sh --mode4 ;;
					*Green) style-switcher.sh --mode5 ;;
					*Teal) style-switcher.sh --mode6 ;;
					*Gruvbox) style-switcher.sh --mode7 ;;
					*Nord) style-switcher.sh --mode8 ;;
					*Solarized) style-switcher.sh --mode9 ;;
					*Cherry) style-switcher.sh --mode10 ;;
				esac
elif [ "$ROFI_STYLE" = "pwidgets" ]
then
	MENU="$(echo " Default| Nord| Gruvbox| Dark| Cherry| White| Black" | rofi_command)"
				case "$MENU" in
					*Default) style-switcher.sh --default ;;
					*Nord) style-switcher.sh --nord ;;
					*Gruvbox) style-switcher.sh --gruvbox ;;
					*Dark) style-switcher.sh --dark ;;
					*Cherry) style-switcher.sh --cherry ;;
					*White) style-switcher.sh --white ;;
					*Black) style-switcher.sh --black ;;
				esac
elif echo "$ROFI_STYLE" |  grep -q "panels/";then
	# Launch Rofi
	MENU="$(echo " Budgie| Deepin| Elementary| Elementary_Dark| Gnome| KDE| KDE_Dark| Liri| Mint| Ubuntu_gnome| Ubuntu_unity| Xubuntu| Zorin" | rofi_command)"
				case "$MENU" in
					*Budgie) style-switcher.sh budgie ;;
					*Deepin) style-switcher.sh deepin ;;
					*Elementary) style-switcher.sh elementary ;;
					*Elementary_Dark) style-switcher.sh elementary_dark ;;
					*Gnome) style-switcher.sh gnome ;;
					*KDE) style-switcher.sh kde ;;
					*KDE_Dark) style-switcher.sh kde_dark ;;
					*Liri) style-switcher.sh liri ;;
					*Mint) style-switcher.sh mint ;;
					*Ubuntu_gnome) style-switcher.sh ubuntu_ugnome ;;
					*Ubuntu_unity) style-switcher.sh ubuntu_unity ;;
					*Xubuntu) style-switcher.sh xubuntu ;;
					*Zorin) style-switcher.sh zorin ;;
				esac
else
	echo "somthing wrong"
fi
