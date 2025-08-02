#!/bin/sh
set -e
__opt="${1:-}"
__user="${2:-}"

__download_only(){
	SudoHOME="/home/$__user"
	if [ -d "$SudoHOME/Desktop/my_stuff" ];then
		base_dir="$SudoHOME/Desktop/my_stuff"
	elif [ -d "/usr/share/my_stuff" ];then
		base_dir="/usr/share/my_stuff"
	else
		base_dir="/tmp/temp_distro_installer_dir/my_stuff"
	fi

	. "${base_dir}/lib/common/common"
	mkdir -p "/tmp/root"
	clone_repo "https://github.com/umrian/dwm" "/tmp/root/dwm" || ( rm -rdf "/tmp/root/dwm" && exit 1 )
}

__build(){
	[ ! -d "/tmp/root/dwm" ] && __download_only
	cd "/tmp/root/dwm"
	make clean install
}

case "${__opt}" in
	download-only) __download_only ;;
	build) __build ;;
	*) __build ;;
esac
