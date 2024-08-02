Package_installer_(){
	sudo zypper install -y "$@"
}
Package_update_(){
	sudo zypper refresh
}
full_upgrade_(){
	sudo zypper -y update
}
Package_remove_(){
	sudo zypper remove -y "$@"
}
