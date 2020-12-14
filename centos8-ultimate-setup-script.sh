#!/bin/bash

# Centos Ultimate Install Script v5 05/2020

# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# ~/.fzf/install

GREEN=$(tput setaf 2)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [ "$(id -u)" = 0 ]; then
    echo "You're root! Run script as user" && exit 1
fi

# >>>>>> start of user settings <<<<<<

#==============================================================================
# gnome desktop settings
#==============================================================================
idle_delay=2400
title_bar_buttons_on="true"
clock_show_date="true"
capslock_delete="true"
night_light="true"
autostart_apps="true"

#==============================================================================
# git settings
#==============================================================================
git_email='example@example.com'
git_user_name='example_name'

#==============================================================================
# php.ini settings
#==============================================================================
upload_max_filesize=128M
post_max_size=128M
max_execution_time=60

# >>>>>> end of user settings <<<<<<

#==============================================================================
# display user settings
#==============================================================================
clear
cat <<EOL
Don't run this script more than once or you may get duplication in settings files

${BOLD}Gnome settings${RESET}
${BOLD}-------------------${RESET}

Increase the delay before the desktop logs out: ${GREEN}$idle_delay${RESET} seconds
Add minimize, maximize and close buttons to windows: ${GREEN}$title_bar_buttons_on${RESET}
Display the date on the desktop: ${GREEN}$clock_show_date${RESET}
Change caps into a backspace for touch typing: ${GREEN}$capslock_delete${RESET}
Turn on night light: ${GREEN}$night_light${RESET}
Run certain apps on start: ${GREEN}$autostart_apps${RESET}

${BOLD}Git settings${RESET}
${BOLD}-------------------${RESET}

Global email: ${GREEN}$git_email${RESET}
Global user name: ${GREEN}$git_user_name${RESET}

${BOLD}PHP settings${RESET} (only if PHP is installed)
${BOLD}-------------------${RESET}

upload_max_filesize: ${GREEN}$upload_max_filesize${RESET}
post_max_size: ${GREEN}$post_max_size${RESET}
max_execution_time: ${GREEN}$max_execution_time${RESET}

EOL
read -rp "Press enter to setup, or ctrl+c to quit"

#==============================================================================
# set host name
#==============================================================================
read -rp "What is this computer's name? [$HOSTNAME] " hostname
if [[ ! -z "$hostname" ]]; then
    hostnamectl set-hostname "$hostname"
fi

#==============================================================================
# setup software (if it is installed)
#==============================================================================
hash mpv 2>/dev/null &&
    #==========================================================================
    # MPV
    #==========================================================================
    {
        mkdir -p "$HOME/.config/mpv"
        cat >"$HOME/.config/mpv/mpv.conf" <<EOL
profile=gpu-hq
hwdec=auto
fullscreen=yes
EOL
    }

hash php 2>/dev/null &&
    #==========================================================================
    # PHP
    #==========================================================================
    {
        for key in upload_max_filesize post_max_size max_execution_time; do
            sudo sed -i "s/^\($key\).*/\1 = ${!key}/" /etc/php.ini
        done
    }

hash code 2>/dev/null &&
    #==========================================================================
    # Visual Studio Code
    #==========================================================================
    {
        # Allow ban.spellright to access built in hunspell directories
        sudo ln -s /usr/share/myspell "$HOME/.config/Code/Dictionaries"
        # https://github.com/Microsoft/vscode/issues/48480
        cat >>"$HOME/.bashrc" <<EOL
alias code="GTK_IM_MODULE=ibus code"
EOL
    }

#==============================================================================
# setup gnome desktop gsettings
#==============================================================================
echo "${BOLD}Setting up Gnome desktop gsettings...${RESET}"

gsettings set org.gnome.desktop.session \
    idle-delay $idle_delay

if [[ "${title_bar_buttons_on}" == "true" ]]; then
    gsettings set org.gnome.desktop.wm.preferences \
        button-layout 'appmenu:minimize,maximize,close'
fi

if [[ "${clock_show_date}" == "true" ]]; then
    gsettings set org.gnome.desktop.interface \
        clock-show-date true
fi

if [[ "${capslock_delete}" == "true" ]]; then
    gsettings set org.gnome.desktop.input-sources \
        xkb-options "['caps:backspace', 'terminate:ctrl_alt_bksp']"
fi

if [[ "${night_light}" == "true" ]]; then
    gsettings set org.gnome.settings-daemon.plugins.color \
        night-light-enabled true
fi

if [[ "${autostart_apps}" == "true" ]]; then
    mkdir "$HOME/.config/autostart"
    touch "$HOME/Documents/TODO.txt"
    cat >"$HOME/.config/autostart/org.gnome.gedit.desktop" <<'EOL'
[Desktop Entry]
Name=Text Editor
Exec=gedit Documents/TODO.txt
Type=Application
EOL

    cat >"$HOME/.config/autostart/org.gnome.Terminal.desktop" <<'EOL'
[Desktop Entry]
Name=Terminal
Exec=gnome-terminal
Type=Application
EOL
fi

#==============================================================================
# setup pulse audio with the best sound quality possible
#
# *pacmd list-sinks | grep sample and see bit-depth available for interface
# *pulseaudio --dump-re-sample-methods and see re-sampling available
#
# *MAKE SURE your interface can handle s32le 32bit rather than the default 16bit
#==============================================================================
echo "${BOLD}Setting up Pulse Audio...${RESET}"
sudo sed -i "s/; default-sample-format = s16le/default-sample-format = s32le/g" /etc/pulse/daemon.conf
sudo sed -i "s/; resample-method = speex-float-1/resample-method = speex-float-10/g" /etc/pulse/daemon.conf
sudo sed -i "s/; avoid-resampling = false/avoid-resampling = true/g" /etc/pulse/daemon.conf

#==============================================================================
# setup jack audio for real time use
#==============================================================================
# sudo usermod -a -G jackuser "$USERNAME" # Add current user to jackuser group
# sudo tee /etc/security/limits.d/95-jack.conf <<EOL
# # Default limits for users of jack-audio-connection-kit

# @jackuser - rtprio 98
# @jackuser - memlock unlimited

# @pulse-rt - rtprio 20
# @pulse-rt - nice -20
# EOL

#==============================================================================
# setup git user name and email if none exist
#==============================================================================
echo "${BOLD}Setting up Git...${RESET}"
if [[ -z $(git config --get user.name) ]]; then
    git config --global user.name $git_user_name
    echo "No global git user name was set, I have set it to ${BOLD}$git_user_name${RESET}"
fi

if [[ -z $(git config --get user.email) ]]; then
    git config --global user.email $git_email
    echo "No global git email was set, I have set it to ${BOLD}$git_email${RESET}"
fi

#==============================================================================================
# turn on subpixel rendering for fonts without fontconfig support
#==============================================================================================
if ! grep -xq "Xft.lcdfilter: lcddefault" "$HOME/.Xresources"; then
    echo "Xft.lcdfilter: lcddefault" >>"$HOME/.Xresources"
fi

#==============================================================================================
# improve ls and tree commands output, add f recursive find function
#==============================================================================================
cat >>"$HOME/.bashrc" <<'EOL'
alias ls="ls -ltha --color --group-directories-first" # l=long listing format, t=sort by modification time (newest first), h=human readable sizes, a=print hidden files
alias tree="tree -Catr --noreport --dirsfirst --filelimit 100" # -C=colorization on, a=print hidden files, t=sort by modification time, r=reversed sort by time (newest first)
f() { find . -name "*$1*"; }
EOL

#==============================================================================================
# misc
#==============================================================================================
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
touch "$HOME/Templates/empty-file" # so you can create new documents from nautilus

cat <<EOL
=================================================================
Gnome:    settings  > details > choose default applications
          tweaks    > fonts   > change to Subpixel (for LCD screens)
          network   > wired   > connect automatically

          gnome software > install 'Hide Top Bar' 'Auto Move Windows'

flatpak run org.mozilla.firefox https://addons.mozilla.org/en-GB/firefox/addon/privacy-badger17/ \
https://addons.mozilla.org/en-GB/firefox/addon/ublock-origin/ \
https://addons.mozilla.org/en-US/firefox/addon/df-youtube/ \
https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/

Firefox:  Preferences > Network Settings > Enable DNS over HTTPS
          about:config network.security.esni.enabled
          (test with https://www.cloudflare.com/ssl/encrypted-sni/)

          Privacy & Security > HTTPS-Only Mode > Enable HTTPS-Only Mode in all windows

          Vimium:   New tab URL           : pages/blank.html
                    Default search engine : https://duckduckgo.com/?q=

For VS Code in Centos 8/8.1:

go to terminal type 'ibus-setup'
go to Emoji tab, press the '...' next to Emoji choice to get 'select keyboard shortcut for switching' window
use the delete button to delete the shortcut and leave nothing there, press OK
Close

If you install rust, to use 'rustup doc' in flatpak Firefox:
- about:config > security.fileuri.strict_origin_policy = false
- flatpak override --user --filesystem=~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc:ro org.mozilla.firefox
- flatpak override --user --show org.mozilla.firefox

Please reboot (or things may not work as expected)
=================================================================
EOL
