if command -v yay >/dev/null 2>&1;then
	Package_installer_(){
		yay --noconfirm -S "$@"
	}
	Package_update_(){
		yay -Syu --noconfirm
	}
	full_upgrade_(){
		yay -Syu --noconfirm
	}
	Packages_upgrade_(){
		my-superuser apt-get -y upgrade
	}
	Package_remove_(){
		yay -Rs "$@"
	}
	Package_list_(){
		for i in $(apt list --upgradable -a  2>/dev/null | awk -F/ '{print $1}' | grep -v Listing... | uniq)
		do 
			dpkg -l | grep -e "$i"
		done
	}
elif command -v paru >/dev/null 2>&1;then
	Package_installer_(){
		paru --noconfirm -S "$@"
	}
	Package_update_(){
		paru -Syu --noconfirm
	}
	full_upgrade_(){
		paru -Syu --noconfirm
	}
	Packages_upgrade_(){
		my-superuser apt-get -y upgrade
	}
	Package_remove_(){
		paru -Rs "$@"
	}
	Package_list_(){
		for i in $(apt list --upgradable -a  2>/dev/null | awk -F/ '{print $1}' | grep -v Listing... | uniq)
		do 
			dpkg -l | grep -e "$i"
		done
	}
else
	Package_installer_(){
		my-superuser pacman --noconfirm -S "$@"
	}
	Package_update_(){
		my-superuser pacman -Syu --noconfirm
	}
	full_upgrade_(){
		my-superuser pacman -Syu --noconfirm
	}
	Packages_upgrade_(){
		my-superuser apt-get -y upgrade
	}
	Package_remove_(){
		my-superuser pacman -Rs "$@"
	}
	Package_list_(){
		for i in $(apt list --upgradable -a  2>/dev/null | awk -F/ '{print $1}' | grep -v Listing... | uniq)
		do 
			dpkg -l | grep -e "$i"
		done
	}
fi

install_deb(){
	deb_name="${1-}"
	my-superuser apt-get install -y ${deb_name}
}
