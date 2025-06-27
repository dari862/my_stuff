$include /etc/inputrc

set meta-flag on
set convert-meta off
set completion-ignore-case on
set completion-prefix-display-length 2
set show-all-if-ambiguous on
set show-all-if-unmodified on

## ------ auto edited by shortcuts script bindkey ------ ##
## ------ end of auto edited by shortcuts script bindkey ------ ##

# below line enables a completion menu when you press Tab with more than one possible completion.
# Instead of just showing the next option, your shell will display a menu listing all potential matches. You can then use the arrow keys and Enter to choose the desired completion.
#"TAB": menu-complete

set mark-symlinked-directories on

set match-hidden-files off

set page-completions off

set completion-query-items 200

set visible-stats on

$if Bash
  set skip-completed-text on
  set colored-stats on
$endif
