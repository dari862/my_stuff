#!/bin/sh
. "$__distro_path_lib"
. "${__distro_path_root}/lib/common/WM"
. "${Distro_config_file}"
rofi_command() {
	rofi -no-config -no-lazy-grab  -dmenu -i -p '' -sep '|' -theme "$HOME/.config/rofi/$ROFI_STYLE/runner.rasi"
}
# Launch Rofi
if [ "$polybar_STYLE" = "blocks" ]
then
	MENU="$(echo " Default| Nord| Gruvbox| Adapta| Cherry" | rofi_command)"
				case "$MENU" in
					*Default) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --default ;;
					*Nord) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --nord ;;
					*Gruvbox) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --gruvbox ;;
					*Adapta) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --adapta ;;
					*Cherry) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --cherry ;;
				esac
elif [ "$polybar_STYLE" = "forest/original" ] || [ "$polybar_STYLE" = "forest/large" ]
then
	MENU="$(echo " Default| Nord| Gruvbox| Dark| Cherry" | rofi_command)"
				case "$MENU" in
					*Default) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --default ;;
					*Nord) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --nord ;;
					*Gruvbox) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --gruvbox ;;
					*Dark) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --dark ;;
					*Cherry) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --cherry ;;
				esac
elif [ "$polybar_STYLE" = "cuts" ]
then
	MENU="$(echo " Black| Adapta| Dark| Red| Green| Teal| Gruvbox| Nord| Solarized| Cherry" | rofi_command)"
				case "$MENU" in
					*Black) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --mode1 ;;
					*Adapta) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --mode2 ;;
					*Dark) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --mode3 ;;
					*Red) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --mode4 ;;
					*Green) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --mode5 ;;
					*Teal) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --mode6 ;;
					*Gruvbox) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --mode7 ;;
					*Nord) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --mode8 ;;
					*Solarized) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --mode9 ;;
					*Cherry) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --mode10 ;;
				esac
elif [ "$polybar_STYLE" = "pwidgets" ]
then
	MENU="$(echo " Default| Nord| Gruvbox| Dark| Cherry| White| Black" | rofi_command)"
				case "$MENU" in
					*Default) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --default ;;
					*Nord) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --nord ;;
					*Gruvbox) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --gruvbox ;;
					*Dark) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --dark ;;
					*Cherry) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --cherry ;;
					*White) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --white ;;
					*Black) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh --black ;;
				esac
elif echo "$polybar_STYLE" |  grep -q "panels/";then
	# Launch Rofi
	MENU="$(echo " Budgie| Deepin| Elementary| Elementary_Dark| Gnome| KDE| KDE_Dark| Liri| Mint| Ubuntu_gnome| Ubuntu_unity| Xubuntu| Zorin" | rofi_command)"
				case "$MENU" in
					*Budgie) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh budgie ;;
					*Deepin) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh deepin ;;
					*Elementary) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh elementary ;;
					*Elementary_Dark) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh elementary_dark ;;
					*Gnome) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh gnome ;;
					*KDE) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh kde ;;
					*KDE_Dark) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh kde_dark ;;
					*Liri) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh liri ;;
					*Mint) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh mint ;;
					*Ubuntu_gnome) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh ubuntu_ugnome ;;
					*Ubuntu_unity) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh ubuntu_unity ;;
					*Xubuntu) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh xubuntu ;;
					*Zorin) "${__distro_path_root}"/bin/X11/polybar/style-switcher.sh zorin ;;
				esac
else
	echo "somthing wrong"
fi
