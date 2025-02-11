#!/bin/sh
#             __ _       _     _            _              _   _
#  _ __ ___  / _(_)     | |__ | |_   _  ___| |_ ___   ___ | |_| |__
# | '__/ _ \| |_| |_____| '_ \| | | | |/ _ \ __/ _ \ / _ \| __| '_ \
# | | | (_) |  _| |_____| |_) | | |_| |  __/ || (_) | (_) | |_| | | |
# |_|  \___/|_| |_|     |_.__/|_|\__,_|\___|\__\___/ \___/ \__|_| |_|
#
# Author: Nick Clyde (clydedroid)
#
# A script that generates a rofi menu that uses bluetoothctl to
# connect to bluetooth devices and display status info.
#
# Inspired by networkmanager-dmenu (https://github.com/firecat53/networkmanager-dmenu)
# Thanks to x70b1 (https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/system-bluetooth-bluetoothctl)
#
# Depends on:
#   Arch repositories: rofi, bluez-utils (contains bluetoothctl)
if [ ! -d /sys/class/bluetooth ];then
	echo # No Bluetooth interface
	exit 0
elif ! command -v bluetoothctl >/dev/null ;then
	echo "bluetoothctl is missing"
	exit 1
fi

_option="${1-}"
_mac="${2-}"

# Checks if bluetooth controller is powered on
power_on() {
    if bluetoothctl show | grep -q "Powered: yes";then
        return 0
    else
        return 1
    fi
}

# Toggles power state
toggle_power() {
    if power_on;then
        bluetoothctl power off
        show_menu
    else
        if rfkill list bluetooth | grep -q 'blocked: yes';then
            rfkill unblock bluetooth && sleep 3
        fi
        bluetoothctl power on
        show_menu
    fi
}

# Checks if controller is scanning for new devices
scan_on() {
    if bluetoothctl show | grep -q "Discovering: yes";then
        echo "Scan: on"
        return 0
    else
        echo "Scan: off"
        return 1
    fi
}

# Toggles scanning state
toggle_scan() {
    if scan_on;then
        kill $(pgrep -f "bluetoothctl scan on")
        bluetoothctl scan off
        show_menu
    else
        bluetoothctl scan on &
        echo "Scanning..."
        sleep 5
        show_menu
    fi
}

# Checks if controller is able to pair to devices
pairable_on() {
    if bluetoothctl show | grep -q "Pairable: yes";then
        echo "Pairable: on"
        return 0
    else
        echo "Pairable: off"
        return 1
    fi
}

# Toggles pairable state
toggle_pairable() {
    if pairable_on;then
        bluetoothctl pairable off
        show_menu
    else
        bluetoothctl pairable on
        show_menu
    fi
}

# Checks if controller is discoverable by other devices
discoverable_on() {
    if bluetoothctl show | grep -q "Discoverable: yes";then
        echo "Discoverable: on"
        return 0
    else
        echo "Discoverable: off"
        return 1
    fi
}

# Toggles discoverable state
toggle_discoverable() {
    if discoverable_on;then
        bluetoothctl discoverable off
        show_menu
    else
        bluetoothctl discoverable on
        show_menu
    fi
}

# Checks if a device is connected
device_connected() {
    device_info=$(bluetoothctl info "${_mac}")
    if echo "$device_info" | grep -q "Connected: yes";then
        return 0
    else
        return 1
    fi
}

# Toggles device connection
toggle_connection() {
    if device_connected "${_mac}";then
        bluetoothctl disconnect "${_mac}"
        device_menu "$device"
    else
        bluetoothctl connect "${_mac}"
        device_menu "$device"
    fi
}

# Checks if a device is paired
device_paired() {
    device_info=$(bluetoothctl info "${_mac}")
    if echo "$device_info" | grep -q "Paired: yes";then
        echo "Paired: yes"
        return 0
    else
        echo "Paired: no"
        return 1
    fi
}

# Toggles device paired state
toggle_paired() {
    if device_paired "${_mac}";then
        bluetoothctl remove "${_mac}"
        device_menu "$device"
    else
        bluetoothctl pair "${_mac}"
        device_menu "$device"
    fi
}

# Checks if a device is trusted
device_trusted() {
    device_info=$(bluetoothctl info "${_mac}")
    if echo "$device_info" | grep -q "Trusted: yes";then
        echo "Trusted: yes"
        return 0
    else
        echo "Trusted: no"
        return 1
    fi
}

# Toggles device connection
toggle_trust() {
    if device_trusted "${_mac}";then
        bluetoothctl untrust "${_mac}"
        device_menu "$device"
    else
        bluetoothctl trust "${_mac}"
        device_menu "$device"
    fi
}

# Prints a short string with the current bluetooth status
# Useful for status bars like polybar, etc.
print_status() {
    if power_on;then
        printf ''

        paired_devices_cmd="devices Paired"
        # Check if an outdated version of bluetoothctl is used to preserve backwards compatibility
        bluetooth_version=$(bluetoothctl version | cut -d ' ' -f 2)
        if awk "BEGIN {if ($bluetooth_version < 5.65) exit 0}";then
            paired_devices_cmd="paired-devices"
        fi
		paired_devices=""
        bluetoothctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2 | while IFS= read -r device; do
    		paired_devices="$paired_devices $device"  # Add each device to the array
		done
        counter=0

        for device in ${paired_devices}; do
            if device_connected "$device";then
                device_alias=$(bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)

                if [ $counter -gt 0 ];then
                    printf ", %s" "$device_alias"
                else
                    printf " %s" "$device_alias"
                fi
				counter=$((counter + 1))
            fi
        done
        printf "\n"
    else
        echo ""
    fi
}

case "${_option}" in
    toggle_connection) toggle_connection;;
	device_paired)
		device_paired
		;;
	device_trusted) 
		device_trusted
		;;
	toggle_paired)
		toggle_paired
		;;
	toggle_trust)
		toggle_trust
		;;
	power_on)
		power_on
		;;
	scan_on)
		scan_on
		;;
	pairable_on)
		pairable_on
		;;
	discoverable_on)
		discoverable_on
		;;
	toggle_power)
		toggle_power
		;;
	toggle_scan)
		toggle_scan
		;;
	toggle_discoverable)
		toggle_discoverable
		;;
	toggle_pairable)
		toggle_pairable
		;;
    *)
        print_status
        ;;
esac
