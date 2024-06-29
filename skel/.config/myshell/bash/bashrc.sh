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

if [ -f "/usr/share/DmDmDmdMdMdM/bin/bin/pfetch" ]; then
	pfetch
fi

if [[ -z "$BASHDOTDIR" ]];then
	export My_shell_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/myshell"
	export BASHDOTDIR="${My_shell_DIR}/bash"
fi

# ------------------------------- variables -----------------------------------
BASH_THEME="debian"

bashplugins=(
keychain
bash_completion
z
thefuck
kitty_auto_complete
zoxide
)

# Configure color-scheme
COLOR_SCHEME=dark # dark/light

# -------------------------------   Prompt  -----------------------------------
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

if builtin test -f $BASHDOTDIR/bashthemes/${BASH_THEME}.bash-prompt-theme; then
  		source $BASHDOTDIR/bashthemes/${BASH_THEME}.bash-prompt-theme
else
    	echo "BASH theme '$BASH_THEME' not found"
fi

# --------------------------------- SETTINGS ----------------------------------
# Source global definitions
if [ -f /etc/bashrc ]; then
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
if [[ $iatest -gt 0 ]]; then bind "set bell-style visible"; fi

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

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# ---------------------------------   binds  ----------------------------------
# below line make bash when pressing ctrl+f runs commnad zi .
bind '"\C-f":"zi\n"'

# below line makes Bash completion case-insensitive.
# When you start typing a command or filename and press Tab for completion, Bash will suggest matches regardless of uppercase or lowercase letters.
bind 'set completion-ignore-case on'

# below line instructs Bash to display all possible completions when the characters you typed could match multiple options.
# By default, Bash only shows a limited number of options if there's ambiguity. This setting ensures you see all possibilities.
bind 'set show-all-if-ambiguous on'

# below line enables a completion menu when you press Tab with more than one possible completion.
# Instead of just showing the next option, Bash will display a menu listing all potential matches. You can then use the arrow keys and Enter to choose the desired completion.
bind 'TAB:menu-complete'

# ---------------------------------  source  ----------------------------------
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ${BASHDOTDIR}/bash_only_aliases ]; then
    source ${BASHDOTDIR}/bash_only_aliases
fi

if [ -f ${BASHDOTDIR}/bash_only_functions ]; then
    source ${BASHDOTDIR}/bash_only_functions
fi

if [ -f $My_shell_DIR/aliases.sh ]; then
    source $My_shell_DIR/aliases.sh
fi

if [ -f $My_shell_DIR/misc.sh ]; then
    source $My_shell_DIR/misc.sh
fi

if [ -f $My_shell_DIR/functions.sh ]; then
    source $My_shell_DIR/functions.sh
fi

# ------------------------------- BASH PLUGINS Applyer --------------------------
# Add all defined plugins to fpath. This must be done
# before running compinit.
for bashplugin in ${bashplugins[@]}; do
	if builtin test -f $BASHDOTDIR/bplugins/${bashplugin}.plugin.bash; then
  		source $BASHDOTDIR/bplugins/${bashplugin}.plugin.bash
  	else
    		echo "plugin '$bashplugin' not found"
  	fi
done
# ---------------------------------  Extra  ----------------------------------
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
