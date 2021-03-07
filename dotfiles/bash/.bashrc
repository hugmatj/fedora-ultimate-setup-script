# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
PATH="$HOME/.local/bin:$HOME/bin:$HOME/bin/ums:$HOME/.deno/bin:$HOME/Documents/scripts:$HOME/.npm-global/bin:$PATH"
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

alias ls="ls -ltha --color --group-directories-first"
alias tree="tree -Catr --noreport --dirsfirst --filelimit 100"
alias diff="diff -u --color=always" # add '| less -r' for full color output using less

stty -ixon # disable terminal flow control to free ctrl-s for shortcut

# search recursively for a file containing a part of the search term and ignore errors, reverse sort by modification time
f() { find . -iname "*$1*" -exec ls -1rt "{}" +; } 2>/dev/null
# copy to clipboard
clip() { xclip -sel clip -rmlastnl; }

set -o vi
bind -m vi-insert '"jk": vi-movement-mode'

source "$HOME/.cargo/env"
export NNN_PLUG="p:addtoplaylist"
