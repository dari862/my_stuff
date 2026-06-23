#!/bin/sh
# need superuser : called by my-installer
if command -v nala >/dev/null 2>&1;then
	package_manger="nala"
	Package_update_(){
		kill_package_manager
		my-superuser nala update
	}
else
	package_manger="apt-get"
	Package_update_(){
    	stamp_file="/var/lib/apt/periodic/update-success-stamp"
    	sources_dir="/etc/apt/sources.list.d"
    	main_sources="/etc/apt/sources.list"
    	cache_expiry=86400 # 24 hours in seconds
    	needs_update=false
	
    	if lsof /var/lib/apt/lists/lock >/dev/null 2>&1 || lsof /var/lib/dpkg/lock-frontend >/dev/null 2>&1; then
        	say "APT is currently locked by another process. killing apt." 'yellow'
        	kill_package_manager
    	fi
	
    	if [ ! -f "$stamp_file" ]; then
        	say "No record of a previous successful update. Update required."
        	needs_update=true
    	else
        	# 3. Check if the last update has expired (older than 24 hours)
        	current_time=$(date +%s)
        	last_update=$(stat -c %Y "$stamp_file")
        	age=$((current_time - last_update))
        	
        	if [ $age -gt $cache_expiry ]; then
            	say "Last update was more than 24 hours ago. Update required." 'yellow'
            	needs_update=true
        	fi
    	fi
	
    	# 4. Check if custom repos are newer than the last successful update stamp
    	if [ "$needs_update" = false ]; then
        	# -newer checks if any file in sources is newer than the modification time of $stamp_file
        	# We check both the main file and the contents of the sources.list.d directory
        	if [ -n "$(find "$main_sources" "$sources_dir" -type f -newer "$stamp_file" 2>/dev/null)" ]; then
            	say "New or modified repository detected since the last update. Update required." 'yellow'
            	needs_update=true
        	fi
    	fi
	
    	# 5. Execute the update if flagged
    	if [ "$needs_update" = true ]; then
        	say "Updating APT package lists..." 'yellow'
        	# -y for non-interactive, output suppression unless errors occur
        	if my-superuser apt-get update -y -qq; then
            	say "APT cache successfully updated."
            	# Explicitly touch the stamp file to ensure it registers now
            	my-superuser touch "$stamp_file"
        	else
            	say "Error: 'apt-get update' failed." 'red'
        	fi
    	else
        	say "APT cache is up to date. Skipping update."
    	fi
	}
fi

Package_installer_(){
	my-superuser ${package_manger} install -y $@
}

full_upgrade_(){
	say 'Full upgrade your system...' 1
	my-superuser ${package_manger} -y full-upgrade
}

Packages_upgrade_(){
	if my-superuser ${package_manger} -y upgrade;then
		exit
	else
		exit 1
	fi
}

Package_remove_(){
	my-superuser "${package_manger}" purge -y $@
}

remove_orphan_packages(){
	my-superuser "$package_manger" clean -y
	my-superuser "${package_manger}" autoremove --purge -y
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

Upgradeable_Packages_list_(){
	apt list --upgradable 2> /dev/null | grep upgradable
}
	
install_deb(){
	deb_name="${1-}"
	my-superuser dpkg -i ${deb_name} || my-superuser apt-get install -y ${deb_name} || continue
	my-superuser apt-get install -y -f || continue
}

Package_cleanup() {
	remove_orphan_packages
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

pacstall_install(){
	packages="$@"
	for package in $packages;do 
		pacstall -I $package
	done
}

add_repo() {
	repo_name="${1:-}"
	repo_value="${2:-}"
	printf '%s\n' "${repo_value}" | my-superuser tee -a "/etc/apt/sources.list.d/${repo_name}.list" > /dev/null 2>&1
}

update_linux_kernel(){
	ARCH="$(uname -m)"
	case "$ARCH" in
    	x86_64) picked_ARCH="amd64" ;;
    	*) 		picked_ARCH="$ARCH" ;;
	esac
	
	Package_installer_ "linux-image-${picked_ARCH}"
	
	if command -v dkms >/dev/null 2>&1;then
		dkms autoinstall
	fi
	
	update-initramfs -u
}

kill_package_manager(){
	ps aux | grep "nala" | awk '{print $2}' | xargs kill -9 >/dev/null 2>&1 || :
	ps aux | grep "apt" | awk '{print $2}' | xargs kill -9 >/dev/null 2>&1 || :
	ps aux | grep "apt-get" | awk '{print $2}' | xargs kill -9 >/dev/null 2>&1 || :
}
