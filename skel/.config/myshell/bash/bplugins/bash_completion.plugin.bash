# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
  
  if [ -d "/usr/share/DmDmDmdMdMdM/lib/auto_completion" ]; then
  	for f in /usr/share/DmDmDmdMdMdM/lib/auto_completion/*;do
  		[ -f "$f" ] && source $f
  	done
  fi
fi
