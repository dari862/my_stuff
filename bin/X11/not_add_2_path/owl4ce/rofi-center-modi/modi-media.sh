#!/bin/sh
. "$__distro_path_lib"
ROW_ICON_FONT='feather 12'
MSG_ICON_FONT='feather 48'

B_='' B="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${B_}</span>   Increase ${AUDIO_VOLUME_STEPS}%"
C_='' C="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${C_}</span>   Decrease ${AUDIO_VOLUME_STEPS}%"
D_='' D="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${D_}</span>   Toggle mute"
F_='' F="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${F_}</span>   Brighten ${BRIGHTNESS_STEPS}%"
G_='' G="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${G_}</span>   Dim ${BRIGHTNESS_STEPS}%"

case "${@}" in
    "$B") "${__distro_path_root}"/system_files/volume_cli_control --inc
    ;;
    "$C") "${__distro_path_root}"/system_files/volume_cli_control --dec
    ;;
    "$D") "${__distro_path_root}"/system_files/volume_cli_control --toggle
    ;;
    "$F") "${__distro_path_root}"/bin/X11/WM/disto_brightness_controller --inc
    ;;
    "$G") "${__distro_path_root}"/bin/X11/WM/disto_brightness_controller --dec
    ;;
esac

AUDIO_VOLUME="${__distro_path_root}/system_files/volume_cli_control --get)"

if "${__distro_path_root}"/system_files/volume_cli_control --is-muted;then
	AUDIO_VOLUME="---"
	A_=''
elif [ "$AUDIO_VOLUME" -eq 0 ]; then
	A_=''
elif [ "$AUDIO_VOLUME" -lt 30 ]; then
    A_=''
elif [ "$AUDIO_VOLUME" -lt 70 ]; then
    A_=''
else
    A_=''
fi

A="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${A_}</span>   ${AUDIO_VOLUME}"
MESSAGE="<span font_desc='${MSG_ICON_FONT}' weight='bold'></span>"

if [ -f "${__distro_path_root}/bin/X11/WM/disto_brightness_controller" ];then
	E_='' E="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${E_}</span>   ${BRIGHTNESS}"
	BRIGHTNESS="$("${__distro_path_root}"/bin/X11/WM/disto_brightness_controller)"
	printf '%b\n' '\0use-hot-keys\037true' '\0markup-rows\037true' "\0message\037${MESSAGE}" \
              	"${A}\0nonselectable\037true" "$B" "$C" "$D" "${E}\0nonselectable\037true" "$F" "$G"
else
	printf '%b\n' '\0use-hot-keys\037true' '\0markup-rows\037true' "\0message\037${MESSAGE}" \
              	"${A}\0nonselectable\037true" "$B" "$C" "$D"
fi
exit ${?}
