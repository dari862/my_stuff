$include /etc/inputrc
set editing-mode vi

set meta-flag on
set convert-meta off
set completion-ignore-case on
set completion-prefix-display-length 2
set show-all-if-ambiguous on
set show-all-if-unmodified on

# below line enables a completion menu when you press Tab with more than one possible completion.
# Instead of just showing the next option, your shell will display a menu listing all potential matches. You can then use the arrow keys and Enter to choose the desired completion.
#"TAB": menu-complete

## ------ auto edited by shortcuts script bindkey ------ ##
## ------ end of auto edited by shortcuts script bindkey ------ ##

set mark-symlinked-directories on

set match-hidden-files off

set page-completions off

set completion-query-items 200

set visible-stats on

$if Bash
  set skip-completed-text on
  set colored-stats on
$endif

$if mode=vi

set show-mode-in-prompt on
## ------ auto edited by shortcuts script show-mode-in-prompt ------ ##
## ------ end of auto edited by shortcuts script show-mode-in-prompt ------ ##

set keymap vi-command
## ------ auto edited by shortcuts script vi-command ------ ##
## ------ end of auto edited by shortcuts script vi-command ------ ##

set keymap vi-insert
## ------ auto edited by shortcuts script vi-insert ------ ##
## ------ end of auto edited by shortcuts script vi-insert ------ ##

$endif
