if command -v yay >/dev/null 2>&1; then
	Package_installer_(){
		yay --noconfirm -S "$@"
	}
	Package_update_(){
		yay -Syu --noconfirm
	}
	full_upgrade_(){
		yay -Syu --noconfirm
	}
	Package_remove_(){
		yay -Rs "$@"
	}
elif command -v paru >/dev/null 2>&1; then
	Package_installer_(){
		paru --noconfirm -S "$@"
	}
	Package_update_(){
		paru -Syu --noconfirm
	}
	full_upgrade_(){
		paru -Syu --noconfirm
	}
	Package_remove_(){
		paru -Rs "$@"
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
	Package_remove_(){
		my-superuser pacman -Rs "$@"
	}
fi
