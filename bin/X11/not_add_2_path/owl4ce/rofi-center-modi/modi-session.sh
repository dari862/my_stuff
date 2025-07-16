#!/usr/bin/env sh
exec 2>/dev/null
ROW_ICON_FONT='feather 12'
MSG_ICON_FONT='feather 48'

A_='' A="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${A_}</span>   Poweroff"
B_='' B="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${B_}</span>   Reboot"
C_='' C="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${C_}</span>   Lock"
D_='' D="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${D_}</span>   Suspend"
E_='' E="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${E_}</span>   Hibernate"
F_='' F="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${F_}</span>   Logout"
Y_='' Y="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${Y_}</span>   Confirm"
N_='' N="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${N_}</span>   Cancel"
Z_='' Z="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${Z_}</span>   Firmware Setup"

prompt()
{
    [ "${1}" = "$B_" ] || Z=

    PROMPT="<span font_desc='${MSG_ICON_FONT}' weight='bold'>${1}</span>"

    printf '%b\n' "\0message\037${PROMPT}" \
                  "${Y}\0info\037#${2}" "$N" "${Z}\0info\037#${2} --firmware-setup"

    exit ${?}
}

case "${@}" in
    "$A"     ) prompt "$A_" "my_session_manager --no-confirm shutdown"
    ;;
    "$B"     ) prompt "$B_" "my_session_manager --no-confirm reboot"
    ;;
    "$C"     ) prompt "$C_" "my_session_manager --no-confirm lock"
    ;;
    "$D"     ) prompt "$D_" "my_session_manager --no-confirm suspend"
    ;;
    "$E"     ) prompt "$E_" "my_session_manager --no-confirm hibernate"
    ;;
    "$F"     ) prompt "$F_" 'my_session_manager --no-confirm logout'
    ;;
    "$Y"|"$Z") eval "exec ${ROFI_INFO#\#} >&2"
    ;;
esac

MESSAGE=" $(date +%H %M) "

printf '%b\n' '\0use-hot-keys\037true' '\0markup-rows\037true' "\0message\037${MESSAGE}" \
              "$A" "$B" "$C" "$D" "$E" "$F"

exit ${?}
