# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix;then
  if [ -f /usr/share/bash-completion/bash_completion ];then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ];then
    . /etc/bash_completion
  fi
  
  if [ -d "/usr/share/my_stuff/system_files/auto_completion" ];then
  	for f in /usr/share/my_stuff/system_files/auto_completion/*;do
  		[ -f "$f" ] && source $f
  	done
  fi
fi
