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
Package_list_(){
	for i in $(apt list --upgradable -a  2>/dev/null | awk -F/ '{print $1}' | grep -v Listing... | uniq)
	do 
		dpkg -l | grep -e "$i"
	done
}
Packages_upgrade_(){
	my-superuser apt-get -y upgrade
}
install_deb(){
	deb_name="${1-}"
	my-superuser apt-get install -y ${deb_name}
}
