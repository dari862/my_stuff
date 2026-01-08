#!/bin/sh
# need superuser : called by my-installer
if command -v yay >/dev/null 2>&1;then
	package_manger="yay"
elif command -v paru >/dev/null 2>&1;then
	package_manger="paru"
else
	package_manger="my-superuser pacman"
fi

Package_installer_(){
	${package_manger} --noconfirm -S $@
}
Package_update_(){
	kill_package_manager
	say 'Updating sources...' 1
	${package_manger} -Syu --noconfirm
}
full_upgrade_(){
	say 'Full upgrade your system...' 1
	${package_manger} -Syu --noconfirm --needed archlinux-keyring
	${package_manger} -Syu --noconfirm
}
Packages_upgrade_(){
	if ${package_manger} -y upgrade;then
		exit
	else
		exit 1
	fi
}

Package_remove_(){
	packges="$@"
	for packge in $packges;do
		if ${package_manger} -Q | grep -q "packge "; then
			packges="$packges $packge"
		fi
	done
	if [ -n "$packges" ];then
		${package_manger} -Rdd --noconfirm $packges
	fi
}

remove_orphan_packages(){
	orphans=$(${package_manger} -Qtdq)
	if [ -n "$orphans" ]; then
		"$package_manger" -Scc --noconfirm
		${package_manger} -Rns  --noconfirm $orphans
	fi
}

Package_list_(){
	:
}
Upgradeable_Packages_list_(){
	checkupdates 2> /dev/null
}
Package_cleanup() {
	remove_orphan_packages
            
    if [ -d /var/tmp ]; then
        my-superuser find /var/tmp -type f -atime +5 -delete
    fi
    if [ -d /tmp ]; then
        my-superuser find /tmp -type f -atime +5 -delete
    fi
    if [ -d /var/log ]; then
        my-superuser find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
    fi
    service_manager cleanup
}

enable_repo() {
  REPO_ID="${1:-}"
  REPO_ID="${1:-}"
  SigLevel="${3:-Never}"
	if ! grep -q "^\s*\[$REPO_ID\]" /etc/pacman.conf; then
		say "Adding jupiter-staging to pacman repositories..."
		echo "[$REPO_ID]" | my-superuser tee -a /etc/pacman.conf
		echo "Server = https://steamdeck-packages.steamos.cloud/archlinux-mirror/\$repo/os/\$arch" | my-superuser tee -a /etc/pacman.conf
		echo "SigLevel = $SigLevel" | my-superuser tee -a /etc/pacman.conf
	fi
}

__dpkg_configure() {
    my-superuser pacman -Rns $(pacman -Qdtq)
}

update_linux_kernel(){
	Package_installer_ "linux-image-$(uname -r)"
	if command -v dkms >/dev/null 2>&1;then
		dkms autoinstall
	fi
	my-superuser mkinitcpio -P
}

kill_package_manager(){
	if [ -f "/var/lib/pacman/db.lck" ];then
		rm /var/lib/pacman/db.lck
	fi
	ps aux | grep "pacman" | awk '{print $2}' | xargs kill -9 >/dev/null 2>&1 || :
}
