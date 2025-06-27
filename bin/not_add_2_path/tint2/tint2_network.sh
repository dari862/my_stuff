#!/usr/bin/env sh
INTERFACE="$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')"

if [ -z "$INTERFACE" ]; then
    E_INTERFACE="$(ip -o link show | awk -F': ' '/state UP/ && $2 ~ /^e/ {print $2}' | grep -v lo | head -n 1)"
    W_INTERFACE="$(ip -o link show | awk -F': ' '/state UP/ && $2 ~ /^w/ {print $2}' | grep -v lo | head -n 1)"
else
    case "$INTERFACE" in
        e*) E_INTERFACE="$INTERFACE" ;;
        w*) W_INTERFACE="$INTERFACE" ;;
    esac
fi

if [ -n "$W_INTERFACE" ]; then
    ESSID=$(iwgetid -r "$W_INTERFACE" 2>/dev/null)

    if [ -n "$ESSID" ]; then
        if ip -o -4 addr show "$W_INTERFACE" | grep -q "inet"; then
            ICON=''
            STAT="${ESSID} @ ${W_INTERFACE}"
        else
            ICON=''
            STAT="No IP Address @ ${W_INTERFACE}"
        fi
    else
        ICON=''
        STAT="Disconnected @ ${W_INTERFACE}"
    fi
elif [ -n "$E_INTERFACE" ]; then
    IP_ET=$(ip -o -4 addr show "$E_INTERFACE" | awk '{print $4}' | cut -d/ -f1)

    if [ -n "$IP_ET" ]; then
        ICON=''
        STAT="${IP_ET} @ ${E_INTERFACE}"
    else
        ICON=''
        STAT="No IP Address @ ${E_INTERFACE}"
    fi
else
    ICON=''
    STAT="No valid network interfaces found"
fi

case "$1" in
    icon) echo "$ICON" ;;
    sta*) echo "$STAT" ;;
esac
