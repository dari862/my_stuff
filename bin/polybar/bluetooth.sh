#!/bin/sh
if [ ! -d /sys/class/bluetooth ]; then
	echo # No Bluetooth interface
	exit 0
fi

bluetooth_print() {
    bluetoothctl | while read -r; do
        if service_manager is-active bluetooth.service; then
            echo "%{F#3b4252} %{F-}"
            devices_paired=$(bluetoothctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2)
            echo "$devices_paired" | while read -r line; do
                device_info=$(bluetoothctl info "$line")

                if echo "$device_info" | grep -q "Connected: yes"; then
                    echo "%{F#81a1c1} %{F-}"
                fi
            done
        else
            echo  "%{F#3b4252} %{F-}"
        fi
    done
}

if command -v bluetoothctl >/dev/null ;then
	paired_devices_cmd="devices Paired"
	# Check if an outdated version of bluetoothctl is used to preserve backwards compatibility
	if (( $(echo "$(bluetoothctl version | cut -d ' ' -f 2) < 5.65" | bc -l) )); then
		paired_devices_cmd="paired-devices"
	fi
	# Print Status
	print_status
fi
