# use `keychain` for ssh-agent management
if [[ -x /usr/bin/keychain ]];then
  keychain ~/.ssh/${HOSTNAME}
  . "${HOME}/.keychain/${HOSTNAME}-sh"
fi
