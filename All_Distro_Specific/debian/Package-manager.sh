if command -v nala >/dev/null 2>&1;then
	package_manger="nala"
	Package_update_(){
		my-superuser nala update
	}
else
	package_manger="apt-get"
	Package_update_(){
		say 'Updating sources...' 1
		# If no update today exec update
		if ! [ "$(find /var/cache/apt/pkgcache.bin -mtime 0 2>/dev/null)" ];then
			# REPOSITORY UPDATE-NOTIFICATION
			say "Updating package repositoriy..."
			my-superuser apt-get update
		else
			my-superuser killall -9 apt-get  >/dev/null 2>&1 || my-superuser killall -9 apt >/dev/null 2>&1
			say "Updating package repositoriy..."
			my-superuser apt-get update
		fi
	}
fi

Package_installer_(){
	my-superuser "${package_manger}" install -y "$@"
}

full_upgrade_(){
	say 'Full upgrade your system...' 1
	my-superuser "${package_manger}" -y full-upgrade
}

Packages_upgrade_(){
	my-superuser "${package_manger}" -y upgrade
}

Package_remove_(){
	my-superuser "${package_manger}" purge -y "$@"
}

download_key(){
	mode="${1-}"
	url="${2-}"
	path="${3-}"
	if [ "${mode}" = "gpg" ];then
		getURL '2term' "${url}" | my-superuser gpg --dearmor --yes -o "${path}" || continue
	elif [ "${mode}" = "download" ];then
		getURL '2term' "${url}" | my-superuser tee "${path}" > /dev/null 2>&1 || continue
	elif [ "${mode}" = "key" ];then
		getURL '2term' "${url}" | my-superuser apt-key --keyring "${path}" add - || continue
	elif [ "${mode}" = "extrepo" ];then
		repo_name="${2-}"
		Package_installer_ extrepo || continue
		my-superuser extrepo enable ${repo_name} || continue
		return
	fi
	my-superuser chmod a+r "${path}" || continue
}

Package_list_(){
	for i in $(apt list --upgradable -a  2>/dev/null | awk -F/ '{print $1}' | grep -v Listing... | uniq)
	do 
		dpkg -l | grep -e "$i"
	done
}

Upgradeable_Packages_count_(){
	apt list --upgradable 2> /dev/null | grep -c upgradable
}
	
install_deb(){
	deb_name="${1-}"
	my-superuser dpkg -i ${deb_name} || my-superuser apt-get install -y ${deb_name} || continue
	my-superuser apt-get install -y -f || continue
}

Package_cleanup() {
	my-superuser "$package_manger" clean
	my-superuser "$package_manger" autoremove -y 
	my-superuser du -h /var/cache/apt
      
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

__dpkg_configure() {
    my-superuser dpkg --configure -a
}
