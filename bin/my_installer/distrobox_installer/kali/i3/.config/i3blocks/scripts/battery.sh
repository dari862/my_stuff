#!/bin/bash

BAT_00=" <span color='#bf616a'>󱃍 </span>"
BAT_10=" <span color='#bf616a'>󰁺</span>"
BAT_20=" <span color='#ebcb8b'>󰁻</span>"
BAT_30=" 󰁼"
BAT_40=" 󰁽"
BAT_50=" 󰁾"
BAT_60=" 󰁿"
BAT_70=" 󰂀"
BAT_80=" 󰂁"
BAT_90=" 󰂂"
BAT_100="󰂄"

CHR_00=" 󰢟"
CHR_10=" 󰢜"
CHR_20=" 󰂆"
CHR_30=" 󰂇"
CHR_40=" 󰂈"
CHR_50=" 󰢝"
CHR_60=" 󰂉"
CHR_70=" 󰢞"
CHR_80=" <span color='#8fbcbb'>󰂊</span>"
CHR_90=" <span color='#a3be8c'>󰂋</span>"
CHR_100=" <span color='#a3be8c'>󰂄</span>"

POW=$(cat /sys/class/power_supply/BAT0/capacity)
PO=$(echo "$POW" | rev | cut -c 2- | rev)

get_bat() {
    case $PO in
        1) echo "$BAT_10$POW " ;;
        2) echo "$BAT_20$POW " ;;
        3) echo "$BAT_30$POW " ;;
        4) echo "$BAT_40$POW " ;;
        5) echo "$BAT_50$POW " ;;
        6) echo "$BAT_60$POW " ;;
        7) echo "$BAT_70$POW " ;;
        8) echo "$BAT_80$POW " ;;
        9) echo "$BAT_90$POW " ;;
        10) echo "$BAT_100$POW " ;;
        *) echo "$BAT_00$POW " ;;
    esac
}

get_chr() {
    case $PO in
        1) echo "$CHR_10$POW " ;;
        2) echo "$CHR_20$POW " ;;
        3) echo "$CHR_30$POW " ;;
        4) echo "$CHR_40$POW " ;;
        5) echo "$CHR_50$POW " ;;
        6) echo "$CHR_60$POW " ;;
        7) echo "$CHR_70$POW " ;;
        8) echo "$CHR_80$POW " ;;
        9) echo "$CHR_90$POW " ;;
        10) echo "$CHR_100$POW " ;;
        *) echo "$CHR_00$POW " ;;
esac
}

if [[ "$(cut -c 1 < /sys/class/power_supply/BAT0/status)" = D ]]; then
    get_bat
else
    get_chr
fi

