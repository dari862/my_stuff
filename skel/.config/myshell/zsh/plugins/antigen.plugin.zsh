# change default antigen folder
export ADOTDIR="$ZDOTDIR/antigen"
# sourcing antigen
source /usr/share/zsh-antigen/antigen.zsh
# sourcing my antigen stuff
source "$ZDOTDIR/antigen-plugins-list.sh"
# Tell Antigen that you are done.
antigen apply
