usr_confdir="${XDG_CONFIG_HOME:-$HOME/.config}"
usr_locl_share_dir="$HOME/.local/share"
usr_setup_flag_file="$usr_locl_share_dir/usr-flag-setup"
usr_xsessionrc="$HOME/.xsessionrc"
usr_resources="$HOME/.config/x11/xresources"
xsessions_lib_path="${__distro_path_root}/lib/xsessions"

if [ -d "${__distro_path_root}/system_files/bin" ];then
	PATH="${__distro_path_root}/system_files/bin:$PATH"
else
	echo "ERROR: ${__distro_path_root}/system_files/bin Does not exist."
fi

if [ -d "${__distro_path_root}/system_files/binX11" ];then
	PATH="${__distro_path_root}/system_files/binX11:$PATH"
else
	echo "ERROR: ${__distro_path_root}/system_files/binX11 Does not exist."
fi

# This section is only executed on first boot.
if [ ! -f "$usr_setup_flag_file" ];then
    # Import user config files
    if [ -x "${xsessions_lib_path}"/skel_user_setup_ ];then
        if "${xsessions_lib_path}"/skel_user_setup_ "$usr_setup_flag_file";then
        	"${xsessions_lib_path}"/skel_user_setup_ "$usr_setup_flag_file" || echo "failed to run skel_user_setup_"
        fi
    fi

    # Actions here are usually handled by scripts in /etc/X11/Xsession.d/
    # but on first boot, user config files were not yet imported at that point.
    # This makes a difference to the live session, unless user logs out/in.

    # Merge ~/.Xresources
    # (usually done by /etc/X11/Xsession.d/30x11-common_xresources)
    command -v xrdb >/dev/null 2>&1 && test -r "$usr_resources" && xrdb -merge "$usr_resources" || echo "$0: cannot merge $usr_resources" >&2

    # Set up the user environment for X sessions.
    # (usually sourced by /etc/X11/Xsession.d/40x11-common_xsessionrc)
    #test -r "$usr_xsessionrc" && . "$usr_xsessionrc" || echo "$0: cannot source $usr_xsessionrc" >&2

    # Set up user directories
    # (usually run by /etc/X11/Xsession.d/60xdg-user-dirs-update)
    if [ -x /usr/bin/xdg-user-dirs-update ];then
        /usr/bin/xdg-user-dirs-update
    fi
    "${__distro_path_root}/bin/not_add_2_path"/set_git_aliases
fi

case $SHELL in
	*/bash)
    	[ -z "$BASH" ] && exec $SHELL $0 "$@"
		. ${HOME}/.config/myshell/profile.sh
		. ${HOME}/.config/myshell/bash/bprofile.sh
	;;
	*/zsh)
    	. ${HOME}/.config/myshell/profile.sh
    	. ${HOME}/.config/myshell/zsh/zprofile.sh
	;;
	*/csh|*/tcsh)
    	# [t]cshrc is always sourced automatically.
    	# Note that sourcing csh.login after .cshrc is non-standard.
    	xsess_tmp=$(mktemp /tmp/${HOME}/xsess-env-XXXXXX)
    	$SHELL -c "if (-f /etc/csh.login) source /etc/csh.login; if (-f ~/.login) so                                                                                                                                                                                 urce ~/.login; /bin/sh -c 'export -p' >! $xsess_tmp"
    	. $xsess_tmp
    	rm -f $xsess_tmp
	;;
	*/fish)
    	. ${HOME}/.config/myshell/profile.sh
		. ${HOME}/.config/myshell/bash/bprofile.sh
    	xsess_tmp=$(mktemp /tmp/${HOME}/xsess-env-XXXXXX)
    	$SHELL --login -c "/bin/sh -c 'export -p' > $xsess_tmp"
    	. $xsess_tmp
    	rm -f $xsess_tmp
	;;
	*) # Plain sh, ksh, and anything we do not know.
    	. ${HOME}/.config/myshell/profile.sh
		. ${HOME}/.config/myshell/bash/bprofile.sh
	;;
esac
