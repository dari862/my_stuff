#!/bin/sh
set -e
DISPLAYSELECT="/usr/share/my_stuff/bin/X11/WM/displayselect"

WRAPPER_PATH="/usr/share/my_stuff/system_files/displayselect-wrapper.sh"
UDEV_RULE="/etc/udev/rules.d/99-displayselect.rules"
	
error_exit() {
	printf "Error: %s" "$1" >&2
	exit 1
}

warning_massage() {
	printf "Warning: %s" "$1" >&2
}

pre_check() {
	[ "$(id -u)" -ne 0 ] && error_exit "This script must be run as root."

	for cmd in logname getent udevadm install; do
		command -v "$cmd" >/dev/null 2>&1 || error_exit "Required command '$cmd' not found."
	done
}

backup_if_exists() {
	file=$1
	[ -e "$file" ] && cp -v "$file" "${file}.bak_$(date +%Y%m%d%H%M%S)"

}
	
__install(){
	echo "installing displayselect wrapper and udev rules..."
	backup_if_exists "$WRAPPER_PATH"
	backup_if_exists "$UDEV_RULE"
	
cat <<EOF | install -m 0755 /dev/stdin "$WRAPPER_PATH"
#!/bin/sh

USER=\$(logname)
HOME_DIR=\$(getent passwd "\$USER" | cut -d: -f6)

export DISPLAY=:0
export XAUTHORITY="\$HOME_DIR/.Xauthority"

if [ ! -r "\$XAUTHORITY" ]; then
	echo "\$0: X11 session not detected or XAUTHORITY not accessible, exiting."
	exit 0
fi

exec "$DISPLAYSELECT" auto noninteractive
EOF

cat <<EOF | install -m 0644 /dev/stdin "$UDEV_RULE"
ACTION=="change", SUBSYSTEM=="drm", RUN+="$WRAPPER_PATH"
EOF
	
	udevadm control --reload-rules || error_exit "Failed to reload udev rules."
	udevadm trigger || error_exit "Failed to trigger udev."
	
	echo "Displayselect wrapper installed and udev rules reloaded successfully."
}

__uninstall(){
	echo "Uninstalling displayselect wrapper and udev rules..."

	rm -f "$WRAPPER_PATH" || warning_massage "Failed to remove $WRAPPER_PATH"
	rm -f "$UDEV_RULE" || warning_massage "Failed to remove $UDEV_RULE"

	udevadm control --reload-rules || error_exit "Failed to reload udev rules."
	udevadm trigger || error_exit "Failed to trigger udev."

	echo "Uninstallation complete."
}
	
pre_check
case "${1:-}" in
	install|''|-i) __install ;;
	uninstall|-u) __uninstall ;;
	*) __install ;;
esac
