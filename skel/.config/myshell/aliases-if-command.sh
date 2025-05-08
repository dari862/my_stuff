# Replace batcat with cat on Fedora as batcat is not available as a RPM in any form
if command -v batcat >/dev/null;then
	alias bat='batcat'
elif ! command -v bat >/dev/null;then
	alias bat='cat'
fi

if command -v fzf >/dev/null 2>&1;then
	alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
fi

# better find
if command -v fdfind >/dev/null 2>&1;then
	alias fd='fdfind'
fi

# better cd
if command -v zoxide >/dev/null 2>&1;then 
	alias z='zoxide'
fi

if command -v nvim > /dev/null;then
	alias vi='nvim'
	alias vis='nvim "+set si"'
	alias vim="nvim" 
	alias vimdiff="nvim -d"
	alias magit="nvim -c MagitOnly"
	alias svi='my-superuser nvim'
elif command -v vim > /dev/null;then
	alias vi='vim'
	alias svi='my-superuser vim'
elif command -v vi > /dev/null;then
	alias svi='my-superuser vi'
fi

if command -v docker > /dev/null;then
	alias d='docker'
fi

if command -v podman > /dev/null;then
	alias pd='podman'
fi

if command -v rails > /dev/null;then
	alias r='rails'
fi

if command -v lazygit > /dev/null;then
	alias lzg='lazygit'
fi

if command -v lazydocker > /dev/null;then
	alias lzd='lazydocker'
fi
