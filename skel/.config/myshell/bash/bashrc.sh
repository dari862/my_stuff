#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# -------------------------------  Checks  -----------------------------------
distro_fetch

# ------------------------------- variables -----------------------------------
bashplugins=(
keychain
theoops
kitty_auto_complete
fzf
mise
command-not-found
lesspipe
)
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

# -------------------------------   Prompt  -----------------------------------
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r "/etc/debian_chroot" ];then
    debian_chroot=$(cat /etc/debian_chroot)
fi

if [[ -n "$SSH_CONNECTION" ]];then
	BASH_THEME="$SSH_THEME"
	PATH="${__distro_path_root}/system_files/binX11:$PATH"
else
	SSH_THEME=""
	SSH_MESS=""
fi

if [[ -z "$BASH_THEME" ]];then
	BASH_THEME="pure"
fi

if [[ -f "$BASHDOTDIR/themes/${BASH_THEME}.bash-prompt-theme" ]];then
  		source "$BASHDOTDIR/themes/${BASH_THEME}.bash-prompt-theme"
else
    	echo "BASH theme: $BASH_THEME not found"
fi

# --------------------------------- Settings ----------------------------------

# --------------------------------- History ----------------------------------
source "$BASHDOTDIR/history.sh"

# --------------------------------- Others  ----------------------------------
# Better management
shopt -s checkwinsize            # Check window size after each command
shopt -s cdspell                 # Autocorrect typos in path names when using cd
shopt -s dirspell                # Correct directory name typos
shopt -s autocd                  # Type directory name to cd
shopt -s nocaseglob              # Case-insensitive globbing
shopt -s extglob                 # Extended pattern matching
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
if [[ "$(expr index "$-" i)" -gt 0 ]];then bind "set bell-style visible"; fi

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
for bashplugin in ${bashplugins[@]}; do
	if builtin test -f $BASHDOTDIR/plugins/${bashplugin}.plugin.bash;then
  		source $BASHDOTDIR/plugins/${bashplugin}.plugin.bash
  	else
    		echo "plugin '$bashplugin' not found"
  	fi
done

# ---------------------------------  completion  ----------------------------------
if [ -d "(((__distro_path_root)))/system_files/completion/bash" ];then
	for f in "(((__distro_path_root)))/system_files/completion/bash"/*;do
		[ -f "$f" ] && source $f
	done
fi

# ---------------------------------  Extra  ----------------------------------
  
