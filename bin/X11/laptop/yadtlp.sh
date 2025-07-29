#!/bin/bash
# if this line exist script will be part of gui scripts.new_name=GUI_TLP

__config_path="/etc/tlp.conf"
__tlp_version_="$(tlp-stat -s | head -1)"

. "/usr/share/my_stuff/lib/languages/tlp/yadtlp_configdescriptions"

check_4_dependencies_if_installed tlp || exit 1

if [ -f "$__config_path" ];then
	source <(sed '/^# /d;/^#!/d;s/#//g' "$__config_path")
else
	yad --form --width="200" --height="100" --field="$__config_path does not exist:LBL" >/dev/null 2>&1
	exit
fi


if [[ "$__tlp_version_" = *"1.7"* ]];then
	__tlp_version_="1.7"
elif [[ "$__tlp_version_" = *"1.6"* ]];then
	__tlp_version_="1.6"
elif [[ "$__tlp_version_" = *"1.5"* ]];then
	__tlp_version_="1.5"
elif [[ "$__tlp_version_" = *"1.4"* ]];then
	__tlp_version_="1.4"
elif [[ "$__tlp_version_" = *"1.3"* ]];then
	__tlp_version_="1.3"
fi


if [[ "${TLP_ENABLE}" == "1" ]];then
	TLP_ENABLE=TRUE
else
	TLP_ENABLE=FALSE
fi
if [[ "${BAY_POWEROFF_ON_AC}" == "1" ]];then
	BAY_POWEROFF_ON_AC=TRUE
else
	BAY_POWEROFF_ON_AC=FALSE
fi
if [[ "${BAY_POWEROFF_ON_BAT}" == "1" ]];then
	BAY_POWEROFF_ON_BAT=TRUE
else
	BAY_POWEROFF_ON_BAT=FALSE
fi
if [[ "${CPU_BOOST_ON_AC}" == "1" ]];then
	CPU_BOOST_ON_AC=TRUE
else
	CPU_BOOST_ON_AC=FALSE
fi
if [[ "${CPU_BOOST_ON_BAT}" == "1" ]];then
	CPU_BOOST_ON_BAT=TRUE
else
	CPU_BOOST_ON_BAT=FALSE
fi
if [[ "$__tlp_version_" != "1.3" ]];then
	if [[ "${CPU_HWP_DYN_BOOST_ON_AC}" == "1" ]];then
		CPU_HWP_DYN_BOOST_ON_AC=TRUE
	else
		CPU_HWP_DYN_BOOST_ON_AC=FALSE
	fi
	if [[ "${CPU_HWP_DYN_BOOST_ON_BAT}" == "1" ]];then
		CPU_HWP_DYN_BOOST_ON_BAT=TRUE
	else
		CPU_HWP_DYN_BOOST_ON_BAT=FALSE
	fi
fi

if [[ "$__tlp_version_" = "1.5" ]] || [[ "$__tlp_version_" = "1.4" ]] || [[ "$__tlp_version_" = "1.3" ]];then
	if [[ "${SCHED_POWERSAVE_ON_AC}" == "1" ]];then
		SCHED_POWERSAVE_ON_AC=TRUE
	else
		SCHED_POWERSAVE_ON_AC=FALSE
	fi	
	if [[ "${SCHED_POWERSAVE_ON_BAT}" == "1" ]];then
		SCHED_POWERSAVE_ON_BAT=TRUE
	else
		SCHED_POWERSAVE_ON_BAT=FALSE
	fi
fi

if [[ "${NMI_WATCHDOG}" == "1" ]];then
	NMI_WATCHDOG=TRUE
else
	NMI_WATCHDOG=FALSE
fi
if [[ "${RESTORE_DEVICE_STATE_ON_STARTUP}" == "1" ]];then
	RESTORE_DEVICE_STATE_ON_STARTUP=TRUE
else
	RESTORE_DEVICE_STATE_ON_STARTUP=FALSE
fi
if [[ "${USB_AUTOSUSPEND}" == "1" ]];then
	USB_AUTOSUSPEND=TRUE
else
	USB_AUTOSUSPEND=FALSE
fi
if [[ "${USB_EXCLUDE_AUDIO}" == "1" ]];then
	USB_EXCLUDE_AUDIO=TRUE
else
	USB_EXCLUDE_AUDIO=FALSE
fi
if [[ "$__tlp_version_" != "1.3" ]];then
	if [[ "${USB_EXCLUDE_BTUSB}" == "1" ]];then
		USB_EXCLUDE_BTUSB=TRUE
	else
		USB_EXCLUDE_BTUSB=FALSE
	fi
	if [[ "${USB_EXCLUDE_PHONE}" == "1" ]];then
		USB_EXCLUDE_PHONE=TRUE
	else
		USB_EXCLUDE_PHONE=FALSE
	fi
	if [[ "${USB_EXCLUDE_PRINTER}" == "1" ]];then
		USB_EXCLUDE_PRINTER=TRUE
	else
		USB_EXCLUDE_PRINTER=FALSE
	fi
	if [[ "${USB_EXCLUDE_WWAN}" == "1" ]];then
		USB_EXCLUDE_WWAN=TRUE
	else
		USB_EXCLUDE_WWAN=FALSE
	fi
else
	if [[ "${USB_BLACKLIST_BTUSB}" == "1" ]];then
		USB_BLACKLIST_BTUSB=TRUE
	else
		USB_BLACKLIST_BTUSB=FALSE
	fi
	if [[ "${USB_BLACKLIST_PHONE}" == "1" ]];then
		USB_BLACKLIST_PHONE=TRUE
	else
		USB_BLACKLIST_PHONE=FALSE
	fi
	if [[ "${USB_BLACKLIST_PRINTER}" == "1" ]];then
		USB_BLACKLIST_PRINTER=TRUE
	else
		USB_BLACKLIST_PRINTER=FALSE
	fi
	if [[ "${USB_BLACKLIST_WWAN}" == "1" ]];then
		USB_BLACKLIST_WWAN=TRUE
	else
		USB_BLACKLIST_WWAN=FALSE
	fi
fi
if [[ "$__tlp_version_" != "1.7" ]];then
	if [[ "${USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN}" == "1" ]];then
		USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN=TRUE
	else
		USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN=FALSE
	fi
fi
if [[ "${RESTORE_THRESHOLDS_ON_BAT}" == "1" ]];then
	RESTORE_THRESHOLDS_ON_BAT=TRUE
else
	RESTORE_THRESHOLDS_ON_BAT=FALSE
fi
if [[ "${NATACPI_ENABLE}" == "1" ]];then
	NATACPI_ENABLE=TRUE
else
	NATACPI_ENABLE=FALSE
fi
if [[ "${TPACPI_ENABLE}" == "1" ]];then
	TPACPI_ENABLE=TRUE
else
	TPACPI_ENABLE=FALSE
fi
if [[ "${TPSMAPI_ENABLE}" == "1" ]];then
	TPSMAPI_ENABLE=TRUE
else
	TPSMAPI_ENABLE=FALSE
fi
if [[ "${SOUND_POWER_SAVE_CONTROLLER}" == "Y" ]];then
	SOUND_POWER_SAVE_CONTROLLER=TRUE
else
	SOUND_POWER_SAVE_CONTROLLER=FALSE
fi
if [[ "${AHCI_RUNTIME_PM_ON_AC}" == "auto" ]];then
	AHCI_RUNTIME_PM_ON_AC=TRUE
else
	AHCI_RUNTIME_PM_ON_AC=FALSE
fi
if [[ "${AHCI_RUNTIME_PM_ON_BAT}" == "auto" ]];then
	AHCI_RUNTIME_PM_ON_BAT=TRUE
else
	AHCI_RUNTIME_PM_ON_BAT=FALSE
fi
if [[ "${WIFI_PWR_ON_AC}" == "on" ]];then
	WIFI_PWR_ON_AC=TRUE
else
	WIFI_PWR_ON_AC=FALSE
fi
if [[ "${WIFI_PWR_ON_BAT}" == "on" ]];then
	WIFI_PWR_ON_BAT=TRUE
else
	WIFI_PWR_ON_BAT=FALSE
fi
if [[ "${WOL_DISABLE}" == "Y" ]];then
	WOL_DISABLE=TRUE
else
	WOL_DISABLE=FALSE
fi
if [[ "${RUNTIME_PM_ON_AC}" == "auto" ]];then
	RUNTIME_PM_ON_AC=TRUE
else
	RUNTIME_PM_ON_AC=FALSE
fi
if [[ "${RUNTIME_PM_ON_BAT}" == "auto" ]];then
	RUNTIME_PM_ON_BAT=TRUE
else
	RUNTIME_PM_ON_BAT=FALSE
fi
KEY=$RANDOM

export temp_dir=$(mktemp -d /tmp/$USER/yadtlp-XXXXXXXX)

General="${temp_dir}/General"
Audio="${temp_dir}/Audio"
Disks="${temp_dir}/Disks"
Graphics="${temp_dir}/Graphics"
Network="${temp_dir}/Network"
PCIe="${temp_dir}/PCIe"
Processor="${temp_dir}/Processor"
Radio="${temp_dir}/Radio"
USB="${temp_dir}/USB"
ThinkPad_Battery="${temp_dir}/ThinkPad_Battery"
out="${temp_dir}/out"
__temp_config_path="${temp_dir}/config"
__check_file="${temp_dir}/check_file"

export buttons_variables="${temp_dir}/buttons_variables"

__add_usb="!\"USB\""
__numeric_START_CHARGE_THRESH_0_="${START_CHARGE_THRESH_BAT0}!0..99!1"
__numeric_STOP_CHARGE_THRESH_0_="${STOP_CHARGE_THRESH_BAT0}!0..100!1"
__numeric_START_CHARGE_THRESH_1_="${START_CHARGE_THRESH_BAT1}!0..99!1"
__numeric_STOP_CHARGE_THRESH_1_="${STOP_CHARGE_THRESH_BAT1}!0..100!1"

if [[ "$__tlp_version_" = "1.4" ]];then
	__add_usb=""
elif [[ "$__tlp_version_" = "1.3" ]];then
	__add_usb=""
	__numeric_START_CHARGE_THRESH_0_="${START_CHARGE_THRESH_BAT0}!1..96!1"
	__numeric_STOP_CHARGE_THRESH_0_="${STOP_CHARGE_THRESH_BAT0}!5..100!1"
	__numeric_START_CHARGE_THRESH_1_="${START_CHARGE_THRESH_BAT1}!1..96!1"
	__numeric_STOP_CHARGE_THRESH_1_="${STOP_CHARGE_THRESH_BAT1}!5..100!1"
	USB_ALLOWLIST="$USB_WHITELIST"
	RUNTIME_PM_DRIVER_DENYLIST="$RUNTIME_PM_DRIVER_BLACKLIST"
	SATA_LINKPWR_DENYLIST="$SATA_LINKPWR_BLACKLIST"
	RUNTIME_PM_DENYLIST="$RUNTIME_PM_BLACKLIST"
	USB_DENYLIST="$USB_BLACKLIST"
	USB_EXCLUDE_BTUSB="$USB_BLACKLIST_BTUSB"
	USB_EXCLUDE_PHONE="$USB_BLACKLIST_PHONE"
	USB_EXCLUDE_PRINTER="$USB_BLACKLIST_PRINTER"
	USB_EXCLUDE_WWAN="$USB_BLACKLIST_WWAN"
fi

echo "DISK_DEVICES=\"${DISK_DEVICES}\"" > "${buttons_variables}"
echo "SATA_LINKPWR_ON_AC=\"${SATA_LINKPWR_ON_AC}\"" >> "${buttons_variables}"
echo "SATA_LINKPWR_ON_BAT=\"${SATA_LINKPWR_ON_BAT}\"" >> "${buttons_variables}"
[[ "$__tlp_version_" != "1.3" ]] && echo "DISK_APM_CLASS_DENYLIST=\"${DISK_APM_CLASS_DENYLIST}\"" >> "${buttons_variables}"
echo "RUNTIME_PM_DENYLIST=\"${RUNTIME_PM_DENYLIST}\"" >> "${buttons_variables}"
echo "USB_DENYLIST=\"${USB_DENYLIST}\"" >> "${buttons_variables}"
echo "USB_ALLOWLIST=\"${USB_ALLOWLIST}\"" >> "${buttons_variables}"
echo "DISK_APM_LEVEL_ON_AC=\"${DISK_APM_LEVEL_ON_AC}\"" >> "${buttons_variables}"
echo "DISK_APM_LEVEL_ON_BAT=\"${DISK_APM_LEVEL_ON_BAT}\"" >> "${buttons_variables}"
echo "DISK_SPINDOWN_TIMEOUT_ON_AC=\"${DISK_SPINDOWN_TIMEOUT_ON_AC}\"" >> "${buttons_variables}"
echo "DISK_SPINDOWN_TIMEOUT_ON_BAT=\"${DISK_SPINDOWN_TIMEOUT_ON_BAT}\"" >> "${buttons_variables}"
echo "DISK_IOSCHED=\"${DISK_IOSCHED}\"" >> "${buttons_variables}"

mapfile -t __lsblk_list_output  < <( lsblk -d | tail -n+2 | cut -d" " -f1)
export __lsblk_list="${__lsblk_list_output[@]}"
INTRO_TXT="TLP $__tlp_version_ - $__config_path"

# cleanup
trap "rm -rdf ${temp_dir}" EXIT

main_yad(){
	#  - name: General
	yad_opts=()
	yad_opts=(--scroll --plug=$KEY --tabnum=1 --borders=10 
	--image=/usr/share/icons/hicolor/128x128/apps/mbcc.png
	--columns=1 --form  )
    yad_opts+=( --field="TLP ENABLE ${TLP_ENABLE__ID_DESCRIPTION}:CHK" "${TLP_ENABLE}")
    [[ "$__tlp_version_" != "1.3" ]] && yad_opts+=(--field="TLP WARN LEVEL ${TLP_WARN_LEVEL__ID_DESCRIPTION}:cb" "${TLP_WARN_LEVEL}!0!1!2!3")
    yad_opts+=( --field="TLP DEFAULT MODE ${TLP_DEFAULT_MODE__ID_DESCRIPTION}:cb" "${TLP_DEFAULT_MODE}!AC!BAT")
    yad_opts+=( --field="TLP PERSISTEN DEFAULT ${TLP_PERSISTENT_DEFAULT__ID_DESCRIPTION}:cb" "${TLP_PERSISTENT_DEFAULT}!0!1")
    yad_opts+=( --field="TLP PS IGNORE ${TLP_PS_IGNORE__ID_DESCRIPTION}:cb" "\"${TLP_PS_IGNORE}\"!\"AC\"$__add_usb!\"BAT\"")
	yad "${yad_opts[@]}" > "$General" &
	
	#  - name: Audio
	yad_opts=()
	yad_opts=(--scroll --plug=$KEY --tabnum=2 --borders=10
	--image=/usr/share/icons/hicolor/128x128/apps/mbcc.png
	--columns=1 --form)
    yad_opts+=( --field="SOUND POWER SAVE ON AC ${SOUND_POWER_SAVE__GROUP_DESCRIPTION}::NUM" "$SOUND_POWER_SAVE_ON_AC"!0..3600!1)
    yad_opts+=( --field="SOUND POWER SAVE ON_BAT ${SOUND_POWER_SAVE__GROUP_DESCRIPTION}::NUM" "$SOUND_POWER_SAVE_ON_BAT"!0..3600!1)
    yad_opts+=( --field="SOUND POWER SAVE CONTROLLER ${SOUND_POWER_SAVE_CONTROLLER__ID_DESCRIPTION}:CHK" "${SOUND_POWER_SAVE_CONTROLLER}")
	yad "${yad_opts[@]}" > "$Audio" &
	
	#  - name: Disks
	yad_opts=()
	yad_opts=(--scroll --plug=$KEY --tabnum=3 --borders=10
	--image=/usr/share/icons/hicolor/128x128/apps/mbcc.png
	--columns=1 --form)
    yad_opts+=( --field="DISK IDLE SECS ON AC ${DISK_IDLE_SECS__GROUP_DESCRIPTION}::NUM" "$DISK_IDLE_SECS_ON_AC"!0..1000!1)
    yad_opts+=( --field="DISK IDLE SECS ON BAT ${DISK_IDLE_SECS__GROUP_DESCRIPTION}::NUM" "$DISK_IDLE_SECS_ON_BAT"!0..1000!1)
    yad_opts+=( --field="MAX LOST WORK SECS ON AC ${MAX_LOST_WORK_SECS__GROUP_DESCRIPTION}::NUM" "$MAX_LOST_WORK_SECS_ON_AC"!0..10000!1)
    yad_opts+=( --field="MAX LOST WORK SECS ON BAT ${MAX_LOST_WORK_SECS__GROUP_DESCRIPTION}::NUM" "$MAX_LOST_WORK_SECS_ON_BAT"!0..10000!1)
    yad_opts+=( --field="DISK DEVICES!gtk-yes!${DISK_DEVICES__ID_DESCRIPTION}:FBTN" "bash -c _DISK_DEVICES")
    yad_opts+=( --field="DISK APM LEVEL ON AC!gtk-yes!${DISK_APM_LEVEL__GROUP_DESCRIPTION}:FBTN" "bash -c _DISK_APM_LEVEL_ON_AC")
    yad_opts+=( --field="DISK APM LEVEL ON BAT!gtk-yes!${DISK_APM_LEVEL__GROUP_DESCRIPTION}:FBTN" "bash -c _DISK_APM_LEVEL_ON_BAT")
	[[ "$__tlp_version_" != "1.3" ]] && yad_opts+=(--field="DISK APM CLASS DENYLIST!gtk-yes!${DISK_APM_CLASS_DENYLIST__ID_DESCRIPTION}:FBTN" "bash -c _DISK_APM_CLASS_DENYLIST")
    yad_opts+=( --field="DISK SPINDOWN TIMEOUT ON AC!gtk-yes!${DISK_SPINDOWN_TIMEOUT__GROUP_DESCRIPTION}:FBTN" "bash -c _DISK_SPINDOWN_TIMEOUT_ON_AC")
    yad_opts+=( --field="DISK SPINDOWN TIMEOUT ON BAT!gtk-yes!${DISK_SPINDOWN_TIMEOUT__GROUP_DESCRIPTION}:FBTN" "bash -c _DISK_SPINDOWN_TIMEOUT_ON_BAT")
    yad_opts+=( --field="DISK IOSCHED!gtk-yes!${DISK_IOSCHED__ID_DESCRIPTION}:FBTN" "bash -c _DISK_IOSCHED")
    yad_opts+=( --field="SATA LINKPWR ON AC!gtk-yes!${SATA_LINKPWR__GROUP_DESCRIPTION}:FBTN" "bash -c _SATA_LINKPWR_ON_AC")
    yad_opts+=( --field="SATA LINKPWR ON BAT!gtk-yes!${SATA_LINKPWR__GROUP_DESCRIPTION}:FBTN" "bash -c _SATA_LINKPWR_ON_BAT")
    yad_opts+=( --field="SATA LINKPWR DENYLIST ${SATA_LINKPWR_DENYLIST__ID_DESCRIPTION}" "$SATA_LINKPWR_DENYLIST")
    yad_opts+=( --field="AHCI RUNTIME PM ON AC ${AHCI_RUNTIME_PM__GROUP_DESCRIPTION}:CHK" "${AHCI_RUNTIME_PM_ON_AC}")
    yad_opts+=( --field="AHCI RUNTIME PM ON BAT ${AHCI_RUNTIME_PM__GROUP_DESCRIPTION}:CHK" "${AHCI_RUNTIME_PM_ON_BAT}")
    yad_opts+=( --field="AHCI RUNTIME PM TIMEOUT ${AHCI_RUNTIME_PM_TIMEOUT__ID_DESCRIPTION}::NUM" "$AHCI_RUNTIME_PM_TIMEOUT"!0..10000!1)
    yad_opts+=( --field="BAY POWEROFF ON AC ${BAY_POWEROFF_ON_BAT__ID_DESCRIPTION}:CHK" "${BAY_POWEROFF_ON_AC}")
    yad_opts+=( --field="BAY POWEROFF ON BAT ${BAY_POWEROFF_ON_BAT__ID_DESCRIPTION}:CHK" "${BAY_POWEROFF_ON_BAT}")
    yad_opts+=( --field="BAY DEVICE ${BAY_DEVICE__ID_DESCRIPTION}" "$BAY_DEVICE")
	yad "${yad_opts[@]}" > "$Disks" &
	
	#  - name: Graphics
	yad_opts=()
	yad_opts=(--scroll --plug=$KEY --tabnum=4 --borders=10
	--image=/usr/share/icons/hicolor/128x128/apps/mbcc.png
	--columns=1 --form)
    yad_opts+=( --field="INTEL GPU MIN FREQ ON_AC ${INTEL_GPU_FREQ__GROUP_DESCRIPTION}::NUM" "$INTEL_GPU_MIN_FREQ_ON_AC"!0..5000!1)
    yad_opts+=( --field="INTEL GPU MIN FREQ ON_BAT ${INTEL_GPU_FREQ__GROUP_DESCRIPTION}::NUM" "$INTEL_GPU_MIN_FREQ_ON_BAT"!0..5000!1)
    yad_opts+=( --field="INTEL GPU MAX FREQ ON_AC ${INTEL_GPU_FREQ__GROUP_DESCRIPTION}::NUM" "$INTEL_GPU_MAX_FREQ_ON_AC"!0..5000!1)
    yad_opts+=( --field="INTEL GPU MAX FREQ ON_BAT ${INTEL_GPU_FREQ__GROUP_DESCRIPTION}::NUM" "$INTEL_GPU_MAX_FREQ_ON_BAT"!0..5000!1)
    yad_opts+=( --field="INTEL GPU BOOST FREQ ON_AC ${INTEL_GPU_FREQ__GROUP_DESCRIPTION}::NUM" "$INTEL_GPU_BOOST_FREQ_ON_AC"!0..5000!1)
    yad_opts+=( --field="INTEL GPU BOOST FREQ ON_BAT ${INTEL_GPU_FREQ__GROUP_DESCRIPTION}::NUM" "$INTEL_GPU_BOOST_FREQ_ON_BAT"!0..5000!1)
    yad_opts+=( --field="RADEON POWER PROFILE ON AC ${RADEON_POWER_PROFILE__GROUP_DESCRIPTION}:cb" "${RADEON_POWER_PROFILE_ON_AC}!low!mid!high!auto!default")
    yad_opts+=( --field="RADEON POWER PROFILE ON BAT ${RADEON_POWER_PROFILE__GROUP_DESCRIPTION}:cb" "${RADEON_POWER_PROFILE_ON_BAT}!low!mid!high!auto!default")
    yad_opts+=( --field="RADEON DPM STATE ON AC ${RADEON_DPM_STATE__GROUP_DESCRIPTION}:cb" "${RADEON_DPM_STATE_ON_AC}!battery!performance")
    yad_opts+=( --field="RADEON DPM STATE ON BAT ${RADEON_DPM_STATE__GROUP_DESCRIPTION}:cb" "${RADEON_DPM_STATE_ON_BAT}!battery!performance")
    yad_opts+=( --field="RADEON DPM PERF LEVEL ON AC ${RADEON_DPM_PERF_LEVEL__GROUP_DESCRIPTION}:cb" "${RADEON_DPM_PERF_LEVEL_ON_AC}!auto!low!high")
    yad_opts+=( --field="RADEON DPM PERF LEVEL ON BAT ${RADEON_DPM_PERF_LEVEL__GROUP_DESCRIPTION}:cb" "${RADEON_DPM_PERF_LEVEL_ON_BAT}!auto!low!high")
	yad "${yad_opts[@]}" > "$Graphics" &
	
	#  - name: Network
	yad_opts=()
	yad_opts=(--scroll --plug=$KEY --tabnum=5 --borders=10
	--image=/usr/share/icons/hicolor/128x128/apps/mbcc.png
	--columns=1 --form)
    yad_opts+=( --field="WIFI PWR ON AC ${WIFI_PWR__GROUP_DESCRIPTION}:CHK" "${WIFI_PWR_ON_AC}")
    yad_opts+=( --field="WIFI PWR ON BAT ${WIFI_PWR__GROUP_DESCRIPTION}:CHK" "${WIFI_PWR_ON_BAT}")
    yad_opts+=( --field="WOL DISABLE ${WOL_DISABLE__ID_DESCRIPTION}:CHK" "${WOL_DISABLE}")
	yad "${yad_opts[@]}" > "$Network" &
	
	#  - name: PCIe
	yad_opts=()
	yad_opts=(--scroll --plug=$KEY --tabnum=6 --borders=10
	--image=/usr/share/icons/hicolor/128x128/apps/mbcc.png
	--columns=1 --form)
    yad_opts+=( --field="PCIE ASPM ON AC ${PCIE_ASPM__GROUP_DESCRIPTION}:cb" "${PCIE_ASPM_ON_AC}!default!performance!powersave!powersupersave")
    yad_opts+=( --field="PCIE ASPM ON BAT ${PCIE_ASPM__GROUP_DESCRIPTION}:cb" "${PCIE_ASPM_ON_BAT}!default!performance!powersave!powersupersave")
    yad_opts+=( --field="RUNTIME PM ON AC ${RUNTIME_PM__GROUP_DESCRIPTION}:CHK" "${RUNTIME_PM_ON_AC}")
    yad_opts+=( --field="RUNTIME PM ON BAT ${RUNTIME_PM__GROUP_DESCRIPTION}:CHK" "${RUNTIME_PM_ON_BAT}")
    yad_opts+=( --field="RUNTIME PM DENYLIST!gtk-yes!${RUNTIME_PM_DENYLIST__ID_DESCRIPTION}:FBTN" "bash -c _RUNTIME_PM_DENYLIST")
    yad_opts+=( --field="RUNTIME PM DRIVER DENYLIST ${RUNTIME_PM_DRIVER_BLACKLIST__ID_DESCRIPTION}" "$RUNTIME_PM_DRIVER_DENYLIST")
    [[ "$__tlp_version_" != "1.3" ]] && yad_opts+=(--field="RUNTIME PM ENABLE ${RUNTIME_PM_GROUP__ID_DESCRIPTION}" "$RUNTIME_PM_ENABLE")
	[[ "$__tlp_version_" != "1.3" ]] && yad_opts+=(--field="RUNTIME PM DISABLE ${RUNTIME_PM_GROUP__ID_DESCRIPTION}" "$RUNTIME_PM_DISABLE")
	yad "${yad_opts[@]}" > "$PCIe" &
	
	#  - name: Processor
	yad_opts=()
	yad_opts=(--scroll --plug=$KEY --tabnum=7 --borders=10
	--image=/usr/share/icons/hicolor/128x128/apps/mbcc.png
	--columns=1 --form)
	if [[ "$__tlp_version_" = "1.7" ]] || [[ "$__tlp_version_" = "1.6" ]];then
		yad_opts+=(--field="CPU DRIVER OPMODE ON AC ${CPU_DRIVER_OPMODE__GROUP_DESCRIPTION}:cb" "${CPU_DRIVER_OPMODE_ON_AC}!active!passive!guided")
		yad_opts+=(--field="CPU DRIVER OPMODE ON BAT ${CPU_DRIVER_OPMODE__GROUP_DESCRIPTION}:cb" "${CPU_DRIVER_OPMODE_ON_BAT}!active!passive!guided")
	fi
    yad_opts+=( --field="CPU SCALING GOVERNOR_ON AC ${CPU_SCALING_GOVERNOR__GROUP_DESCRIPTION}:cb" "${CPU_SCALING_GOVERNOR_ON_AC}!ondemand!powersave!performance!conservative!schedutil")
    yad_opts+=( --field="CPU SCALING GOVERNOR_ON BAT ${CPU_SCALING_GOVERNOR__GROUP_DESCRIPTION}:cb" "${CPU_SCALING_GOVERNOR_ON_BAT}!ondemand!powersave!performance!conservative!schedutil")
    yad_opts+=( --field="CPU SCALING MIN FREQ ON AC ${CPU_SCALING_FREQ__GROUP_DESCRIPTION}" "$CPU_SCALING_MIN_FREQ_ON_AC")
    yad_opts+=( --field="CPU SCALING MAX FREQ ON AC ${CPU_SCALING_FREQ__GROUP_DESCRIPTION}" "$CPU_SCALING_MAX_FREQ_ON_AC")
    yad_opts+=( --field="CPU SCALING MIN FREQ ON BAT ${CPU_SCALING_FREQ__GROUP_DESCRIPTION}" "$CPU_SCALING_MIN_FREQ_ON_BAT")
    yad_opts+=( --field="CPU SCALING MAX FREQ ON BAT ${CPU_SCALING_FREQ__GROUP_DESCRIPTION}" "$CPU_SCALING_MAX_FREQ_ON_BAT")
    yad_opts+=( --field="CPU ENERGY PERF POLICY ON AC ${CPU_ENERGY_PERF_POLICY__GROUP_DESCRIPTION}:cb" "${CPU_ENERGY_PERF_POLICY_ON_AC}!default!performance!balance_performance!balance_power")
    yad_opts+=( --field="CPU ENERGY PERF POLICY ON BAT ${CPU_ENERGY_PERF_POLICY__GROUP_DESCRIPTION}:cb" "${CPU_ENERGY_PERF_POLICY_ON_BAT}!default!performance!balance_performance!balance_power")
    yad_opts+=( --field="CPU MIN PERF ON AC ${CPU_PERF__GROUP_DESCRIPTION}::NUM" "$CPU_MIN_PERF_ON_AC"!0..100!1)
    yad_opts+=( --field="CPU MAX PERF ON AC ${CPU_PERF__GROUP_DESCRIPTION}::NUM" "$CPU_MAX_PERF_ON_AC"!0..100!1)
    yad_opts+=( --field="CPU MIN PERF ON BAT ${CPU_PERF__GROUP_DESCRIPTION}::NUM" "$CPU_MIN_PERF_ON_BAT"!0..100!1)
    yad_opts+=( --field="CPU MAX PERF ON BAT ${CPU_PERF__GROUP_DESCRIPTION}::NUM" "$CPU_MAX_PERF_ON_BAT"!0..100!1)
    yad_opts+=( --field="CPU BOOST ON AC ${CPU_BOOST__GROUP_DESCRIPTION}:CHK" "${CPU_BOOST_ON_AC}")
    yad_opts+=( --field="CPU BOOST ON BAT ${CPU_BOOST__GROUP_DESCRIPTION}:CHK" "${CPU_BOOST_ON_BAT}")
    if [[ "$__tlp_version_" != "1.3" ]];then
    	yad_opts+=(--field="CPU HWP DYN BOOST ON AC ${CPU_HWP_DYN_BOOST__GROUP_DESCRIPTION}:CHK" "${CPU_HWP_DYN_BOOST_ON_AC}")
    	yad_opts+=(--field="CPU HWP DYN BOOST ON BAT ${CPU_HWP_DYN_BOOST__GROUP_DESCRIPTION}:CHK" "${CPU_HWP_DYN_BOOST_ON_BAT}")
    fi
    if [[ "$__tlp_version_" = "1.5" ]] || [[ "$__tlp_version_" = "1.4" ]] || [[ "$__tlp_version_" = "1.3" ]];then
    	yad_opts+=(--field="SCHED POWERSAVE ON AC ${SCHED_POWERSAVE__GROUP_DESCRIPTION}:CHK" "${SCHED_POWERSAVE_ON_AC}")
		yad_opts+=(--field="SCHED POWERSAVE ON BAT ${SCHED_POWERSAVE__GROUP_DESCRIPTION}:CHK" "${SCHED_POWERSAVE_ON_BAT}")
	fi
    yad_opts+=(--field="NMI WATCHDOG ${NMI_WATCHDOG__ID_DESCRIPTION}:CHK" "${NMI_WATCHDOG}")
    [[ "$__tlp_version_" = "1.3" ]] && yad_opts+=(--field="PHC CONTROLS ${PHC_CONTROLS__ID_DESCRIPTION}" "$PHC_CONTROLS")
    if [[ "$__tlp_version_" != "1.3" ]];then
    	yad_opts+=(--field="PLATFORM PROFILE ON AC ${PLATFORM_PROFILE__GROUP_DESCRIPTION}:cb" "${PLATFORM_PROFILE_ON_AC}!performance!balanced!low-power")
		yad_opts+=(--field="PLATFORM PROFILE ON BAT ${PLATFORM_PROFILE__GROUP_DESCRIPTION}:cb" "${PLATFORM_PROFILE_ON_BAT}!performance!balanced!low-power")
    	if [[ "$__tlp_version_" != "1.5" ]] && [[ "$__tlp_version_" != "1.4" ]];then	
    		yad_opts+=(--field="MEM SLEEP ON AC ${MEM_SLEEP__GROUP_DESCRIPTION}:cb" "${MEM_SLEEP_ON_AC}!s2idle!deep")
			yad_opts+=(--field="MEM SLEEP ON BAT ${MEM_SLEEP__GROUP_DESCRIPTION}:cb" "${MEM_SLEEP_ON_BAT}!s2idle!deep")
		fi
	fi
	yad "${yad_opts[@]}" > "$Processor" &
	
	#  - name: Radio
	yad_opts=()
	yad_opts=(--scroll --plug=$KEY --tabnum=8 --borders=10
	--image=/usr/share/icons/hicolor/128x128/apps/mbcc.png
	--columns=1 --form)
    yad_opts+=( --field="RESTORE DEVICE STATE ON STARTUP ${RESTORE_DEVICE_STATE_ON_STARTUP__ID_DESCRIPTION}:CHK" "${RESTORE_DEVICE_STATE_ON_STARTUP}")
	yad_opts+=( --field="DEVICES TO DISABLE ON STARTUP ${DEVICES_TO_DISABLE_ON_STARTUP__ID_DESCRIPTION}" "${DEVICES_TO_DISABLE_ON_STARTUP}")
    yad_opts+=( --field="DEVICES TO ENABLE ON STARTUP ${DEVICES_TO_ENABLE_ON_STARTUP__ID_DESCRIPTION}" "${DEVICES_TO_ENABLE_ON_STARTUP}")
    if [[ "$__tlp_version_" != "1.7" ]];then
    	yad_opts+=(--field="DEVICES TO DISABLE ON SHUTDOWN ${DEVICES_TO_DISABLE_ON_SHUTDOWN__ID_DESCRIPTION}" "${DEVICES_TO_DISABLE_ON_SHUTDOWN}")
    	yad_opts+=(--field="DEVICES TO ENABLE ON SHUTDOWN ${DEVICES_TO_ENABLE_ON_SHUTDOWN__ID_DESCRIPTION}" "${DEVICES_TO_ENABLE_ON_SHUTDOWN}")
    fi
    yad_opts+=( --field="DEVICES TO ENABLE ON AC ${DEVICES_TO_ENABLE_ON_AC__ID_DESCRIPTION}" "${DEVICES_TO_ENABLE_ON_AC}")
    yad_opts+=( --field="DEVICES TO DISABLE ON BAT ${DEVICES_TO_DISABLE_ON_BAT__ID_DESCRIPTION}" "${DEVICES_TO_DISABLE_ON_BAT}")
    yad_opts+=( --field="DEVICES TO DISABLE ON BAT NOT IN USE ${DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE__ID_DESCRIPTION}" "${DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE}")
    yad_opts+=( --field="DEVICES TO DISABLE ON LAN CONNECT ${DEVICES_TO_DISABLE_ON_CONNECT__GROUP_DESCRIPTION}" "${DEVICES_TO_DISABLE_ON_LAN_CONNECT}")
    yad_opts+=( --field="DEVICES TO DISABLE ON WIFI CONNECT ${DEVICES_TO_DISABLE_ON_CONNECT__GROUP_DESCRIPTION}" "${DEVICES_TO_DISABLE_ON_WIFI_CONNECT}")
    yad_opts+=( --field="DEVICES TO DISABLE ON WWAN CONNECT ${DEVICES_TO_DISABLE_ON_CONNECT__GROUP_DESCRIPTION}" "${DEVICES_TO_DISABLE_ON_WWAN_CONNECT}")
    yad_opts+=( --field="DEVICES TO ENABLE ON LAN DISCONNECT ${DEVICES_TO_ENABLE_ON_DISCONNECT__GROUP_DESCRIPTION}" "${DEVICES_TO_ENABLE_ON_LAN_DISCONNECT}")
    yad_opts+=( --field="DEVICES TO ENABLE ON WIFI DISCONNECT ${DEVICES_TO_ENABLE_ON_DISCONNECT__GROUP_DESCRIPTION}" "${DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT}")
    yad_opts+=( --field="DEVICES TO ENABLE ON WWAN DISCONNECT ${DEVICES_TO_ENABLE_ON_DISCONNECT__GROUP_DESCRIPTION}" "${DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT}")
    yad_opts+=( --field="DEVICES TO ENABLE ON DOCK ${DEVICES_ON_DOCK__GROUP_DESCRIPTION}" "${DEVICES_TO_ENABLE_ON_DOCK}")
    yad_opts+=( --field="DEVICES TO DISABLE ON DOCK ${DEVICES_ON_DOCK__GROUP_DESCRIPTION}" "${DEVICES_TO_DISABLE_ON_DOCK}")
    yad_opts+=( --field="DEVICES TO ENABLE ON UNDOCK ${DEVICES_ON_UNDOCK__GROUP_DESCRIPTION}" "${DEVICES_TO_ENABLE_ON_UNDOCK}")
    yad_opts+=( --field="DEVICES TO DISABLE ON UNDOCK ${DEVICES_ON_UNDOCK__GROUP_DESCRIPTION}" "${DEVICES_TO_DISABLE_ON_UNDOCK}")
	yad "${yad_opts[@]}" > "$Radio" &

	#  - name: USB
	yad_opts=()
	yad_opts=(--scroll --plug=$KEY --tabnum=9 --borders=10
	--image=/usr/share/icons/hicolor/128x128/apps/mbcc.png
	--columns=1 --form)
    yad_opts+=( --field="USB AUTOSUSPEND ${USB_AUTOSUSPEND__ID_DESCRIPTION}:CHK" "${USB_AUTOSUSPEND}")
    yad_opts+=( --field="USB DENYLIST!gtk-yes!${USB_DENYLIST__ID_DESCRIPTION}:FBTN" "bash -c _USB_DENYLIST")
    [[ "$__tlp_version_" != "1.3" ]] && yad_opts+=( --field="USB EXCLUDE AUDIO ${USB_EXCLUDE_AUDIO__ID_DESCRIPTION}:CHK" "${USB_EXCLUDE_AUDIO}")
    yad_opts+=( --field="USB EXCLUDE BTUSB ${USB_EXCLUDE_BTUSB__ID_DESCRIPTION}:CHK" "${USB_EXCLUDE_BTUSB}")
    yad_opts+=( --field="USB EXCLUDE PHONE ${USB_EXCLUDE_PHONE__ID_DESCRIPTION}:CHK" "${USB_EXCLUDE_PHONE}")
    yad_opts+=( --field="USB EXCLUDE PRINTER ${USB_EXCLUDE_WWAN__ID_DESCRIPTION}:CHK" "${USB_EXCLUDE_PRINTER}")
    yad_opts+=( --field="USB EXCLUDE WWAN ${USB_EXCLUDE_WWAN__ID_DESCRIPTION}:CHK" "${USB_EXCLUDE_WWAN}")
    yad_opts+=( --field="USB ALLOWLIST!gtk-yes!${USB_ALLOWLIST__ID_DESCRIPTION}:FBTN" "bash -c _USB_ALLOWLIST")
    [[ "$__tlp_version_" != "1.7" ]] && yad_opts+=(--field="USB AUTOSUSPEND DISABLE ON SHUTDOWN ${USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN__ID_DESCRIPTION}:CHK" "${USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN}")
	yad "${yad_opts[@]}" > "$USB" &

	#  - name: ThinkPad_Battery
	yad_opts=()
	yad_opts=(--scroll --plug=$KEY --tabnum=10 --borders=10
	--image=/usr/share/icons/hicolor/128x128/apps/mbcc.png
	--columns=1 --form)
    yad_opts+=( --field="START CHARGE THRESH BAT0 ${CHARGE_THRESH_BAT0__GROUP_DESCRIPTION}::NUM" "${__numeric_START_CHARGE_THRESH_0_}")
    yad_opts+=( --field="STOP CHARGE THRESH BAT0 ${CHARGE_THRESH_BAT0__GROUP_DESCRIPTION}::NUM" "${__numeric_STOP_CHARGE_THRESH_0_}")
    yad_opts+=( --field="START CHARGE THRESH BAT1 ${CHARGE_THRESH_BAT1__GROUP_DESCRIPTION}::NUM" "${__numeric_START_CHARGE_THRESH_1_}")
    yad_opts+=( --field="STOP CHARGE THRESH_BAT1 ${CHARGE_THRESH_BAT1__GROUP_DESCRIPTION}::NUM" "${__numeric_STOP_CHARGE_THRESH_1_}")
    yad_opts+=( --field="RESTORE THRESHOLDS ON BAT ${RESTORE_THRESHOLDS_ON_BAT__ID_DESCRIPTION}:CHK" "${RESTORE_THRESHOLDS_ON_BAT}")
    yad_opts+=( --field="NATACPI ENABLE ${NATACPI_ENABLE__ID_DESCRIPTION}:CHK" "${NATACPI_ENABLE}")
    yad_opts+=( --field="TPACPI ENABLE ${TPACPI_ENABLE__ID_DESCRIPTION}:CHK" "${TPACPI_ENABLE}")
    yad_opts+=( --field="TPSMAPI ENABLE ${TPSMAPI_ENABLE__ID_DESCRIPTION}:CHK" "${TPSMAPI_ENABLE}")
	yad "${yad_opts[@]}" > "$ThinkPad_Battery" &
	
	#main window
	yad --notebook --tab-pos="left" --key=$KEY \
    	--tab="General" \
    	--tab="Audio" \
    	--tab="Disks" \
    	--tab="Graphics"  \
    	--tab="Network" \
    	--tab="PCIe" \
    	--tab="Processor" \
    	--tab="Radio" \
    	--tab="USB" \
    	--tab="ThinkPad_Battery" \
    	--title="TLP" --image=/usr/share/my_stuff/icons/linux.png \
    	--scroll --center --width="720" --height="420" --image-on-top --text-justify=right --text="$acc"  \
    	--text="$INTRO_TXT" \
    	--button="show simple statistics":"bash -c 'show_statistics simple'" \
    	--button="show complate statistics":"bash -c 'show_statistics complate'" \
    	--button="Save":5 \
    	--button="Restore Default Conf":50 \
    	--button="Exit":100 \
    	
    	 > $out
}

_DISK_DEVICES(){
	source "${buttons_variables}"
	__lsblk_list_array=(${__lsblk_list[@]})
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
           	--text=" ID "
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	for m in "${__lsblk_list_array[@]}"
	do
  	yad_opts+=( --field="${m}:CHK" )
	done

	ans=($(yad "${yad_opts[@]}"))
	exval=$?
	case $exval in
        	100) return;;
	esac
	
	DISK_DEVICES=""
	
	for i in "${!ans[@]}"
	do

  	if [[ "${ans[$i]}" == TRUE ]]
  	then
    	name=${__lsblk_list[$i]}
		name=${name%|*}
    	DISK_DEVICES="${name},${DISK_DEVICES}"
  	fi
	done
	DISK_DEVICES="${DISK_DEVICES::-1}"
	sed -i "s/DISK_DEVICES=.*/DISK_DEVICES=\"${DISK_DEVICES}\"/g" "${buttons_variables}"
}
export -f _DISK_DEVICES

_DISK_APM_LEVEL_ON_AC(){
	source "${buttons_variables}"
	__lsblk_list_array=(${__lsblk_list[@]})
	DISK_APM_LEVEL_ON_AC=(${DISK_APM_LEVEL_ON_AC})
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
            --text=" 1 – max power saving / minimum performance 
– Important: this setting may lead to increased disk drive wear and tear because of excessive read-write head unloading (recognizable from the clicking noises)

128 – compromise between power saving and wear (TLP standard setting on battery)

192 – prevents excessive head unloading of some HDDs

254 – minimum power saving / max performance (TLP standard setting on AC)

255 – disable APM (not supported by some disk models)

keep – special value to skip this setting for the particular disk (synonym: _)

     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	count=0
	for m in "${__lsblk_list_array[@]}"
	do
  		yad_opts+=( --field="${m}:cb" "${DISK_APM_LEVEL_ON_AC[${count}]}"'!1!128!192!254!255' )
 		((count++))
	done
	
	DISK_APM_LEVEL_ON_AC="$(yad "${yad_opts[@]}")"
	exval=$?
	case $exval in
        	100) return;;
	esac
	DISK_APM_LEVEL_ON_AC="${DISK_APM_LEVEL_ON_AC::-1}"
	sed -i "s/DISK_APM_LEVEL_ON_AC=.*/DISK_APM_LEVEL_ON_AC=\"${DISK_APM_LEVEL_ON_AC}\"/g" "${buttons_variables}"
}
export -f _DISK_APM_LEVEL_ON_AC

_DISK_APM_LEVEL_ON_BAT(){
	source "${buttons_variables}"
	__lsblk_list_array=(${__lsblk_list[@]})
	DISK_APM_LEVEL_ON_BAT=(${DISK_APM_LEVEL_ON_BAT})
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
            --text=" 1 – max power saving / minimum performance 
– Important: this setting may lead to increased disk drive wear and tear because of excessive read-write head unloading (recognizable from the clicking noises)

128 – compromise between power saving and wear (TLP standard setting on battery)

192 – prevents excessive head unloading of some HDDs

254 – minimum power saving / max performance (TLP standard setting on AC)

255 – disable APM (not supported by some disk models)

keep – special value to skip this setting for the particular disk (synonym: _)

     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	count=0
	for m in "${__lsblk_list_array[@]}"
	do
  		yad_opts+=( --field="${m}:cb" "${DISK_APM_LEVEL_ON_BAT[${count}]}"'!1!128!192!254!255' )
 		((count++))
	done
	
	DISK_APM_LEVEL_ON_BAT="$(yad "${yad_opts[@]}")"
	exval=$?
	case $exval in
        	100) return;;
	esac
	DISK_APM_LEVEL_ON_BAT="${DISK_APM_LEVEL_ON_BAT::-1}"
	sed -i "s/DISK_APM_LEVEL_ON_BAT=.*/DISK_APM_LEVEL_ON_BAT=\"${DISK_APM_LEVEL_ON_BAT}\"/g" "${buttons_variables}"
}
export -f _DISK_APM_LEVEL_ON_BAT

_DISK_SPINDOWN_TIMEOUT_ON_AC(){
	source "${buttons_variables}"
	__lsblk_list_array=(${__lsblk_list[@]})
	DISK_SPINDOWN_TIMEOUT_ON_AC=(${DISK_SPINDOWN_TIMEOUT_ON_AC})
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
           	--text="     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	count=0
	for m in "${__lsblk_list_array[@]}"
	do
  		yad_opts+=( --field="${m}::NUM" "${DISK_SPINDOWN_TIMEOUT_ON_AC[${count}]}"'!0..251!1' )
 		((count++))
	done
	DISK_SPINDOWN_TIMEOUT_ON_AC="$(yad "${yad_opts[@]}")"
	exval=$?
	case $exval in
        	100) return;;
	esac
	DISK_SPINDOWN_TIMEOUT_ON_AC="${DISK_SPINDOWN_TIMEOUT_ON_AC::-1}"
	sed -i "s/DISK_SPINDOWN_TIMEOUT_ON_AC=.*/DISK_SPINDOWN_TIMEOUT_ON_AC=\"${DISK_SPINDOWN_TIMEOUT_ON_AC}\"/g" "${buttons_variables}"
}
export -f _DISK_SPINDOWN_TIMEOUT_ON_AC

_DISK_SPINDOWN_TIMEOUT_ON_BAT(){
	source "${buttons_variables}"
	__lsblk_list_array=(${__lsblk_list[@]})
	DISK_SPINDOWN_TIMEOUT_ON_BAT=(${DISK_SPINDOWN_TIMEOUT_ON_BAT})
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
           	--text="     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	count=0
	for m in "${__lsblk_list_array[@]}"
	do
  		yad_opts+=( --field="${m}::NUM" "${DISK_SPINDOWN_TIMEOUT_ON_BAT[${count}]}"'!0..251!1' )
 		((count++))
	done
	
	DISK_SPINDOWN_TIMEOUT_ON_BAT="$(yad "${yad_opts[@]}")"
	exval=$?
	case $exval in
        	100) return;;
	esac
	DISK_SPINDOWN_TIMEOUT_ON_BAT="${DISK_SPINDOWN_TIMEOUT_ON_BAT::-1}"
	sed -i "s/DISK_SPINDOWN_TIMEOUT_ON_BAT=.*/DISK_SPINDOWN_TIMEOUT_ON_BAT=\"${DISK_SPINDOWN_TIMEOUT_ON_BAT}\"/g" "${buttons_variables}"
}
export -f _DISK_SPINDOWN_TIMEOUT_ON_BAT

_DISK_IOSCHED(){
	source "${buttons_variables}"
	__lsblk_list_array=(${__lsblk_list[@]})
	DISK_IOSCHED=(${DISK_IOSCHED})
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
           	--text="     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	count=0
	for m in "${__lsblk_list_array[@]}"
	do
  		yad_opts+=( --field="${m}:cb" "${DISK_IOSCHED[${count}]}"'!mq-deadline!none!kyber!bfq!keep' )
 		((count++))
	done
	
	DISK_IOSCHED="$(yad "${yad_opts[@]}")"
	exval=$?
	case $exval in
        	100) return;;
	esac
	DISK_IOSCHED="${DISK_IOSCHED::-1}"
	sed -i "s/DISK_IOSCHED=.*/DISK_IOSCHED=\"${DISK_IOSCHED}\"/g" "${buttons_variables}"
}
export -f _DISK_IOSCHED

_SATA_LINKPWR_ON_AC(){
	source "${buttons_variables}"
	
	menu=( "min_power|min_power"
       	"med_power_with_dipm|med_power_with_dipm"
       	"medium_power|medium_power"
       	"max_performance|max_performance" )
	
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
           	--text="     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	for m in "${menu[@]}"
	do
  		yad_opts+=( --field="${m%|*}:CHK" )
	done
	
	ans=($(yad "${yad_opts[@]}"))
	exval=$?
	case $exval in
        	100) return;;
	esac
	
	SATA_LINKPWR_ON_AC=""
	
	for i in "${!ans[@]}"
	do
  	if [[ "${ans[$i]}" == TRUE ]]
  	then
    	m=${menu[$i]}
    	name=${m%|*}
    	SATA_LINKPWR_ON_AC="${name},${SATA_LINKPWR_ON_AC}"
  	fi
	done
	SATA_LINKPWR_ON_AC=${SATA_LINKPWR_ON_AC::-1}
	SATA_LINKPWR_ON_AC="${SATA_LINKPWR_ON_AC[@]}${__Add_Custom_USB_ID}"
	sed -i "s/SATA_LINKPWR_ON_AC=.*/SATA_LINKPWR_ON_AC=\"${SATA_LINKPWR_ON_AC}\"/g" "${buttons_variables}"
}
export -f _SATA_LINKPWR_ON_AC

_SATA_LINKPWR_ON_BAT(){
	source "${buttons_variables}"
	
	menu=( "min_power|min_power"
       	"med_power_with_dipm|med_power_with_dipm"
       	"medium_power|medium_power"
       	"max_performance|max_performance" )
	
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
           	--text="     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	for m in "${menu[@]}"
	do
  	yad_opts+=( --field="${m%|*}:CHK" )
	done
	
	ans=($(yad "${yad_opts[@]}"))
	exval=$?
	case $exval in
        	100) return;;
	esac
	
	SATA_LINKPWR_ON_BAT=""
	
	for i in "${!ans[@]}"
	do
  	if [[ "${ans[$i]}" == TRUE ]]
  	then
    	m=${menu[$i]}
    	name=${m%|*}
    	SATA_LINKPWR_ON_BAT="${name},${SATA_LINKPWR_ON_BAT}"
  	fi
	done
	SATA_LINKPWR_ON_BAT=${SATA_LINKPWR_ON_BAT::-1}
	SATA_LINKPWR_ON_BAT="${SATA_LINKPWR_ON_BAT[@]}${__Add_Custom_USB_ID}"
	sed -i "s/SATA_LINKPWR_ON_BAT=.*/SATA_LINKPWR_ON_BAT=\"${SATA_LINKPWR_ON_BAT}\"/g" "${buttons_variables}"
}
export -f _SATA_LINKPWR_ON_BAT

_DISK_APM_CLASS_DENYLIST(){
	source "${buttons_variables}"
	menu=( "sata|sata"
       	"ata|ata"
       	"usb|usb"
       	"ieee1394|ieee1394" )
	
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
           	--text="     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	for m in "${menu[@]}"
	do
  	yad_opts+=( --field="${m%|*}:CHK" )
	done
	
	ans=($(yad "${yad_opts[@]}"))
	exval=$?
	case $exval in
        	100) return;;
	esac
	
	DISK_APM_CLASS_DENYLIST=""
	
	for i in "${!ans[@]}"
	do
  	if [[ "${ans[$i]}" == TRUE ]]
  	then
    	m=${menu[$i]}
    	name=${m%|*}
    	DISK_APM_CLASS_DENYLIST="${name},${DISK_APM_CLASS_DENYLIST}"
  	fi
	done
	DISK_APM_CLASS_DENYLIST=${DISK_APM_CLASS_DENYLIST::-1}
	DISK_APM_CLASS_DENYLIST="${DISK_APM_CLASS_DENYLIST[@]}${__Add_Custom_USB_ID}"
	sed -i "s/DISK_APM_CLASS_DENYLIST=.*/DISK_APM_CLASS_DENYLIST=\"${DISK_APM_CLASS_DENYLIST}\"/g" "${buttons_variables}"
}
export -f _DISK_APM_CLASS_DENYLIST

_RUNTIME_PM_DENYLIST(){
	source "${buttons_variables}"
	mapfile -t menu  < <( lspci | awk '$1=$1"|"' )
	
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
           	--text="     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	for m in "${menu[@]}"
	do
  	yad_opts+=( --field="${m}:CHK" )
	done
	
	ans=($(yad "${yad_opts[@]}"))
	exval=$?
	case $exval in
        	100) return;;
	esac
	
	RUNTIME_PM_DENYLIST=""
	
	for i in "${!ans[@]}"
	do
  	if [[ "${ans[$i]}" == TRUE ]]
  	then
    	m=${menu[$i]}
    	name=${m%|*}
    	RUNTIME_PM_DENYLIST="${name},${RUNTIME_PM_DENYLIST}"
  	fi
	done
	RUNTIME_PM_DENYLIST="${RUNTIME_PM_DENYLIST::-1}"
	sed -i "s/RUNTIME_PM_DENYLIST=.*/RUNTIME_PM_DENYLIST=\"${RUNTIME_PM_DENYLIST}\"/g" "${buttons_variables}"
}
export -f _RUNTIME_PM_DENYLIST

_USB_DENYLIST(){
	source "${buttons_variables}"
	mapfile -t menu  < <( lsusb | grep -Po ' ID \K.*' | awk '$1=$1"|"' )
	
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
           	--text="     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	for m in "${menu[@]}"
	do
  	yad_opts+=( --field="${m}:CHK" )
	done
	
	yad_opts+=( --field="Add Custom USB ID:" "" )
	
	ans=($(yad "${yad_opts[@]}"))
	exval=$?
	case $exval in
        	100) return;;
	esac
	
	__Add_Custom_USB_ID="${ans[-1]}"
	[ -n "${__Add_Custom_USB_ID}" ] && __Add_Custom_USB_ID=",${__Add_Custom_USB_ID}"
	
	USB_DENYLIST=""
	
	for i in "${!ans[@]}"
	do
  	if [[ "${ans[$i]}" == TRUE ]]
  	then
    	m=${menu[$i]}
    	name=${m%|*}
    	USB_DENYLIST="${name},${USB_DENYLIST}"
  	fi
	done
	USB_DENYLIST=${USB_DENYLIST::-1}
	USB_DENYLIST="${USB_DENYLIST[@]}${__Add_Custom_USB_ID}"
	sed -i "s/USB_DENYLIST=.*/USB_DENYLIST=\"${USB_DENYLIST}\"/g" "${buttons_variables}"
}
export -f _USB_DENYLIST

_USB_ALLOWLIST(){
	source "${buttons_variables}"
	mapfile -t menu  < <( lsusb | grep -Po ' ID \K.*' | awk '$1=$1"|"' )
	
	yad_opts=( --form --separator=' ' --on-top
           	--title="Applications Installer - change to whatever you want"
           	--text="     		 ID     	   Description"
           	--image="/path/to/some/png/logo/image/logo.png"
           	--button="Save" --button="Exit":100)
	
	for m in "${menu[@]}"
	do
  	yad_opts+=( --field="${m}:CHK" )
	done
	
	yad_opts+=( --field="Add Custom USB ID:" "" )
	
	ans=($(yad "${yad_opts[@]}"))
	exval=$?
	case $exval in
        	100) return;;
	esac
	
	__Add_Custom_USB_ID="${ans[-1]}"
	[ -n "${__Add_Custom_USB_ID}" ] && __Add_Custom_USB_ID=",${__Add_Custom_USB_ID}"
	
	USB_ALLOWLIST=""
	
	for i in "${!ans[@]}"
	do
  	if [[ "${ans[$i]}" == TRUE ]]
  	then
    	m=${menu[$i]}
    	name=${m%|*}
    	USB_ALLOWLIST="${name},${USB_ALLOWLIST}"
  	fi
	done
	USB_ALLOWLIST=${USB_ALLOWLIST::-1}
	USB_ALLOWLIST="${USB_ALLOWLIST[@]}${__Add_Custom_USB_ID}"
	sed -i "s/USB_ALLOWLIST=.*/USB_ALLOWLIST=\"${USB_ALLOWLIST}\"/g" "${buttons_variables}"
}
export -f _USB_ALLOWLIST

show_statistics(){
	if [ "$1" = "complate" ];then
		tlp_stat="$(apps_as_root $(which tlp-stat))"
	else
		tlp_stat="$($(which tlp-stat) -c -s -t -r -u)"
	fi
	yad --form --scroll --width="720" --height="420" --field="$tlp_stat:LBL" >/dev/null 2>&1
	unset tlp_stat
}
export -f show_statistics

_save_settings(){
	if [[ "$__tlp_version_" = *"1.7"* ]];then
		__tlp_version_="1.7"
	elif [[ "$__tlp_version_" = *"1.6"* ]];then
		__tlp_version_="1.6"
	elif [[ "$__tlp_version_" = *"1.5"* ]];then
		__tlp_version_="1.5"
	elif [[ "$__tlp_version_" = *"1.4"* ]];then
		__tlp_version_="1.4"
	fi
	
	__Yad_Output_="$(cat $General)$(cat $Audio)$(cat $Disks)$(cat $Graphics)$(cat $Network)$(cat $PCIe)$(cat $Processor)$(cat $Radio)$(cat $USB)$(cat $ThinkPad_Battery)"
	
	__Yad_Output_="$(echo $__Yad_Output_ | sed 's/||/| |/g;s/||/| |/g;s/||/| |/g')"
	__Yad_Output_array_=()

	IFS='|' read -ra __Yad_Output_array_ < <( echo "${__Yad_Output_}" )	

	unset __Yad_Output_
	
	__key_array_=(TLP_ENABLE)
	if [[ "$__tlp_version_" != "1.3" ]];then 
		__key_array_+=(TLP_WARN_LEVEL)
	fi
	
	__key_array_+=(TLP_DEFAULT_MODE)
	__key_array_+=(TLP_PERSISTENT_DEFAULT)
	__key_array_+=(TLP_PS_IGNORE)
	__key_array_+=(SOUND_POWER_SAVE_ON_AC)
	__key_array_+=(SOUND_POWER_SAVE_ON_BAT)
	__key_array_+=(SOUND_POWER_SAVE_CONTROLLER)
	__key_array_+=(DISK_IDLE_SECS_ON_AC)
	__key_array_+=(DISK_IDLE_SECS_ON_BAT)
	__key_array_+=(MAX_LOST_WORK_SECS_ON_AC)
	__key_array_+=(MAX_LOST_WORK_SECS_ON_BAT)
	__key_array_+=(DISK_DEVICES)
	__key_array_+=(DISK_APM_LEVEL_ON_AC)
	__key_array_+=(DISK_APM_LEVEL_ON_BAT)
	if [[ "$__tlp_version_" != "1.3" ]];then 
		__key_array_+=(DISK_APM_CLASS_DENYLIST)
	fi
	__key_array_+=(DISK_SPINDOWN_TIMEOUT_ON_AC)
	__key_array_+=(DISK_SPINDOWN_TIMEOUT_ON_BAT)
	__key_array_+=(DISK_IOSCHED)
	__key_array_+=(SATA_LINKPWR_ON_AC)
	__key_array_+=(SATA_LINKPWR_ON_BAT)
	if [[ "$__tlp_version_" != "1.3" ]];then 
		__key_array_+=(SATA_LINKPWR_DENYLIST)
	else
		__key_array_+=(SATA_LINKPWR_BLACKLIST)
	fi
	__key_array_+=(AHCI_RUNTIME_PM_ON_AC)
	__key_array_+=(AHCI_RUNTIME_PM_ON_BAT)
	__key_array_+=(AHCI_RUNTIME_PM_TIMEOUT)
	__key_array_+=(BAY_POWEROFF_ON_AC)
	__key_array_+=(BAY_POWEROFF_ON_BAT)
	__key_array_+=(BAY_DEVICE)
	__key_array_+=(INTEL_GPU_MIN_FREQ_ON_AC)
	__key_array_+=(INTEL_GPU_MIN_FREQ_ON_BAT)
	__key_array_+=(INTEL_GPU_MAX_FREQ_ON_AC)
	__key_array_+=(INTEL_GPU_MAX_FREQ_ON_BAT)
	__key_array_+=(INTEL_GPU_BOOST_FREQ_ON_AC)
	__key_array_+=(INTEL_GPU_BOOST_FREQ_ON_BAT)
	__key_array_+=(RADEON_POWER_PROFILE_ON_AC)
	__key_array_+=(RADEON_POWER_PROFILE_ON_BAT)
	__key_array_+=(RADEON_DPM_STATE_ON_AC)
	__key_array_+=(RADEON_DPM_STATE_ON_BAT)
	__key_array_+=(RADEON_DPM_PERF_LEVEL_ON_AC)
	__key_array_+=(RADEON_DPM_PERF_LEVEL_ON_BAT)
	__key_array_+=(WIFI_PWR_ON_AC)
	__key_array_+=(WIFI_PWR_ON_BAT)
	__key_array_+=(WOL_DISABLE)
	__key_array_+=(PCIE_ASPM_ON_AC)
	__key_array_+=(PCIE_ASPM_ON_BAT)
	__key_array_+=(RUNTIME_PM_ON_AC)
	__key_array_+=(RUNTIME_PM_ON_BAT)
	if [[ "$__tlp_version_" != "1.3" ]];then
		__key_array_+=(RUNTIME_PM_DENYLIST)
		__key_array_+=(RUNTIME_PM_DRIVER_DENYLIST) 
		__key_array_+=(RUNTIME_PM_ENABLE)
		__key_array_+=(RUNTIME_PM_DISABLE)
	else
		__key_array_+=(RUNTIME_PM_BLACKLIST)
		__key_array_+=(RUNTIME_PM_DRIVER_BLACKLIST)
	fi
	if [[ "$__tlp_version_" = "1.7" ]] || [[ "$__tlp_version_" = "1.6" ]];then
		__key_array_+=(CPU_DRIVER_OPMODE_ON_AC)
		__key_array_+=(CPU_DRIVER_OPMODE_ON_BAT)
	fi
	__key_array_+=(CPU_SCALING_GOVERNOR_ON_AC)
	__key_array_+=(CPU_SCALING_GOVERNOR_ON_BAT)
	__key_array_+=(CPU_SCALING_MIN_FREQ_ON_AC)
	__key_array_+=(CPU_SCALING_MAX_FREQ_ON_AC)
	__key_array_+=(CPU_SCALING_MIN_FREQ_ON_BAT)
	__key_array_+=(CPU_SCALING_MAX_FREQ_ON_BAT)
	__key_array_+=(CPU_ENERGY_PERF_POLICY_ON_AC)
	__key_array_+=(CPU_ENERGY_PERF_POLICY_ON_BAT)
	__key_array_+=(CPU_MIN_PERF_ON_AC)
	__key_array_+=(CPU_MAX_PERF_ON_AC)
	__key_array_+=(CPU_MIN_PERF_ON_BAT)
	__key_array_+=(CPU_MAX_PERF_ON_BAT)
	__key_array_+=(CPU_BOOST_ON_AC)
	__key_array_+=(CPU_BOOST_ON_BAT)
	if [[ "$__tlp_version_" != "1.3" ]];then
		__key_array_+=(CPU_HWP_DYN_BOOST_ON_AC)
		__key_array_+=(CPU_HWP_DYN_BOOST_ON_BAT)
	fi
	if [[ "$__tlp_version_" = "1.5" ]] || [[ "$__tlp_version_" = "1.4" ]] || [[ "$__tlp_version_" = "1.3" ]];then
		__key_array_+=(SCHED_POWERSAVE_ON_AC)
		__key_array_+=(SCHED_POWERSAVE_ON_BAT)
	fi
	__key_array_+=(NMI_WATCHDOG)
	[[ "$__tlp_version_" = "1.3" ]] && __key_array_+=(PHC_CONTROLS)
	if [[ "$__tlp_version_" != "1.3" ]];then
		__key_array_+=(PLATFORM_PROFILE_ON_AC)
		__key_array_+=(PLATFORM_PROFILE_ON_BAT)
		if [[ "$__tlp_version_" != "1.5" ]] && [[ "$__tlp_version_" != "1.4" ]];then
			__key_array_+=(MEM_SLEEP_ON_AC)
			__key_array_+=(MEM_SLEEP_ON_BAT)
		fi
	fi
	__key_array_+=(RESTORE_DEVICE_STATE_ON_STARTUP)
	__key_array_+=(DEVICES_TO_DISABLE_ON_STARTUP)
	__key_array_+=(DEVICES_TO_ENABLE_ON_STARTUP)
	if [[ "$__tlp_version_" != "1.7" ]];then  
		__key_array_+=(DEVICES_TO_DISABLE_ON_SHUTDOWN)
		__key_array_+=(DEVICES_TO_ENABLE_ON_SHUTDOWN)
	fi
	__key_array_+=(DEVICES_TO_ENABLE_ON_AC)
	__key_array_+=(DEVICES_TO_DISABLE_ON_BAT)
	__key_array_+=(DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE)
	__key_array_+=(DEVICES_TO_DISABLE_ON_LAN_CONNECT)
	__key_array_+=(DEVICES_TO_DISABLE_ON_WIFI_CONNECT)
	__key_array_+=(DEVICES_TO_DISABLE_ON_WWAN_CONNECT)
	__key_array_+=(DEVICES_TO_ENABLE_ON_LAN_DISCONNECT)
	__key_array_+=(DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT)
	__key_array_+=(DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT)
	__key_array_+=(DEVICES_TO_ENABLE_ON_DOCK)
	__key_array_+=(DEVICES_TO_DISABLE_ON_DOCK)
	__key_array_+=(DEVICES_TO_ENABLE_ON_UNDOCK)
	__key_array_+=(DEVICES_TO_DISABLE_ON_UNDOCK)
	__key_array_+=(USB_AUTOSUSPEND)
	if [[ "$__tlp_version_" != "1.3" ]];then
		__key_array_+=(USB_DENYLIST)
		__key_array_+=(USB_EXCLUDE_AUDIO)
		__key_array_+=(USB_EXCLUDE_BTUSB)
		__key_array_+=(USB_EXCLUDE_PHONE)
		__key_array_+=(USB_EXCLUDE_PRINTER)
		__key_array_+=(USB_EXCLUDE_WWAN)
		__key_array_+=(USB_ALLOWLIST)
	else
		__key_array_+=(USB_BLACKLIST)
		__key_array_+=(USB_BLACKLIST_BTUSB)
		__key_array_+=(USB_BLACKLIST_PHONE)
		__key_array_+=(USB_BLACKLIST_PRINTER)
		__key_array_+=(USB_BLACKLIST_WWAN)
		__key_array_+=(USB_WHITELIST)
	fi
	if [[ "$__tlp_version_" != "1.7" ]];then
		__key_array_+=(USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN)
	fi
	__key_array_+=(START_CHARGE_THRESH_BAT0)
	__key_array_+=(STOP_CHARGE_THRESH_BAT0)
	__key_array_+=(START_CHARGE_THRESH_BAT1)
	__key_array_+=(STOP_CHARGE_THRESH_BAT1)
	__key_array_+=(RESTORE_THRESHOLDS_ON_BAT)
	__key_array_+=(NATACPI_ENABLE)
	__key_array_+=(TPACPI_ENABLE)
	__key_array_+=(TPSMAPI_ENABLE)
	
	declare -A __Output_array_
	
	for key in "${!__key_array_[@]}"
	do
  		__Output_array_+=(["${__key_array_[${key}]}"]="${__Yad_Output_array_[${key}]}")
	done
	unset __key_array_
	source "${buttons_variables}"
	if [[ "${__Output_array_[TLP_ENABLE]}" == TRUE ]];then
		__Output_array_[TLP_ENABLE]=1
	else
		__Output_array_[TLP_ENABLE]=0
	fi
	if [[ "${__Output_array_[BAY_POWEROFF_ON_AC]}" == TRUE ]];then
		__Output_array_[BAY_POWEROFF_ON_AC]=1
	else
		__Output_array_[BAY_POWEROFF_ON_AC]=0
	fi
	if [[ "${__Output_array_[BAY_POWEROFF_ON_BAT]}" == TRUE ]];then
		__Output_array_[BAY_POWEROFF_ON_BAT]=1
	else
		__Output_array_[BAY_POWEROFF_ON_BAT]=0
	fi
	if [[ "${__Output_array_[CPU_BOOST_ON_AC]}" == TRUE ]];then
		__Output_array_[CPU_BOOST_ON_AC]=1
	else
		__Output_array_[CPU_BOOST_ON_AC]=0
	fi
	if [[ "${__Output_array_[CPU_BOOST_ON_BAT]}" == TRUE ]];then
		__Output_array_[CPU_BOOST_ON_BAT]=1
	else
		__Output_array_[CPU_BOOST_ON_BAT]=0
	fi
	if [[ "$__tlp_version_" != "1.3" ]];then
		if [[ "${__Output_array_[CPU_HWP_DYN_BOOST_ON_AC]}" == TRUE ]];then
			__Output_array_[CPU_HWP_DYN_BOOST_ON_AC]=1
		else
			__Output_array_[CPU_HWP_DYN_BOOST_ON_AC]=0
		fi
		if [[ "${__Output_array_[CPU_HWP_DYN_BOOST_ON_BAT]}" == TRUE ]];then
			__Output_array_[CPU_HWP_DYN_BOOST_ON_BAT]=1
		else
			__Output_array_[CPU_HWP_DYN_BOOST_ON_BAT]=0
		fi
	fi
	if [[ "$__tlp_version_" = "1.5" ]] || [[ "$__tlp_version_" = "1.4" ]] || [[ "$__tlp_version_" = "1.3" ]];then
		if [[ "${__Output_array_[SCHED_POWERSAVE_ON_AC]}" == TRUE ]];then
			__Output_array_[SCHED_POWERSAVE_ON_AC]=1
		else
			__Output_array_[SCHED_POWERSAVE_ON_AC]=0
		fi
		if [[ "${__Output_array_[SCHED_POWERSAVE_ON_BAT]}" == TRUE ]];then
			__Output_array_[SCHED_POWERSAVE_ON_BAT]=1
		else
			__Output_array_[SCHED_POWERSAVE_ON_BAT]=0
		fi
	fi
	if [[ "${__Output_array_[NMI_WATCHDOG]}" == TRUE ]];then
		__Output_array_[NMI_WATCHDOG]=1
	else
		__Output_array_[NMI_WATCHDOG]=0
	fi
	if [[ "${__Output_array_[RESTORE_DEVICE_STATE_ON_STARTUP]}" == TRUE ]];then
		__Output_array_[RESTORE_DEVICE_STATE_ON_STARTUP]=1
	else
		__Output_array_[RESTORE_DEVICE_STATE_ON_STARTUP]=0
	fi
	if [[ "${__Output_array_[USB_AUTOSUSPEND]}" == TRUE ]];then
		__Output_array_[USB_AUTOSUSPEND]=1
	else
		__Output_array_[USB_AUTOSUSPEND]=0
	fi
	if [[ "$__tlp_version_" != "1.7" ]];then
		if [[ "${__Output_array_[USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN]}" == TRUE ]];then
			__Output_array_[USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN]=1
		else
			__Output_array_[USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN]=0
		fi
	fi
	if [[ "${__Output_array_[RESTORE_THRESHOLDS_ON_BAT]}" == TRUE ]];then
		__Output_array_[RESTORE_THRESHOLDS_ON_BAT]=1
	else
		__Output_array_[RESTORE_THRESHOLDS_ON_BAT]=0
	fi
	if [[ "${__Output_array_[NATACPI_ENABLE]}" == TRUE ]];then
		__Output_array_[NATACPI_ENABLE]=1
	else
		__Output_array_[NATACPI_ENABLE]=0
	fi
	if [[ "${__Output_array_[TPACPI_ENABLE]}" == TRUE ]];then
		__Output_array_[TPACPI_ENABLE]=1
	else
		__Output_array_[TPACPI_ENABLE]=0
	fi
	if [[ "${__Output_array_[TPSMAPI_ENABLE]}" == TRUE ]];then
		__Output_array_[TPSMAPI_ENABLE]=1
	else
		__Output_array_[TPSMAPI_ENABLE]=0
	fi
	if [[ "${__Output_array_[AHCI_RUNTIME_PM_ON_AC]}" == TRUE ]];then
		__Output_array_[AHCI_RUNTIME_PM_ON_AC]=auto
	else
		__Output_array_[AHCI_RUNTIME_PM_ON_AC]=on
	fi
	if [[ "${__Output_array_[AHCI_RUNTIME_PM_ON_BAT]}" == TRUE ]];then
		__Output_array_[AHCI_RUNTIME_PM_ON_BAT]=auto
	else
		__Output_array_[AHCI_RUNTIME_PM_ON_BAT]=on
	fi
	if [[ "${__Output_array_[RUNTIME_PM_ON_AC]}" == TRUE ]];then
		__Output_array_[RUNTIME_PM_ON_AC]=auto
	else
		__Output_array_[RUNTIME_PM_ON_AC]=on
	fi
	if [[ "${__Output_array_[RUNTIME_PM_ON_BAT]}" == TRUE ]];then
		__Output_array_[RUNTIME_PM_ON_BAT]=auto
	else
		__Output_array_[RUNTIME_PM_ON_BAT]=on
	fi
	if [[ "${__Output_array_[WOL_DISABLE]}" == TRUE ]];then
		__Output_array_[WOL_DISABLE]=Y
	else
		__Output_array_[WOL_DISABLE]=N
	fi
	if [[ "${__Output_array_[SOUND_POWER_SAVE_CONTROLLER]}" == TRUE ]];then
		__Output_array_[SOUND_POWER_SAVE_CONTROLLER]=Y
	else
		__Output_array_[SOUND_POWER_SAVE_CONTROLLER]=N
	fi
	if [[ "${__Output_array_[WIFI_PWR_ON_AC]}" == TRUE ]];then
		__Output_array_[WIFI_PWR_ON_AC]=on
	else
		__Output_array_[WIFI_PWR_ON_AC]=off
	fi
	if [[ "${__Output_array_[WIFI_PWR_ON_BAT]}" == TRUE ]];then
		__Output_array_[WIFI_PWR_ON_BAT]=on
	else
		__Output_array_[WIFI_PWR_ON_BAT]=off
	fi
	__Output_array_[DISK_DEVICES]="\"${DISK_DEVICES}\""
	__Output_array_[DISK_APM_LEVEL_ON_AC]="\"${DISK_APM_LEVEL_ON_AC}\""
	__Output_array_[DISK_APM_LEVEL_ON_BAT]="\"${DISK_APM_LEVEL_ON_BAT}\""
	[[ "$__tlp_version_" != "1.3" ]] && __Output_array_[DISK_APM_CLASS_DENYLIST]="\"${DISK_APM_CLASS_DENYLIST}\""
	__Output_array_[DISK_SPINDOWN_TIMEOUT_ON_AC]="\"${DISK_SPINDOWN_TIMEOUT_ON_AC}\""
	__Output_array_[DISK_SPINDOWN_TIMEOUT_ON_BAT]="\"${DISK_SPINDOWN_TIMEOUT_ON_BAT}\""
	__Output_array_[DISK_IOSCHED]="\"${DISK_IOSCHED}\""
	__Output_array_[SATA_LINKPWR_ON_AC]="\"${SATA_LINKPWR_ON_AC}\""
	__Output_array_[SATA_LINKPWR_ON_BAT]="\"${SATA_LINKPWR_ON_BAT}\""
	__Output_array_[DEVICES_TO_DISABLE_ON_STARTUP]="\"${__Output_array_[DEVICES_TO_DISABLE_ON_STARTUP]}\""
	__Output_array_[DEVICES_TO_ENABLE_ON_STARTUP]="\"${__Output_array_[DEVICES_TO_ENABLE_ON_STARTUP]}\""
	if [[ "$__tlp_version_" != "1.7" ]];then 
		__Output_array_[DEVICES_TO_DISABLE_ON_SHUTDOWN]="\"${__Output_array_[DEVICES_TO_DISABLE_ON_SHUTDOWN]}\""
		__Output_array_[DEVICES_TO_ENABLE_ON_SHUTDOWN]="\"${__Output_array_[DEVICES_TO_ENABLE_ON_SHUTDOWN]}\""
	fi
	__Output_array_[DEVICES_TO_ENABLE_ON_AC]="\"${__Output_array_[DEVICES_TO_ENABLE_ON_AC]}\""
	__Output_array_[DEVICES_TO_DISABLE_ON_BAT]="\"${__Output_array_[DEVICES_TO_DISABLE_ON_BAT]}\""
	__Output_array_[DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE]="\"${__Output_array_[DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE]}\""
	__Output_array_[DEVICES_TO_DISABLE_ON_LAN_CONNECT]="\"${__Output_array_[DEVICES_TO_DISABLE_ON_LAN_CONNECT]}\""
	__Output_array_[DEVICES_TO_DISABLE_ON_WIFI_CONNECT]="\"${__Output_array_[DEVICES_TO_DISABLE_ON_WIFI_CONNECT]}\""
	__Output_array_[DEVICES_TO_DISABLE_ON_WWAN_CONNECT]="\"${__Output_array_[DEVICES_TO_DISABLE_ON_WWAN_CONNECT]}\""
	__Output_array_[DEVICES_TO_ENABLE_ON_LAN_DISCONNECT]="\"${__Output_array_[DEVICES_TO_ENABLE_ON_LAN_DISCONNECT]}\""
	__Output_array_[DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT]="\"${__Output_array_[DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT]}\""
	__Output_array_[DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT]="\"${__Output_array_[DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT]}\""
	__Output_array_[DEVICES_TO_ENABLE_ON_DOCK]="\"${__Output_array_[DEVICES_TO_ENABLE_ON_DOCK]}\""
	__Output_array_[DEVICES_TO_DISABLE_ON_DOCK]="\"${__Output_array_[DEVICES_TO_DISABLE_ON_DOCK]}\""
	__Output_array_[DEVICES_TO_ENABLE_ON_UNDOCK]="\"${__Output_array_[DEVICES_TO_ENABLE_ON_UNDOCK]}\""
	__Output_array_[DEVICES_TO_DISABLE_ON_UNDOCK]="\"${__Output_array_[DEVICES_TO_DISABLE_ON_UNDOCK]}\""
	__Output_array_[BAY_DEVICE]="\"${__Output_array_[BAY_DEVICE]}\""

	if [[ "$__tlp_version_" != "1.3" ]];then
		if [[ "${__Output_array_[USB_EXCLUDE_AUDIO]}" == TRUE ]];then
			__Output_array_[USB_EXCLUDE_AUDIO]=1
		else
			__Output_array_[USB_EXCLUDE_AUDIO]=0
		fi
		if [[ "${__Output_array_[USB_EXCLUDE_BTUSB]}" == TRUE ]];then
			__Output_array_[USB_EXCLUDE_BTUSB]=1
		else
			__Output_array_[USB_EXCLUDE_BTUSB]=0
		fi
		if [[ "${__Output_array_[USB_EXCLUDE_PHONE]}" == TRUE ]];then
			__Output_array_[USB_EXCLUDE_PHONE]=1
		else
			__Output_array_[USB_EXCLUDE_PHONE]=0
		fi
		if [[ "${__Output_array_[USB_EXCLUDE_PRINTER]}" == TRUE ]];then
			__Output_array_[USB_EXCLUDE_PRINTER]=1
		else
			__Output_array_[USB_EXCLUDE_PRINTER]=0
		fi
		if [[ "${__Output_array_[USB_EXCLUDE_WWAN]}" == TRUE ]];then
			__Output_array_[USB_EXCLUDE_WWAN]=1
		else
			__Output_array_[USB_EXCLUDE_WWAN]=0
		fi
		__Output_array_[DISK_APM_CLASS_DENYLIST]="\"${DISK_APM_CLASS_DENYLIST}\""
		__Output_array_[RUNTIME_PM_ENABLE]="\"${__Output_array_[RUNTIME_PM_ENABLE]}\""
		__Output_array_[RUNTIME_PM_DISABLE]="\"${__Output_array_[RUNTIME_PM_DISABLE]}\""
		__Output_array_[RUNTIME_PM_DENYLIST]="\"${RUNTIME_PM_DENYLIST}\""
		__Output_array_[USB_ALLOWLIST]="\"${USB_ALLOWLIST}\""
		__Output_array_[USB_DENYLIST]="\"${USB_DENYLIST}\""
		__Output_array_[RUNTIME_PM_DRIVER_DENYLIST]="\"${__Output_array_[RUNTIME_PM_DRIVER_DENYLIST]}\""
		__Output_array_[SATA_LINKPWR_DENYLIST]="\"${__Output_array_[SATA_LINKPWR_DENYLIST]}\""
	else
		if [[ "${__Output_array_[USB_BLACKLIST_BTUSB]}" == TRUE ]];then
			__Output_array_[USB_BLACKLIST_BTUSB]=1
		else
			__Output_array_[USB_BLACKLIST_BTUSB]=0
		fi
		if [[ "${__Output_array_[USB_BLACKLIST_PHONE]}" == TRUE ]];then
			__Output_array_[USB_BLACKLIST_PHONE]=1
		else
			__Output_array_[USB_BLACKLIST_PHONE]=0
		fi
		if [[ "${__Output_array_[USB_BLACKLIST_PRINTER]}" == TRUE ]];then
			__Output_array_[USB_BLACKLIST_PRINTER]=1
		else
			__Output_array_[USB_BLACKLIST_PRINTER]=0
		fi
		if [[ "${__Output_array_[USB_BLACKLIST_WWAN]}" == TRUE ]];then
			__Output_array_[USB_BLACKLIST_WWAN]=1
		else
			__Output_array_[USB_BLACKLIST_WWAN]=0
		fi
		__Output_array_[RUNTIME_PM_BLACKLIST]="\"${RUNTIME_PM_DENYLIST}\""
		__Output_array_[USB_WHITELIST]="\"${USB_ALLOWLIST}\""
		__Output_array_[USB_BLACKLIST]="\"${USB_DENYLIST}\""
		__Output_array_[RUNTIME_PM_DRIVER_BLACKLIST]="\"${__Output_array_[RUNTIME_PM_DRIVER_BLACKLIST]}\""
		__Output_array_[SATA_LINKPWR_BLACKLIST]="\"${__Output_array_[SATA_LINKPWR_BLACKLIST]}\""
	fi
	
	source <(sed '/^# /d;/^#!/d;s/#//g' "$__config_path")
	
	cat "${__config_path}" > "${__temp_config_path}"
	
	for key in "${!__Output_array_[@]}"
	do
			if [[ "${__Output_array_[${key}]}" != "" ]];then
				__in_config_="${!key}"
				__in_config_="${__in_config_%\"}"
				__in_config_="${__in_config_#\"}"
			else
				__in_config_=""
			fi
			
			if [[ "${__Output_array_[${key}]}" != "" ]];then
				__in_yad_="${__Output_array_[${key}]}"
				__in_yad_="${__in_yad_%\"}"
				__in_yad_="${__in_yad_#\"}"
			else
				__in_yad_=""
			fi
			
			if [[ "${__in_yad_}" != " " ]];then
  				if [[ "${__in_yad_}" != "${__in_config_}" ]];then
  					echo "$key=${__Output_array_[${key}]}" >> "${__check_file}"
					sed -i "s/^$key=.*/$key=${__Output_array_[${key}]}/g" "${__temp_config_path}"
					sed -i "s/^#$key=.*/$key=${__Output_array_[${key}]}/g" "${__temp_config_path}"
				fi
			fi
	done
	if [ -f "${__check_file}" ];then
		apps_as_root true && my-superuser cp -r "${__temp_config_path}" "${__config_path}"
	fi
	
	unset __Yad_Output_array_
	
}

_restore_default_value(){
	popup_terminal --superuser "copy tlp.conf" "cp -r \"/usr/share/${Custom_distro_dir_name}/lib/tlp-defaults/tlp-${__tlp_version_}.conf\" /etc/tlp.conf"
	exval=$?
	case $exval in
        	0) yad --form --width="200" --height="100" --field="$0 restored config to default value:LBL" >/dev/null 2>&1;;
        	1) yad --form --width="200" --height="100" --field="$0 failed to restore default value:LBL" >/dev/null 2>&1;;
	esac
}

main_yad 
exval=$?
case $exval in
        5) _save_settings;;
        50) _restore_default_value;;
esac

unset _DISK_DEVICES
unset _SATA_LINKPWR_ON_AC
unset _SATA_LINKPWR_ON_BAT
unset _RUNTIME_PM_DENYLIST
unset _USB_DENYLIST
unset _USB_ALLOWLIST
unset _DISK_APM_LEVEL_ON_AC
unset _DISK_APM_LEVEL_ON_BAT
unset _DISK_SPINDOWN_TIMEOUT_ON_AC
unset _DISK_SPINDOWN_TIMEOUT_ON_BAT
unset _DISK_IOSCHED

unset show_statistics
unset _save_settings

exit
