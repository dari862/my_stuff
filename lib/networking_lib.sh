#!/bin/bash

WIRELESS_INTERFACES=($(nmcli device | awk '$2=="wifi" {print $1}'))
WIRELESS_INTERFACES_PRODUCT=()
WLAN_INT=0
WIRED_INTERFACES=($(nmcli device | awk '$2=="ethernet" {print $1}'))
WIRED_INTERFACES_PRODUCT=()

initialization() {
	for i in "${WIRELESS_INTERFACES[@]}"; do WIRELESS_INTERFACES_PRODUCT+=("$(nmcli -f general.product device show "$i" | awk '{print $2}')"); done
	for i in "${WIRED_INTERFACES[@]}"; do WIRED_INTERFACES_PRODUCT+=("$(nmcli -f general.product device show "$i" | awk '{print $2}')"); done
	change_interface_state
}

notification() {
	[[ "$NOTIFICATIONS_INIT" == "on" && -x "$(command -v notify-send)" ]] && notify-send -r "5" -u "normal" $1 "$2"
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

change_wifi_state() {
	notification "$1" "$2"
	nmcli radio wifi "$3"
}

change_wired_state() {
	notification "$1" "$2"
	nmcli device "$3" "$4"
}

net_restart() {
	notification "$1" "$2"
	nmcli networking off && sleep 3 && nmcli networking on
}

disconnect() {
	ACTIVE_SSID=$(nmcli -t -f GENERAL.CONNECTION dev show "${WIRELESS_INTERFACES[WLAN_INT]}" | cut -d ':' -f2)
	notification "$1" "$NOTIFICATION_WIFI_DISCONNECTED '$ACTIVE_SSID'"
	nmcli con down id "$ACTIVE_SSID"
}

check_wifi_connected() {
	[[ "$(nmcli device status | grep "^${WIRELESS_INTERFACES[WLAN_INT]}." | awk '{print $3}')" == "connected" ]] && disconnect "$NOTIFICATION_WIFI_TILE_TERMINATED"
}

connect() {
	check_wifi_connected
	notification "-t 0 $NOTIFICATION_WIFI_TILE" "$NOTIFICATION_WIFI_CONNECTING $1"
	if [[ $(nmcli dev wifi con "$1" password "$2" ifname "${WIRELESS_INTERFACES[WLAN_INT]}" | grep -c "successfully activated") -eq "1" ]]; then
		notification "$NOTIFICATION_WIFI_TILE_CONNECTION_OK" "$NOTIFICATION_WIFI_CONNECTED '$1'"
	else
		notification "$NOTIFICATION_WIFI_TILE_CONNECTION_ERROR" "$NOTIFICATION_WIFI_ERROR"
	fi
}

stored_connection() {
	check_wifi_connected
	notification "-t 0 $NOTIFICATION_WIFI_TILE" "$NOTIFICATION_WIFI_CONNECTING $1"
	if nmcli dev wifi con "$1" ifname "${WIRELESS_INTERFACES[WLAN_INT]}" | grep -q "successfully activated"; then
		notification "$NOTIFICATION_WIFI_TILE_CONNECTION_OK" "$NOTIFICATION_WIFI_CONNECTED '$1'"
	else
		notification "$NOTIFICATION_WIFI_TILE_CONNECTION_ERROR" "$NOTIFICATION_WIFI_ERROR"
	fi
}

UP_SAVEED_SSID(){
	nmcli con up "$SSID" ifname "${WIRELESS_INTERFACES[WLAN_INT]}"
}

interface_status() {
	local -n INTERFACES=$1
	local -n INTERFACES_PRODUCT=$2
	for i in "${!INTERFACES[@]}"; do
		CON_STATE=$(nmcli device status | grep "^${INTERFACES[$i]}." | awk '{print $3}')
		INT_NAME=${INTERFACES_PRODUCT[$i]}[${INTERFACES[$i]}]
		if [[ "$CON_STATE" == "connected" ]]; then
			STATUS="$INT_NAME:\n\t$(nmcli -t -f GENERAL.CONNECTION dev show "${INTERFACES[$i]}" | awk -F '[:]' '{print $2}') ~ $(nmcli -t -f IP4.ADDRESS dev show "${INTERFACES[$i]}" | awk -F '[:/]' '{print $2}')"
		else
			STATUS="$INT_NAME: ${CON_STATE^}"
		fi
		echo -e "${STATUS}"
	done
}

gen_qrcode_file(){
	[[ -e $QRCODE_DIR$SSID.png ]] || qrencode -t png -o $QRCODE_DIR$SSID.png -l H -s 25 -m 2 --dpi=192 "WIFI:S:""$SSID"";T:""$(nmcli dev wifi show-password | grep -oP '(?<=Security: ).*' | head -1)"";P:""$PASSWORD"";;"
}

show_pass() {
	SSID=$(nmcli dev wifi show-password | grep -oP '(?<=SSID: ).*' | head -1)
	PASSWORD=$(nmcli dev wifi show-password | grep -oP '(?<=Password: ).*' | head -1)
}

create_share_pass() {
	show_pass
	OPTIONS="SSID: ${SSID}\nPassword: ${PASSWORD}"
	[[ -x "$(command -v qrencode)" ]] && OPTIONS="${OPTIONS}\n${SELECTION_PREFIX}${SELECTION_QRCODE}"
}

change_interface_state() {
	if wireless_interface_state;then
		ethernet_interface_state
	else
		echo "$0: failed to run wireless_interface_state functions."
		exit 1
	fi
}

create_more_options() {
	OPTIONS=""
	if [[ "$WIFI_CON_STATE" == "connected" ]]; then
		OPTIONS="${SELECTION_PREFIX}${SELECTION_SHARE}\n"
	fi

	OPTIONS="${OPTIONS}${SELECTION_PREFIX}${SELECTION_STATUS}\n${SELECTION_PREFIX}${SELECTION_RESTAT_NETWORK}"

	if [[ $(nmcli -g NAME,TYPE connection | awk '/:vpn/' | sed 's/:vpn.*//g') ]]; then
		OPTIONS="${OPTIONS}\n${SELECTION_PREFIX}${SELECTION_VPN}"
	fi

	if [[ -x "$(command -v nm-connection-editor)" ]]; then
		OPTIONS="${OPTIONS}\n${SELECTION_PREFIX}${SELECTION_OPEN_EDITOR}"
	fi
}

change_status() {
	OPTIONS=""
	if [[ ${#WIRED_INTERFACES[@]} -ne "0" ]]; then
		ETH_STATUS="$(interface_status WIRED_INTERFACES WIRED_INTERFACES_PRODUCT)"
		OPTIONS="${OPTIONS}${ETH_STATUS}"
	fi

	if [[ ${#WIRELESS_INTERFACES[@]} -ne "0" ]]; then
		WLAN_STATUS="$(interface_status WIRELESS_INTERFACES WIRELESS_INTERFACES_PRODUCT)"
		if [[ -n ${OPTIONS} ]]; then
			OPTIONS="${OPTIONS}\n${WLAN_STATUS}"
		else
			OPTIONS="${OPTIONS}${WLAN_STATUS}"
		fi
	fi

	ACTIVE_VPN=$(nmcli -g NAME,TYPE con show --active | awk '/:vpn/' | sed 's/:vpn.*//g')
	if [[ -n $ACTIVE_VPN ]]; then
		OPTIONS="${OPTIONS}\n${ACTIVE_VPN}[VPN]: $(nmcli -g ip4.address con show "${ACTIVE_VPN}" | awk -F '[:/]' '{print $1}')"
	fi
}

vpn_status() {
	ACTIVE_VPN=$(nmcli -g NAME,TYPE con show --active | awk '/:vpn/' | sed 's/:vpn.*//g')
	if [[ $ACTIVE_VPN ]]; then
		OPTIONS="${SELECTION_PREFIX}${SELECTION_DISCONECT} $ACTIVE_VPN"
	else
		OPTIONS="$(nmcli -g NAME,TYPE connection | awk '/:vpn/' | sed 's/:vpn.*//g')"
	fi
}

vpn_action() {
	if [[ -n "$VPN_ACTION" ]]; then
		if [[ "$VPN_ACTION" =~ "${SELECTION_PREFIX}${SELECTION_DISCONECT}" ]]; then
			nmcli connection down "$ACTIVE_VPN"
			notification "$NOTIFICATION_VPN_TITLE_DEACTIVE" "$ACTIVE_VPN"
		else
			notification "-t 0 $NOTIFICATION_VPN_TITLE_ACTIVATING" "$VPN_ACTION"
			VPN_OUTPUT=$(nmcli connection up "$VPN_ACTION" 2>/dev/null)
			if [[ $(echo "$VPN_OUTPUT" | grep -c "Connection successfully activated") -eq "1" ]]; then
				notification "$NOTIFICATION_VPN_TITLE_OK" "$VPN_ACTION"
			else
				notification "$NOTIFICATION_VPN_TITLE_ERROR" "$NOTIFICATION_VPN_CHECK $VPN_ACTION"
			fi
		fi
	fi
}

scan() {
	[[ "$WIFI_CON_STATE" =~ "unavailable" ]] && change_wifi_state "Wi-Fi" "$NOTIFICATION_WIFI_ENABLE" "on" && sleep 2
	notification "-t 0 ${NOTIFICATION_WIFI_TILE}" "$NOTIFICATION_WIFI_SCANNING"
	WIFI_LIST=$(nmcli --fields IN-USE,SSID,SECURITY,BARS device wifi list ifname "${WIRELESS_INTERFACES[WLAN_INT]}" --rescan yes | awk -F'  +' '{ if (!seen[$2]++) print}' | sed "s/^IN-USE\s//g" | sed "/*/d" | sed "s/^ *//" | awk '$1!="--" {print}')
	change_interface_state
	notification "-t 1 Wifi" "$NOTIFICATION_WIFI_SCANNING"
}

connect2hiddenSSID() {
	SSID="${1:-}"
	PASS="${2:-}"
	if [[ -n "$PASS" ]]; then
		nmcli con add type wifi con-name "$SSID" ssid "$SSID" ifname "${WIRELESS_INTERFACES[WLAN_INT]}"
		nmcli con modify "$SSID" wifi-sec.key-mgmt wpa-psk
		nmcli con modify "$SSID" wifi-sec.psk "$PASS"
	elif [[ $(nmcli -g NAME con show | grep -c "$SSID") -eq "0" ]]; then
		nmcli con add type wifi con-name "$SSID" ssid "$SSID" ifname "${WIRELESS_INTERFACES[WLAN_INT]}"
	fi
	notification "-t 0 ${NOTIFICATION_WIFI_TILE}" "$NOTIFICATION_WIFI_CONNECTING $SSID"
	if [[ $(nmcli con up id "$SSID" | grep -c "successfully activated") -eq "1" ]]; then
		notification "$NOTIFICATION_WIFI_TILE_CONNECTION_OK" "$NOTIFICATION_WIFI_CONNECTED '$SSID'"
	else
		notification "$NOTIFICATION_WIFI_TILE_CONNECTION_ERROR" "$NOTIFICATION_WIFI_ERROR"
	fi
}
