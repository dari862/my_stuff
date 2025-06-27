#!/bin/sh
# profile file. Runs on login. Environmental variables are set here.

# Default programs:
export EDITOR=nano
export VISUAL=$EDITOR
export CLI_EDITER=$EDITOR
export SUDO_EDITOR="${VISUAL}"
export TERMINAL="my-terminal-emulator"
export TERMINAL_PROG="${TERMINAL}"
export BROWSER="firefox" # librewolf

# myshell config dir
export My_X11_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/x11"
export My_shell_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/myshell"
export BASHDOTDIR="${My_shell_DIR}/bash"
export ZDOTDIR="${My_shell_DIR}/zsh"
export INPUTRC="${My_shell_DIR}/inputrc.sh"

# ~/ Clean-up:
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XINITRC="${My_X11_DIR}/xinitrc"
#export XDG_RUNTIME_DIR="/run/user/$UID"
#export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority" # This line will break some DMs.
export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"
export LESSHISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/lesshst"
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"

# histroy
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/bash_history/bash_history"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"

# Establish error file location
#export ERRFILE="$XDG_CACHE_HOME/X11/xsession-errors"

# Other program settings:
#export ALSA_CONFIG_PATH="$XDG_CONFIG_HOME/alsa/asoundrc"
#export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
#export KODI_DATA="$XDG_DATA_HOME/kodi"
#export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
#export ANDROID_SDK_HOME="$XDG_CONFIG_HOME/android"
#export CARGO_HOME="$XDG_DATA_HOME/cargo"
#export GOPATH="$XDG_DATA_HOME/go"
#export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
#export ANSIBLE_CONFIG="$XDG_CONFIG_HOME/ansible/ansible.cfg"
#export UNISON="$XDG_DATA_HOME/unison"
#export MBSYNCRC="$XDG_CONFIG_HOME/mbsync/config"
#export ELECTRUMDIR="$XDG_DATA_HOME/electrum"
#export ANSIBLE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ansible/ansible.cfg"

# fixes
#export AWT_TOOLKIT="MToolkit wmname LG3D"       #May have to install wmname
#export _JAVA_AWT_WM_NONREPARENTING=1      # Fix for Java applications in dwm

# better less
export LESS="R"
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
export LESS_TERMCAP_me="$(printf '%b' '[0m')"
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
export LESS_TERMCAP_se="$(printf '%b' '[0m')"
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"
export LESSOPEN="| /usr/bin/highlight -O ansi %s 2>/dev/null"

#Themeing
# Styling QT apps
export QT_QPA_PLATFORMTHEME=gtk2
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export MOZ_USE_XINPUT2="1"              # Mozilla smooth scrolling/touchpads.

if [ ! -d "$GNUPGHOME" ];then
	[ -d "$HOME/.gnupg" ] && mv "$HOME/.gnupg" "$GNUPGHOME"
	mkdir -p $GNUPGHOME
	chmod 700 $GNUPGHOME
fi

# Set environment path
export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin:/usr/games:/usr/local/games
# set PATH so it includes user's private bin if it exists
PATH="$HOME/.local/bin:$PATH"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ];then
    PATH="$HOME/bin:$PATH"
fi

# Python
# use PYTHONPYCACHEPREFIX to use a global cache, so python won't create
# __pycache__ directories in my projects
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHONPYCACHEPREFIX="$HOME/.cache/cpython/"s
# Manage multiple versions of Python using pyenv
if [ -d "$HOME/.pyenv" ];then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# Start graphical server on user's current tty if not already running.
[ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx "$XINITRC"

#enable PROMPT to INSTALL COMMAND_NOT_FOUND output
export COMMAND_NOT_FOUND_INSTALL_PROMPT=1

export GPG_TTY="${TTY:-$(tty)}"
