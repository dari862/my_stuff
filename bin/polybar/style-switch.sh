#!/usr/bin/env bash
. "/usr/share/my_stuff/lib/common/WM"
. "/usr/share/my_stuff/lib/common/rofi"

# Launch Rofi
if [ "$ROFI_STYLE" == "blocks" ]
then
	MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' \
	-theme "$rofi_style_dir"/styles.rasi \
	<<< " Default| Nord| Gruvbox| Adapta| Cherry|")"
				case "$MENU" in
					*Default) style-switcher.sh --default ;;
					*Nord) style-switcher.sh --nord ;;
					*Gruvbox) style-switcher.sh --gruvbox ;;
					*Adapta) style-switcher.sh --adapta ;;
					*Cherry) style-switcher.sh --cherry ;;
				esac
elif [ "$ROFI_STYLE" == "forest" ] || [ "$ROFI_STYLE" == "forest_large" ]
then
	MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' \
	-theme "$rofi_style_dir"/styles.rasi \
	<<< " Default| Nord| Gruvbox| Dark| Cherry|")"
				case "$MENU" in
					*Default) style-switcher.sh --default ;;
					*Nord) style-switcher.sh --nord ;;
					*Gruvbox) style-switcher.sh --gruvbox ;;
					*Dark) style-switcher.sh --dark ;;
					*Cherry) style-switcher.sh --cherry ;;
				esac
elif [ "$ROFI_STYLE" == "cuts" ]
then
	MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' \
	-theme "$rofi_style_dir"/styles.rasi \
	<<< " Black| Adapta| Dark| Red| Green| Teal| Gruvbox| Nord| Solarized| Cherry|")"
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
elif [[ "$ROFI_STYLE" == "panels/"* ]]
then
	# Launch Rofi
	MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' \
	-theme "$rofi_style_dir"/styles.rasi \
	<<< " Budgie| Deepin| Elementary| Elementary_Dark| Gnome| KDE|\
	 KDE_Dark| Liri| Mint| Ubuntu_gnome| Ubuntu_unity| Xubuntu| Zorin|")"
				case "$MENU" in
					*Budgie) style-switcher.sh --budgie ;;
					*Deepin) style-switcher.sh --deepin ;;
					*Elementary) style-switcher.sh --elight ;;
					*Elementary_Dark) style-switcher.sh --edark ;;
					*Gnome) style-switcher.sh --gnome ;;
					*KDE) style-switcher.sh --klight ;;
					*KDE_Dark) style-switcher.sh --kdark ;;
					*Liri) style-switcher.sh --liri ;;
					*Mint) style-switcher.sh --mint ;;
					*Ubuntu_gnome) style-switcher.sh --ugnome ;;
					*Ubuntu_unity) style-switcher.sh --unity ;;
					*Xubuntu) style-switcher.sh --xubuntu ;;
					*Zorin) style-switcher.sh --zorin ;;
				esac
elif [ "$ROFI_STYLE" == "pwidgets" ]
then
	MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' \
	-theme "$rofi_style_dir"/styles.rasi \
	<<< " Default| Nord| Gruvbox| Dark| Cherry| White| Black|")"
				case "$MENU" in
					*Default) style-switcher.sh --default ;;
					*Nord) style-switcher.sh --nord ;;
					*Gruvbox) style-switcher.sh --gruvbox ;;
					*Dark) style-switcher.sh --dark ;;
					*Cherry) style-switcher.sh --cherry ;;
					*White) style-switcher.sh --white ;;
					*Black) style-switcher.sh --black ;;
				esac
elif [ "$ROFI_STYLE" == "shapes" ]
then
	# Replace Glyphs
	change_style() {
		sed -i -e "s/gleft = .*/gleft = $1/g" "$rofi_style_dir"/glyphs.ini
		sed -i -e "s/gright = .*/gright = $2/g" "$rofi_style_dir"/glyphs.ini

		polybar-msg cmd restart
	}


	# Launch Rofi
	MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' \
	-theme "$rofi_style_dir"/styles.rasi \
	<<< "♥ Style-1|♥ Style-2|♥ Style-3|♥ Style-4|♥ Style-5|♥ Style-6|♥ Style-7|♥ Style-8|♥ Style-9|♥ Style-10|♥ Style-11|♥ Style-12|")"
				case "$MENU" in
					## Light Colors
					*Style-1) change_style   ;;
					*Style-2) change_style   ;;
					*Style-3) change_style   ;;
					*Style-4) change_style   ;;
					*Style-5) change_style   ;;
					*Style-6) change_style   ;;
					*Style-7) change_style   ;;
					*Style-8) change_style   ;;
					*Style-9) change_style   ;;
					*Style-10) change_style   ;;
					*Style-11) change_style   ;;
					*Style-12) change_style   ;;
				esac
else
	echo "somthing wrong"
fi
