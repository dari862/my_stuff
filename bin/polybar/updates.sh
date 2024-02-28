#!/usr/bin/env bash

## Copyright (C) 2020-2022 Aditya Shakya <adi1090x@gmail.com>
## Everyone is permitted to copy and distribute copies of this file under GNU-GPL3
Style="$1"
if [ "$Style" == "beach" ]
then
    BAR_ICON=""
    NOTIFY_ICON=/usr/share/DmDmDmdMdMdM/icons/dunst/updates.png
elif [ "$Style" == "forest" ] || [ "$Style" == "forest_large" ]
then
    BAR_ICON=""
    NOTIFY_ICON=/usr/share/DmDmDmdMdMdM/icons/dunst/updates.png
elif [ "$Style" == "hack" ] || [ "$Style" == "hack_large" ]
then
    NOTIFY_ICON=/usr/share/icons/Papirus/32x32/apps/system-software-update.svg
else
	NOTIFY_ICON=/usr/share/icons/Papirus/32x32/apps/system-software-update.svg
fi

get_total_updates() { UPDATES=$(apt list --upgradable -a  2>/dev/null | awk -F/ '{print $1}' | grep -v Listing... | sort -u | sed '/^$/d' | wc -l); }

while true; do
    get_total_updates

    # notify user of updates
    if hash notify-send &>/dev/null; then
        if (( UPDATES > 50 )); then
            notify-send -u critical -i $NOTIFY_ICON \
                "You really need to update!!" "$UPDATES New packages"
        elif (( UPDATES > 25 )); then
            notify-send -u normal -i $NOTIFY_ICON \
                "You should update soon" "$UPDATES New packages"
        elif (( UPDATES > 2 )); then
            notify-send -u low -i $NOTIFY_ICON \
                "$UPDATES New packages"
        fi
    fi

    # when there are updates available
    # every 10 seconds another check for updates is done
    while (( UPDATES > 0 )); do
        if (( UPDATES == 1 )); then
            echo " $UPDATES Update"
        elif (( UPDATES > 1 )); then
            echo " $UPDATES Updates"
        else
            echo "$BAR_ICON"
        fi
        sleep 10
        get_total_updates
    done

    # when no updates are available, use a longer loop, this saves on CPU
    # and network uptime, only checking once every 30 min for new updates
    while (( UPDATES == 0 )); do
        echo "$BAR_ICON"
        sleep 1800
        get_total_updates
    done
done
