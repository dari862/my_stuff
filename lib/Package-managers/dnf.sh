Package_installer_(){
	sudo dnf install -y "$@"
}
Package_update_(){
	sudo dnf update -y
}
full_upgrade_(){
	sudo dnf -y upgrade
}
Package_remove_(){
	sudo dnf remove -y "$@"
}
