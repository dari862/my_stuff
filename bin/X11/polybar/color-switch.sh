#!/bin/sh
. "$__distro_path_lib"
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
				*amber) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --amber ;;
				*blue) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --blue ;;
				*blue-gray) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --blue-gray ;;
				*brown) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --brown ;;
				*cyan) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --cyan ;;
				*deep-orange) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --deep-orange ;;
				*deep-purple) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --deep-purple ;;
				*green) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --green ;;
				*gray) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --gray ;;
				*indigo) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --indigo ;;
				*blue-light) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --light-blue ;;
				*green-light) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --light-green ;;
				*lime) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --lime ;;
				*orange) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --orange ;;
				*pink) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --pink ;;
				*purple) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --purple ;;
				*red) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --red ;;
				*teal) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --teal ;;
				*yellow) "${__distro_path_root}"/bin/X11/polybar/colors-light.sh --yellow ;;
				## Dark Colors
				*amber-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --amber ;;
				*blue-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --blue ;;
				*blue-gray-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --blue-gray ;;
				*brown-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --brown ;;
				*cyan-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --cyan ;;
				*deep-orange-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --deep-orange ;;
				*deep-purple-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --deep-purple ;;
				*green-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --green ;;
				*gray-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --gray ;;
				*indigo-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --indigo ;;
				*blue-light-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --light-blue ;;
				*green-light-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --light-green ;;
				*lime-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --lime ;;
				*orange-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --orange ;;
				*pink-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --pink ;;
				*purple-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --purple ;;
				*red-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --red ;;
				*teal-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --teal ;;
				*yellow-dark) "${__distro_path_root}"/bin/X11/polybar/colors-dark.sh --yellow				
            esac
