#!/bin/sh
exec 2>/dev/null
ROW_ICON_FONT='feather 12'
MSG_ICON_FONT='feather 48'

A_='' A="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${A_}</span>   Screen"
B_='' B="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${B_}</span>   Select or Draw"
C_='' C="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${C_}</span>   Countdown 5s"

Y_='' Y="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${Y_}</span>   Confirm"
N_='' N="<span font_desc='${ROW_ICON_FONT}' weight='bold'>${N_}</span>   Cancel"

prompt()
{
    PROMPT="<span font_desc='${MSG_ICON_FONT}' weight='bold'>${1}</span>"
    printf '%b\n' "\0message\037${PROMPT}" \
                  "${Y}\0info\037#${2}" "$N"
    exit ${?}
}

case "${@}" in
    "$A") prompt "$A_" "my-shots" ;;
    "$B") prompt "$B_" "my-shots --area" ;;
    "$C") prompt "$C_" "my-shots --delay 5" ;;
    "$Y") eval "exec ${ROFI_INFO#\#} >&2" ;;
esac

MESSAGE="<span font_desc='${MSG_ICON_FONT}' weight='bold'></span>"
printf '%b\n' '\0use-hot-keys\037true' '\0markup-rows\037true' "\0message\037${MESSAGE}" \
              "$A" "$B" "$C"
exit


