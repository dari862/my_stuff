#!/bin/sh
# need superuser : installed by git installer code
set -e
. "$__distro_path_lib"
. "${__distro_path_root}/Distro_Specific/disto_icon"

if [ "$(id -u)" -ne 0 ];then
    echo "Script is not running as superuser."
    exit 1
fi

if [ "$XDG_SESSION_TYPE" = "x11" ] || ps aux | grep -q Xorg || loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type | awk -F= '{print $2}' | grep -q x11 >/dev/null 2>&1;then
	Display_server_are="X11"
else
	Display_server_are="wayland"
fi

THEME_DIR="/usr/share/grub/themes"
SCRIPT_DIR="$(dirname "$(readlink -m "${0}")")"
background_path="${SCRIPT_DIR}/common/background.jpg"
custom_background_path="${SCRIPT_DIR}/background.jpg"
logoicon="$root_distro_name"
if [ "$Display_server_are" = "X11" ];then
	screen="$(xrandr | awk '/\*/ {print $1; exit}' | cut -d 'x' -f1)"
elif [ "$Display_server_are" = "wayland" ];then
    if command -v swaymsg >/dev/null 2>&1; then
        screen=$(swaymsg -t get_outputs | jq -r '.[0].current_mode.width')
    elif command -v hyprctl >/dev/null 2>&1; then
        screen=$(hyprctl monitors -j | jq -r '.[0].width')
    elif command -v wlr-randr >/dev/null 2>&1; then
        screen=$(wlr-randr | awk '/current mode/ {print $3; exit}' | cut -d 'x' -f1)
    elif command -v wayland-info >/dev/null 2>&1; then
        screen=$(wayland-info | awk '/current_mode/ {print $2; exit}' | cut -d 'x' -f1)
    fi
fi
if [ -z "${screen}" ] || [ "${screen}" -le '1920' ];then
	screen="1080p"
elif [ "${screen}" -le '2560' ];then
	screen="2k"
elif [ "${screen}" -le '3840' ];then
	screen="4k"
else
	screen="4k"
fi
TEMP_THEME_DIR="/tmp/$USER/Temp_GRUB_Theme"

[ -d "${THEME_DIR}" ] && rm -rf "${THEME_DIR}"
mkdir -p "${THEME_DIR}"

[ -d "${TEMP_THEME_DIR}" ] && rm -rf "${TEMP_THEME_DIR}"
mkdir -p "${TEMP_THEME_DIR}"

if [ ! -f "$background_path" ] && [ -f "$custom_background_path" ];then
	"${SCRIPT_DIR}/create_custom_bg" || exit 1
fi
cp -r "${SCRIPT_DIR}/common"/* "${TEMP_THEME_DIR}"
cp -r "${SCRIPT_DIR}/extra/theme-${screen}.txt" "${TEMP_THEME_DIR}/theme.txt"
cp -r "${SCRIPT_DIR}/extra/icons/${screen}" "${TEMP_THEME_DIR}/icons"
cp -r "${SCRIPT_DIR}/extra/select/${screen}"/* "${TEMP_THEME_DIR}"
if [ -f "${SCRIPT_DIR}/extra/logo/${screen}/${logoicon}.png" ];then
	cp -r "${SCRIPT_DIR}/extra/logo/${screen}/${logoicon}.png" "${TEMP_THEME_DIR}/logo.png"
else
	cp -r "${SCRIPT_DIR}/extra/logo/${screen}/Default.png" "${TEMP_THEME_DIR}/logo.png"
fi

cp -a --no-preserve=ownership "${TEMP_THEME_DIR}"/* "${THEME_DIR}"

# Backup grub config
[ -f /etc/default/grub.bak ] && cp -an /etc/default/grub /etc/default/grub.bak

if grep -q "GRUB_THEME=" /etc/default/grub;then
	#Replace GRUB_THEME
	sed -i "s|.*GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/theme.txt\"|" /etc/default/grub
else
	#Append GRUB_THEME
	echo "GRUB_THEME=\"${THEME_DIR}/theme.txt\"" >> /etc/default/grub
fi

if grep -q "GRUB_BACKGROUND=" /etc/default/grub;then
	#Replace GRUB_BACKGROUND
	sed -i "s|.*GRUB_BACKGROUND=.*|GRUB_BACKGROUND=\"${THEME_DIR}/background.jpg\"|" /etc/default/grub
else
	#Append GRUB_BACKGROUND
	echo "GRUB_BACKGROUND=\"${THEME_DIR}/background.jpg\"" >> /etc/default/grub
fi

case "${screen}" in
		1080p)
		gfxmode="GRUB_GFXMODE=1920x1080,auto"
		;;
		2k)
		gfxmode="GRUB_GFXMODE=2560x1440,auto"
		;;
		4k)
		gfxmode="GRUB_GFXMODE=3840x2160,auto"
		;;
	esac

if grep -q "GRUB_GFXMODE=" /etc/default/grub;then
	#Replace GRUB_GFXMODE
	sed -i "s|.*GRUB_GFXMODE=.*|${gfxmode}|" /etc/default/grub
else
	#Append GRUB_GFXMODE
	echo "${gfxmode}" >> /etc/default/grub
fi

for option in "GRUB_TERMINAL" "GRUB_TERMINAL_OUTPUT"; do
	if grep -q "${option}=console" /etc/default/grub;then
		sed -i "s|.*${option}=console|#${option}=console|" /etc/default/grub
	fi
done

if command -v  update-grub >/dev/null 2>&1; then
	update-grub
elif command -v  grub-mkconfig >/dev/null 2>&1; then
	grub-mkconfig -o /boot/grub/grub.cfg
elif command -v  zypper >/dev/null 2>&1 || command -v  transactional-update >/dev/null 2>&1; then
	grub2-mkconfig -o /boot/grub2/grub.cfg
elif command -v  dnf >/dev/null 2>&1 || command -v  rpm-ostree >/dev/null 2>&1; then
	if [ -f "/boot/grub2/grub.cfg" ]; then
		grub2-mkconfig -o /boot/grub2/grub.cfg
	elif [ -f "/boot/efi/EFI/fedora/grub.cfg" ]; then
		grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
	fi
fi
