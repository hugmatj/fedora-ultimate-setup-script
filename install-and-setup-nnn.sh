#!/usr/bin/env sh

#==============================================================================
# Set directory and URL locations as global variables
#==============================================================================
NNN_LOCATION=https://download.opensuse.org/repositories/home:/stig124:/nnn/CentOS_8/x86_64/
NNN_FILENAME=nnn-4.1.1-1.3.x86_64.rpm

curl -LOf $NNN_LOCATION$NNN_FILENAME
chmod +x ./$NNN_FILENAME
sudo dnf install ./$NNN_FILENAME
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

#==============================================================================
# Add settings to .bashrc 
#==============================================================================
function add_to_bashrc() {
    grep -qxF "$1" "$HOME/.bashrc" || echo "$1" >>"$HOME/.bashrc"
}

add_to_bashrc 'export NNN_PLUG="p:addtoplaylist;f:fzcd"'
add_to_bashrc "export NNN_BMS='d:~/Documents;D:~/Downloads;p:~/Pictures;v:~/Videos;m:~/Music;h:~/'"
add_to_bashrc "export NNN_TRASH=1"
add_to_bashrc 'alias nnn="nnn -xe"'
