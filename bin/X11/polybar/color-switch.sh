#!/bin/sh
. "/usr/share/my_stuff/lib/common/Distro_path"
. "${__distro_path_root}/lib/common/WM"
. "${Distro_config_file}"
rofi_command() {
	rofi -no-config -no-lazy-grab  -dmenu -i -p '' -sep '|' -theme "$HOME/.config/rofi/$ROFI_STYLE/runner.rasi"
}
if [ "$ROFI_STYLE" = "grayblocks" ] || [ "$ROFI_STYLE" = "docky" ] || [ "$ROFI_STYLE" = "cuts" ];then
	symbol_for_themes_=""
else
	symbol_for_themes_="♥"
fi

# Launch Rofi
MENU="$(printf "$symbol_for_themes_ amber|$symbol_for_themes_ blue|$symbol_for_themes_ blue-gray|$symbol_for_themes_ brown|$symbol_for_themes_ cyan|$symbol_for_themes_ deep-orange|\
$symbol_for_themes_ deep-purple|$symbol_for_themes_ green|$symbol_for_themes_ gray|$symbol_for_themes_ indigo|$symbol_for_themes_ blue-light|$symbol_for_themes_ green-light|\
$symbol_for_themes_ lime|$symbol_for_themes_ orange|$symbol_for_themes_ pink|$symbol_for_themes_ purple|$symbol_for_themes_ red|$symbol_for_themes_ teal|$symbol_for_themes_ yellow|$symbol_for_themes_ amber-dark|\
$symbol_for_themes_ blue-dark|$symbol_for_themes_ blue-gray-dark|$symbol_for_themes_ brown-dark|$symbol_for_themes_ cyan-dark|$symbol_for_themes_ deep-orange-dark|\
$symbol_for_themes_ deep-purple-dark|$symbol_for_themes_ green-dark|$symbol_for_themes_ gray-dark|$symbol_for_themes_ indigo-dark|$symbol_for_themes_ blue-light-dark|\
$symbol_for_themes_ green-light-dark|$symbol_for_themes_ lime-dark|$symbol_for_themes_ orange-dark|$symbol_for_themes_ pink-dark|$symbol_for_themes_ purple-dark|$symbol_for_themes_ red-dark|$symbol_for_themes_ teal-dark|$symbol_for_themes_ yellow-dark" | rofi_command)"
            case "$MENU" in
				## Light Colors
				*amber) colors-light.sh --amber ;;
				*blue) colors-light.sh --blue ;;
				*blue-gray) colors-light.sh --blue-gray ;;
				*brown) colors-light.sh --brown ;;
				*cyan) colors-light.sh --cyan ;;
				*deep-orange) colors-light.sh --deep-orange ;;
				*deep-purple) colors-light.sh --deep-purple ;;
				*green) colors-light.sh --green ;;
				*gray) colors-light.sh --gray ;;
				*indigo) colors-light.sh --indigo ;;
				*blue-light) colors-light.sh --light-blue ;;
				*green-light) colors-light.sh --light-green ;;
				*lime) colors-light.sh --lime ;;
				*orange) colors-light.sh --orange ;;
				*pink) colors-light.sh --pink ;;
				*purple) colors-light.sh --purple ;;
				*red) colors-light.sh --red ;;
				*teal) colors-light.sh --teal ;;
				*yellow) colors-light.sh --yellow ;;
				## Dark Colors
				*amber-dark) colors-dark.sh --amber ;;
				*blue-dark) colors-dark.sh --blue ;;
				*blue-gray-dark) colors-dark.sh --blue-gray ;;
				*brown-dark) colors-dark.sh --brown ;;
				*cyan-dark) colors-dark.sh --cyan ;;
				*deep-orange-dark) colors-dark.sh --deep-orange ;;
				*deep-purple-dark) colors-dark.sh --deep-purple ;;
				*green-dark) colors-dark.sh --green ;;
				*gray-dark) colors-dark.sh --gray ;;
				*indigo-dark) colors-dark.sh --indigo ;;
				*blue-light-dark) colors-dark.sh --light-blue ;;
				*green-light-dark) colors-dark.sh --light-green ;;
				*lime-dark) colors-dark.sh --lime ;;
				*orange-dark) colors-dark.sh --orange ;;
				*pink-dark) colors-dark.sh --pink ;;
				*purple-dark) colors-dark.sh --purple ;;
				*red-dark) colors-dark.sh --red ;;
				*teal-dark) colors-dark.sh --teal ;;
				*yellow-dark) colors-dark.sh --yellow				
            esac
