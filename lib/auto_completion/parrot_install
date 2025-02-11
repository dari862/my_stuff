# Debian parrot_install(8) completion                             -*- shell-script -*-

_parrot_install()
{
    local cur words cword
    _init_completion || return

    # see if the user selected a command already
    local COMMANDS=("install" "reinstall")

    local command i
    for (( i=1; i < ${#words[@]}; i++ )); do
        if [[ " ${COMMANDS[*]} " == *" ${words[i]} "* ]];then
            command=${words[i]}
            break
        fi
    done
    
    if [[ "$cur" == .* || "$cur" == /* || "$cur" == ~* ]];then
    	_filedir "deb"
    else
    	COMPREPLY=( $( apt-cache --no-generate pkgnames "$cur" \
    	2> /dev/null ) )
    fi
    return 0
} &&
complete -F _parrot_install parrot_install

# ex: ts=4 sw=4 et filetype=sh
