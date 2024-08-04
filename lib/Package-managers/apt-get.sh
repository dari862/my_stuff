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
	Package_remove_(){
		my-superuser nala purge -y "$@"
	}
else
	Package_installer_(){
		my-superuser apt-get install -y "$@"
	}
	Package_update_(){
		my-superuser apt-get update
	}
	full_upgrade_(){
		my-superuser apt-get -y full-upgrade
	}
	Package_remove_(){
		my-superuser apt-get purge -y "$@"
	}
fi
