if command -v nala >/dev/null 2>&1; then
	Package_installer_(){
		my-superuser nala install -y "$@"
	}
	Package_update_(){
		my-superuser nala update
	}
	full_upgrade_(){
		my-superuser nala -y upgrade
	}
	Packages_upgrade_(){
		my-superuser apt-get -y upgrade
	}
	Package_remove_(){
		my-superuser nala purge -y "$@"
	}
	Package_remove_(){
		# remove packages that can no longer be downloaded
		my-superuser apt-get autoclean	
		# remove packages automatically installed as dependencies and not currently
		# dependencies of any installed packages
		my-superuser apt autoremove
	}
	Package_list_(){
		for i in $(apt list --upgradable -a  2>/dev/null | awk -F/ '{print $1}' | grep -v Listing... | uniq)
		do 
			dpkg -l | grep -e "$i"
		done
	}
else
	Package_installer_(){
		my-superuser apt-get install -y "$@"
	}
	Package_update_(){
		# If no update today exec update
		if ! [ "$(find /var/cache/apt/pkgcache.bin -mtime 0 2>/dev/null)" ]; then
			# REPOSITORY UPDATE-NOTIFICATION
			say "Updating package repositoriy..."
			my-superuser apt-get update &> /dev/null
		else
			my-superuser killall -9 apt-get  &> /dev/null || my-superuser killall -9 apt &> /dev/null
			say "Updating package repositoriy..."
			my-superuser apt-get update &> /dev/null
		fi
	}
	full_upgrade_(){
		my-superuser apt-get -y full-upgrade
	}
	Packages_upgrade_(){
		my-superuser apt-get -y upgrade
	}
	Package_remove_(){
		my-superuser apt-get purge -y "$@"
	}
	Package_list_(){
		for i in $(apt list --upgradable -a  2>/dev/null | awk -F/ '{print $1}' | grep -v Listing... | uniq)
		do 
			dpkg -l | grep -e "$i"
		done
	}
fi
