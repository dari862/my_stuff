Package_installer_(){
	my-superuser zypper install -y "$@"
}
Package_update_(){
	my-superuser zypper refresh
}
full_upgrade_(){
	my-superuser zypper -y update
}
Package_remove_(){
	my-superuser zypper remove -y "$@"
}
