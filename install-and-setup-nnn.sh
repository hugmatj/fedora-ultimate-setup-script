#!/usr/bin/env sh

curl -LOf https://github.com/jarun/nnn/releases/download/v4.0/nnn-4.0-1.el8.0.centos.x86_64.rpm
chmod +x ./nnn-4.0-1.el8.0.centos.x86_64.rpm 
sudo dnf install ./nnn-4.0-1.el8.0.centos.x86_64.rpm
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh

# Download the following script to anywhere in your PATH
# curl https://raw.githubusercontent.com/mpv-player/mpv/master/TOOLS/umpv -o "$HOME/Documents/scripts/umpv"

cat >"$HOME/.config/nnn/plugins/addtoplaylist" <<'EOL'
#!/usr/bin/env sh
# Open selected files in MPV playlist

player="umpv"
selection=${NNN_SEL:-${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}
if [ -s "$selection" ]; then
    xargs -0 "$player" <"$selection"
else
    "$player" "$1"
fi
EOL

chmod +x "$HOME/.config/nnn/plugins/addtoplaylist"

cat >>"$HOME/.bashrc" <<'EOL'
export NNN_PLUG="p:addtoplaylist;f:fzcd"
export NNN_BMS='d:~/Documents;D:~/Downloads;p:~/Pictures;v:~/Videos;m:~/Music;h:~/'
export NNN_TRASH=1

# -e open text in $VISUAL/$EDITOR/vi, -x selection to system clipboard
alias nnn="nnn -xe"
EOL
