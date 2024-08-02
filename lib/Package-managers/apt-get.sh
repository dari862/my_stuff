if command -v nala >/dev/null 2>&1; then
	Package_installer_(){
		sudo nala install -y "$@"
	}
	Package_update_(){
		sudo nala update
	}
	full_upgrade_(){
		sudo nala -y upgrade
	}
	Package_remove_(){
		sudo nala purge -y "$@"
	}
else
	Package_installer_(){
		sudo apt-get install -y "$@"
	}
	Package_update_(){
		sudo apt-get update
	}
	full_upgrade_(){
		sudo apt-get -y full-upgrade
	}
	Package_remove_(){
		sudo apt-get purge -y "$@"
	}
fi
