#!/bin/sh
set -e
# need superuser : called by my-superuser and install by my-installer
distro_path="${__distro_path_root}/system_files"
skel_path="${distro_path}/skel"
nvim_skel_path="${skel_path}/.config/nvim"

__choice=""


if [ "${__choice}" = "1" ];then
	vim_extra="Lazyvim"
elif [ "${__choice}" = "2" ];then
	vim_extra="kickstart"
elif [ "${__choice}" = "3" ];then
	vim_extra="ThePrimeagen"
elif [ "${__choice}" = "4" ];then
	vim_extra="kickstart_titus"
else
	vim_extra=""
fi

if [ ! -z "${vim_extra}" ];then
	[ -d "${nvim_skel_path}" ] && my-superuser rm -rdf ${nvim_skel_path}
	
	if [ "${vim_extra}" = "Lazyvim" ];then
		super_clone_repo https://github.com/LazyVim/starter ${nvim_skel_path} || continue
		my-superuser rm -rf ${nvim_skel_path}/.git
		
		# Disable update notification popup in starter config
		my-superuser sed -i 's/checker = { enabled = true }/checker = { enabled = true, notify = false }/g' "${nvim_skel_path}"/lua/config/lazy.lua || continue
		copy_from_extra_skel ".config/neovim" || continue
		
	elif [ "${vim_extra}" = "kickstart" ];then
		my-superuser mkdir -p ${nvim_skel_path}
		getURL '2term' https://raw.githubusercontent.com/nvim-lua/kickstart.nvim/master/init.lua | my-superuser tee ${nvim_skel_path}/init.lua >/dev/null 2>&1 || continue
	elif [ "${vim_extra}" = "ThePrimeagen" ];then
		my-superuser mkdir -p ${skel_path}/personal
		cd ${skel_path}/personal
		super_clone_repo https://github.com/ThePrimeagen/vim-apm.git
		super_clone_repo https://github.com/ThePrimeagen/vim-with-me.git
		super_clone_repo https://github.com/ThePrimeagen/vim-arcade.git
		super_clone_repo https://github.com/ThePrimeagen/caleb.git
		super_clone_repo https://github.com/nvim-lua/plenary.nvim.git
		
		super_clone_repo https://github.com/ThePrimeagen/harpoon.git
		cd harpoon
		my-superuser git fetch
		my-superuser git checkout harpoon2
		copy_from_extra_skel ".config/nvim" || continue
	elif [ "${vim_extra}" = "kickstart_titus" ];then
		super_clone_repo https://github.com/ChrisTitusTech/neovim.git /tmp/ChrisTitusTech_neovim || continue
		my-superuser rm -rdf /tmp/ChrisTitusTech_neovim/titus-kickstart/nvim || continue
		[ -d "${nvim_skel_path}" ] && rm -rdf "${nvim_skel_path}"
		my-superuser mv /tmp/ChrisTitusTech_neovim/titus-kickstart "${nvim_skel_path}" || continue
		my-superuser mkdir -p ${skel_path}/.vim/undodir
		my-superuser mkdir -p ${skel_path}/.scripts
	fi
	
	for d in /home/*; do
    	user_and_group=$(stat "$(dirname "$d/.config")" -c %u:%g)
    	if [ -d "$d/.config/nvim" ];then
    		if [ "${vim_extra}" = "kickstart_titus" ];then
    			my-superuser cp -rv ${skel_path}/.scripts "$d/" || continue
    			my-superuser chown -R $user_and_group "$d/.scripts" || continue
    			my-superuser cp -rv ${skel_path}/.vim "$d/" || continue
    			my-superuser chown -R $user_and_group "$d/.vim" || continue
    		elif [ "${vim_extra}" = "ThePrimeagen" ];then
    			my-superuser cp -rv ${skel_path}/personal "$d/" || continue
    			my-superuser chown -R $user_and_group "$d/personal" || continue
    		fi
			my-superuser cp -rv ${nvim_skel_path} "$d/.config" || continue
			my-superuser chown -R $user_and_group "$d/.config/nvim" || continue
		fi
	done
fi

say 'Creating applications shortcut...' 1

create_applicationsdotdesktop_link "nvim" || continue
cp -r "${__distro_path_root}/bin/not_add_2_path/my-vim" "${__distro_path_system_files}/bin"

clear

"${app_name}"
