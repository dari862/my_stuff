#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# -------------------------------  Checks  -----------------------------------
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

iatest=$(expr index "$-" i)

pfetch

# ------------------------------- variables -----------------------------------
bashplugins=(
keychain
bash_completion
thefuck
kitty_auto_complete
fzf
mise
command-not-found
lesspipe
)

# Configure color-scheme
COLOR_SCHEME=dark # dark/light

# -------------------------------   Prompt  -----------------------------------
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r "/etc/debian_chroot" ];then
    debian_chroot=$(cat /etc/debian_chroot)
fi

if [[ -n $SSH_CONNECTION ]] || [[ -z $BASH_THEME ]];then
  BASH_THEME="debian"
fi

if [[ -f "$BASHDOTDIR/themes/${BASH_THEME}.bash-prompt-theme" ]];then
  		source "$BASHDOTDIR/themes/${BASH_THEME}.bash-prompt-theme"
else
    	echo "BASH theme: $BASH_THEME not found"
fi

# --------------------------------- SETTINGS ----------------------------------
# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500

HISTFILE=$BASHDOTDIR/bash_history

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# Source global definitions
if [ -f /etc/bashrc ];then
	. /etc/bashrc
fi

# The command shopt -s globstar in bash enables the use of the globstar pattern (**) for filename expansion.
# By default, the * wildcard in bash only matches files within the current directory level.
# The ** pattern, also known as globstar, allows matching files across multiple subdirectories within a directory tree.
# Example:
# Without globstar:
# ls dir/* - This will only list files directly inside the "dir" directory.
# With globstar enabled (shopt -s globstar):
# ls dir/**/*.txt - This will list all .txt files within the "dir" directory and all its subdirectories.

shopt -s globstar

# Disable the bell
if [[ "$iatest" -gt 0 ]];then bind "set bell-style visible"; fi

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

# ---------------------------------   binds  ----------------------------------
# below line make bash when pressing ctrl+f runs commnad zi .
## ------ auto edited by shortcuts script ------ ##
## ------ end of auto edited by shortcuts script ------ ##
# ---------------------------------  source  ----------------------------------
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f "${BASHDOTDIR}"/aliases ];then
    source ${BASHDOTDIR}/aliases
fi

if [ -f "${BASHDOTDIR}"/functions ];then
    source ${BASHDOTDIR}/functions
fi

if [ -f "$My_shell_DIR"/aliases.sh ];then
    source $My_shell_DIR/aliases.sh
fi

if [ -f "$My_shell_DIR"/aliases-if-command.sh ];then
    source $My_shell_DIR/aliases-if-command.sh
fi

if [ -f "$My_shell_DIR"/misc.sh ];then
    source $My_shell_DIR/misc.sh
fi

if [ -f "$My_shell_DIR"/functions.sh ];then
    source $My_shell_DIR/functions.sh
fi

# ------------------------------- BASH PLUGINS Applyer --------------------------
# Add all defined plugins to fpath. This must be done
# before running compinit.
if command -v zoxide >/dev/null 2>&1;then
	bashplugin+=(zoxide)
else
	bashplugin+=(z)
fi

if command -v npm >/dev/null 2>&1;then
	bashplugin+=(npm)
fi

for bashplugin in ${bashplugins[@]}; do
	if builtin test -f $BASHDOTDIR/plugins/${bashplugin}.plugin.bash;then
  		source $BASHDOTDIR/plugins/${bashplugin}.plugin.bash
  	else
    		echo "plugin '$bashplugin' not found"
  	fi
done
# ---------------------------------  Extra  ----------------------------------

if [ "$vim_mode_enabled" = true ];then
	set -o vi
	# Use `bind` to detect mode changes
	bind 'set show-mode-in-prompt on'
	bind 'set vi-ins-mode-string \1\e[0;32m>\e[0m '
	bind 'set vi-cmd-mode-string \1\e[0;31m<\e[0m '
fi
