#!/bin/zsh

# Simple prompt with path in the window/pane title and carat for typing line
PROMPT=$'\uf0a9 '
PROMPT="\[\e]0;\w\a\]$PS1"
