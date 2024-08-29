Package_installer_(){
	my-superuser dnf install -y "$@"
}
Package_update_(){
	my-superuser dnf update -y
}
full_upgrade_(){
	my-superuser dnf -y upgrade
}
Package_remove_(){
	my-superuser dnf remove -y "$@"
}
