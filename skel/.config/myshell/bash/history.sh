# Allow ctrl-S for history navigation (with ctrl-R)
stty -ixon
# Expand the history size
export HISTTIMEFORMAT='%F %T '
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTIGNORE="ls:cd:pwd:exit:sudo reboot:history:cd -:cd ..:doas reboot:my-superuser reboot"
export HISTFILE=$BASHDOTDIR/bash_history

# Don't put duplicate lines in the history
export HISTCONTROL=erasedups:ignoredups

shopt -s histappend              # Append to history, don't overwrite

# Immediately write history
PROMPT_COMMAND='history -a'
