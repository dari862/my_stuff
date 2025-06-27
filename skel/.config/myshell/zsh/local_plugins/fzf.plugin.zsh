if command -v fzf >/dev/null 2>&1;then
  zstyle ':completion:*:*:*:default' menu yes select search
  source /usr/share/my_stuff/lib/auto_completion/key-bindings.zsh
fi
