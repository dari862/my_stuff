#!/usr/bin/env sh
. "$__distro_path_lib"
exec 2>/dev/null
. "${__distro_path_root}/lib/common/WM"

ROW_ICON_FONT='feather 12'
MSG_ICON_FONT='feather 48'
MUSIC_PLAYER="$(cat "${script_config_path}/owl4ce_music_player")"
CHK_MPD_PORT="$(awk -F'"' '/^port/ {print $2}' "$HOME/.config/mpd/mpd.conf")"

A_='' A="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${A_}</span>   Previous"
B_='' B="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${B_}</span>   Playback"
C_='' C="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${C_}</span>   Next"
D_='' D="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${D_}</span>   Stop"

case "$MUSIC_PLAYER" in
    mpd) E_='' E="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${E_}</span>   Single"
    ;;
esac

case "${@}" in
    "$A") ${__distro_path_root}/bin/X11/not_add_2_path/owl4ce/owl4ce_scripts music prev
    ;;
    "$B") ${__distro_path_root}/bin/X11/not_add_2_path/owl4ce/owl4ce_scripts music toggle
    ;;
    "$C") ${__distro_path_root}/bin/X11/not_add_2_path/owl4ce/owl4ce_scripts music next
    ;;
    "$D") ${__distro_path_root}/bin/X11/not_add_2_path/owl4ce/owl4ce_scripts music stop
    ;;
    "$E") mpc -p "$CHK_MPD_PORT" single -q
    ;;
esac

MESSAGE="$(${__distro_path_root}/bin/X11/not_add_2_path/owl4ce/owl4ce_scripts music title)"

if [ "${#MESSAGE}" -gt 8 ]; then
    MESSAGE="<span size='xx-small'>$(printf '%.9s\n' "$MESSAGE")..</span>"
elif [ "${#MESSAGE}" -gt 4 ]; then
    MESSAGE="<span size='x-small'>${MESSAGE}</span>"
elif [ -z "$MESSAGE" ]; then
    MESSAGE="<span font_desc='${MSG_ICON_FONT}' weight='bold'></span>"
fi

printf '%b\n' '\0use-hot-keys\037true' '\0markup-rows\037true' "\0message\037${MESSAGE}" \
              "$A" "$B" "$C" "$D" "$E"

[ -n "$(${__distro_path_root}/bin/X11/not_add_2_path/owl4ce/owl4ce_scripts music status)" ] && P_A='1' || P_U='1'

case "$MUSIC_PLAYER" in
    mpd) STATUS="$(mpc -p "$CHK_MPD_PORT" status)"
         [ -n "${STATUS##*single:\ off*}" ] && S_A='4' || S_U='4'
    ;;
esac

printf "\0active\037${P_A}\n\0urgent\037${P_U}\n\0active\037${S_A}\n\0urgent\037${S_U}\n"

exit ${?}
