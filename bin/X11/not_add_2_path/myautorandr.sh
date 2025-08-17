#!/bin/sh
set -e
DISPLAYSELECT="/usr/share/my_stuff/bin/X11/WM/displayselect"
WRAPPER_PATH="/usr/share/my_stuff/system_files/displayselect-wrapper.sh"
	
error_exit() {
	printf "Error: %s" "$1" >&2
	exit 1
}

warning_massage() {
	printf "Warning: %s" "$1" >&2
}

pre_check() {
	[ "$(id -u)" -ne 0 ] && error_exit "This script must be run as root."

	for cmd in udevadm install; do
		command -v "$cmd" >/dev/null 2>&1 || error_exit "Required command '$cmd' not found."
	done
}

__install(){
	echo "installing displayselect wrapper..."
 
cat <<EOF | install -m 0755 /dev/stdin "$WRAPPER_PATH"
#!/bin/bash
udevadm monitor --subsystem-match=drm --property | \
while read -r line; do
    if echo "\$line" | grep -q "HOTPLUG=1"; then
        export DISPLAY=:0
        export XAUTHORITY=/home/\$USER/.Xauthority
        sleep 1
        displayselect auto "noninteractive"
    fi
done
EOF
	
	echo "Displayselect wrapper installed and udev rules reloaded successfully."
}

__uninstall(){
	echo "Uninstalling displayselect wrapper and udev rules..."

	rm -f "$WRAPPER_PATH" || warning_massage "Failed to remove $WRAPPER_PATH"
	echo "Uninstallation complete."
}
	
pre_check
case "${1:-}" in
	install|''|-i) __install ;;
	uninstall|-u) __uninstall ;;
	*) __install ;;
esac
