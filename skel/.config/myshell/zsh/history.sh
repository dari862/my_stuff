setopt HIST_BEEP
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt appendhistory
setopt hist_ignore_space
export HISTFILE=$ZDOTDIR/zsh_history
export HISTTIMEFORMAT="%F %T "
export HIST_STAMPS=dd/mm/yyyy
export HISTSIZE=5000
export SAVEHIST=5000
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..|doas reboot|my-superuser reboot)"
export HISTDUP=erase
