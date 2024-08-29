Package_installer_(){
	my-superuser yum install -y "$@"
}
Package_update_(){
	my-superuser yum update -y
}
full_upgrade_(){
	my-superuser yum -y upgrade
}
Package_remove_(){
	my-superuser yum remove -y "$@"
}
