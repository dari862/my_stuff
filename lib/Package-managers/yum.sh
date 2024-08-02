Package_installer_(){
	sudo yum install -y "$@"
}
Package_update_(){
	sudo yum update -y
}
full_upgrade_(){
	sudo yum -y upgrade
}
Package_remove_(){
	sudo yum remove -y "$@"
}
