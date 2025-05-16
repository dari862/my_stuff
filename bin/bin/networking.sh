#!/bin/bash
# if this line exist script will be part of hub script.
# Default Values

. "/usr/share/my_stuff/lib/common/WM"

rofi_network_manager_config="${script_config_path}/rofi-network-manager.ini"
languages_lib_dir="/usr/share/my_stuff/lib/languages/rofi-network-manager"
SELECTION_PREFIX="~"
WIRELESS_INTERFACES=($(nmcli device | awk '$2=="wifi" {print $1}'))
WIRELESS_INTERFACES_PRODUCT=()
WLAN_INT=0
WIRED_INTERFACES=($(nmcli device | awk '$2=="ethernet" {print $1}'))
WIRED_INTERFACES_PRODUCT=()

SELECTION="${1:-}"

initialization() {
	for i in "${WIRELESS_INTERFACES[@]}"; do WIRELESS_INTERFACES_PRODUCT+=("$(nmcli -f general.product device show "$i" | awk '{print $2}')"); done
	for i in "${WIRED_INTERFACES[@]}"; do WIRED_INTERFACES_PRODUCT+=("$(nmcli -f general.product device show "$i" | awk '{print $2}')"); done
	if wireless_interface_state;then
		ethernet_interface_state
	else
		echo "$0: failed to run wireless_interface_state functions."
		exit 1
	fi
}

wireless_interface_state() {
	if [[ ${#WIRELESS_INTERFACES[@]} -ne "0" ]]; then
		ACTIVE_SSID=$(nmcli device status | grep "^${WIRELESS_INTERFACES[WLAN_INT]}." | awk '{print $4}')
		WIFI_CON_STATE=$(nmcli device status | grep "^${WIRELESS_INTERFACES[WLAN_INT]}." | awk '{print $3}')
		if [[ "$WIFI_CON_STATE" == "unavailable" ]]; then
			WIFI_LIST="$SELECTION_WIFI_DISABLED"
			WIFI_SWITCH="${SELECTION_PREFIX}${SELECTION_WIFI_ON}"
			OPTIONS="${WIFI_LIST}\n${WIFI_SWITCH}\n${SELECTION_PREFIX}${SELECTION_SCAN}\n"
		else
			if [[ "$WIFI_CON_STATE" =~ "connected" ]]; then
				PROMPT=${WIRELESS_INTERFACES_PRODUCT[WLAN_INT]}[${WIRELESS_INTERFACES[WLAN_INT]}]
				WIFI_LIST=$(nmcli --fields IN-USE,SSID,SECURITY,BARS device wifi list ifname "${WIRELESS_INTERFACES[WLAN_INT]}" | awk -F'  +' '{ if (!seen[$2]++) print}' | sed "s/^IN-USE\s//g" | sed "/*/d" | sed "s/^ *//" | awk '$1!="--" {print}')
				if [[ "$ACTIVE_SSID" == "--" ]]; then
					WIFI_SWITCH="${SELECTION_PREFIX}${SELECTION_SCAN}\n${SELECTION_PREFIX}${SELECTION_MANUAL_HIDDEN}\n${SELECTION_PREFIX}${SELECTION_WIFI_OFF}"
				else
					WIFI_SWITCH="${SELECTION_PREFIX}${SELECTION_SCAN}\n${SELECTION_PREFIX}${SELECTION_DISCONECT}\n${SELECTION_PREFIX}${SELECTION_MANUAL_HIDDEN}\n${SELECTION_PREFIX}${SELECTION_WIFI_OFF}"
				fi
				OPTIONS="${WIFI_LIST}\n${WIFI_SWITCH}\n"
			fi
		fi
	fi
}

ethernet_interface_state() {
	if [[ ${#WIRED_INTERFACES[@]} -ne "0" ]]; then
		WIRED_CON_STATE=$(nmcli device status | grep "ethernet" | head -1 | awk '{print $3}')
		if [[ "$WIRED_CON_STATE" == "disconnected" ]]; then
			WIRED_SWITCH="${SELECTION_PREFIX}${SELECTION_ETH_ON}"
		elif [[ "$WIRED_CON_STATE" == "connected" ]]; then
			WIRED_SWITCH="${SELECTION_PREFIX}${SELECTION_ETH_OFF}"
		elif [[ "$WIRED_CON_STATE" == "unavailable" ]]; then
			WIRED_SWITCH="$SELECTION_ETH_UNAVAILBLE"
		elif [[ "$WIRED_CON_STATE" == "connecting" ]]; then
			WIRED_SWITCH="$SELECTION_ETH_INITIALIZING"
		fi
		OPTIONS="${OPTIONS}${WIRED_SWITCH}\n"
	fi
}

list_scan() {
	scan
	echo -e "${OPTIONS}"
}

ssid_manual() {
	if [ -n "$PASS" ];then
		connect "$SSID" "$PASS"
	else
		stored_connection "$SSID"
	fi
}

share_pass() {
	show_pass
	echo -e "SSID: ${SSID}\nPassword: ${PASSWORD}"
}

gen_qrcode() {
	show_pass
	gen_qrcode_file
	echo "$QRCODE_DIR$SSID.png"
}

vpn() {
	VPN_ACTION=${1:-}
	[ -n "$VPN_ACTION" ] && vpn_action
}

# main
. "${rofi_network_manager_config}"
. "/usr/share/my_stuff/lib/networking_lib.sh"

if [ -f "${languages_lib_dir}/${LANGUAGE}.lang" ];then
	. "${languages_lib_dir}/${LANGUAGE}.lang"
else
	. "${languages_lib_dir}/english.lang"
fi

initialization

case "$SELECTION" in
	--disconnect) disconnect "$NOTIFICATION_WIFI_TILE_TERMINATED" ;;
	--connect) ssid_manual ;;
	--scan) scan ;;
	--show-pass) share_pass ;;
	--hidden) connect2hiddenSSID ;;
	--change-wifi-state) change_wifi_state "$NOTIFICATION_WIFI_TILE" "$NOTIFICATION_WIFI_ENABLE" "on" ;;
	--change-wifi-state) change_wifi_state "$NOTIFICATION_WIFI_TILE" "$NOTIFICATION_WIFI_DISABLE" "off" ;;
	--change-eth-state) change_wired_state "$NOTIFICATION_WIRED_TITLE" "$NOTIFICATION_WIRED_DISBALE" "disconnect" "${WIRED_INTERFACES}" ;;
	--change-eth-state) change_wired_state "$NOTIFICATION_WIRED_TITLE" "$NOTIFICATION_WIRED_ENABLE" "connect" "${WIRED_INTERFACES}" ;;
	--restart) net_restart "$NOTIFICATION_NETWORK_TITLE" "$NOTIFICATION_NETWORK_RESTART" ;;
	--qrcode) gen_qrcode ;;
	--nm-editor) nm-connection-editor ;;
	--vpn) vpn ;;
esac

