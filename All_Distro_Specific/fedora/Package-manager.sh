Package_installer_(){
	my-superuser dnf install -y --non-interactive $@
}

Package_update_(){
	kill_package_manager
	say 'Updating sources...' 1
	my-superuser dnf update -y
}

full_upgrade_(){
	say 'Full upgrade your system...' 1
	current_version=$(rpm -E '%{fedora}')
	next_version=$((current_version + 1))
	Package_installer_ dnf-plugin-system-upgrade || failed_to_run "Failed to install dnf-plugin-system-upgrade.${RC}"  	
	my-superuser dnf system-upgrade download --releasever="$next_version" -y || failed_to_run "Failed to download the upgrade packages."

	if prompt "Do you want to reboot now to apply the upgrade?" "Y";then
		cat <<- EOF > "$HOME/.config/autostartscripts/full_upgrade_"
		#!/bin/sh
# need superuser : called by my-installer
		set -e
		popup_terminal --superuser "dnf autoremove && rm -rf \"$HOME/.config/autostartscripts/full_upgrade_\" && my-superuser dnf system-upgrade reboot"
		EOF
		chmod +x "$HOME/.config/autostartscripts/full_upgrade_"
		say "Rebooting to apply the upgrade..."
	else
		say "You can reboot later to apply the upgrade."
	fi
	
	my-superuser dnf distro-sync -y
}

Package_remove_(){
	my-superuser dnf remove -y $@
}

Package_list_(){
	:
}

Upgradeable_Packages_list_(){
	dnf updateinfo -q --list
}
Packages_upgrade_(){
	if my-superuser dnf -y upgrade;then
		exit
	else
		exit 1
	fi
}
Package_cleanup() {
	my-superuser dnf clean all
	my-superuser dnf autoremove -y
       
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
  Package_installer_ addrepo -f ${REPO_ID}
  Package_installer_ --gpg-auto-import-keys refresh
}

add_repo() {
	REPO_ID="${1:-}"
	Package_installer_ addrepo -f ${REPO_ID}
	dnf_version=$(dnf --version | head -n 1 | cut -d '.' -f 1)
	if [ "$dnf_version" -eq 4 ]; then
		Package_installer_ config-manager --add-repo ${REPO_ID}
	else
		Package_installer_ config-manager addrepo --from-repofile=${REPO_ID}
	fi
}

copr_enable(){
	REPO_ID="${1:-}"
	dnf copr enable ${REPO_ID}
}

import_key() {
	url="${1:-}"
	say "importing $url key..."
	my-superuser rpm --import ${url}
}

__dpkg_configure() {
    my-superuser dnf clean all
	my-superuser dnf autoremove -y
	my-superuser dnf autoremove --assumeno
}

update_linux_kernel(){
	Package_installer_ "linux-image-$(uname -r)"
	if command -v dkms >/dev/null 2>&1;then
		dkms autoinstall
	fi
	dracut -f
}

kill_package_manager(){
	ps aux | grep "dnf" | awk '{print $2}' | xargs kill -9 >/dev/null 2>&1 || :
}
