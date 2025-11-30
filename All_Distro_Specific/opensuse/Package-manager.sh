#!/bin/sh
# need superuser : called by my-installer
Package_installer_(){
	my-superuser zypper install -y $@
}

Package_update_(){
	say 'Updating sources...' 1
	my-superuser zypper ref
}

full_upgrade_(){
	say 'Full upgrade your system...' 1
	my-superuser zypper -y --non-interactive dup
}

Package_remove_(){
	my-superuser zypper remove -y $@
}
Package_list_(){
	:
}
Upgradeable_Packages_list_(){
	zypper list-updates
}
Packages_upgrade_(){
	if my-superuser zypper -y upgrade;then
		exit
	else
		exit 1
	fi
}
Package_cleanup() {
	my-superuser zypper clean -a
	my-superuser zypper tidy
	my-superuser zypper cc -a

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
  if [ "$(zypper repolist enabled 2>/dev/null | grep -c "$REPO_ID")" -le 0 ]; then
    say "$REPO_ID repository is not enabled. Enabling now..."
    my-superuser zypper config-manager --set-enabled "$REPO_ID"
    my-superuser zypper makecache
    if [ "$(zypper repolist enabled 2>/dev/null | grep -c "$REPO_ID")" -le 0 ]; then
      failed_to_run "Failed to enable $REPO_ID repository..."
    fi
  fi
}

add_repo() {
	REPO_ID="${1:-}"
	say "Adding $REPO_ID repository..."
	my-superuser zypper addrepo ${REPO_ID}
}

import_key() {
	url="${1:-}"
	say "importing $url key..."
	my-superuser rpm --import ${url}
}

__dpkg_configure() {
    my-superuser zypper remove $(zypper packages --orphaned | awk '/^[0-9]/ {print $5}')
}
