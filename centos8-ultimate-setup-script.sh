#!/bin/bash

GREEN=$(tput setaf 2)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [ "$(id -u)" = 0 ]; then
    echo "You're root! Run script as user" && exit 1
fi

# >>>>>> start of user settings <<<<<<

#==============================================================================
# git settings
#==============================================================================
git_email='hugmatj@gmail.com'
git_user_name='hugmatj'

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
# move dotfiles to the home directory, backup existing files and run stow
#==============================================================================
mv ./dotfiles ~/dotfiles

mv "$HOME/.bash_profile" "$HOME/.bash_profile_backup"
mv "$HOME/.bashrc" "$HOME/.bashrc_backup"

cd "$HOME/dotfiles" || exit
stow *
cd - || exit

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
        # https://github.com/Microsoft/vscode/issues/48480
        cat >>"$HOME/.bashrc" <<EOL
alias code="GTK_IM_MODULE=ibus code"
EOL
    }

#==============================================================================
# setup git user name and email if none exist
#==============================================================================
if [[ -z $(git config --get user.name) ]]; then
    git config --global user.name $git_user_name
    echo "No global git user name was set, I have set it to ${BOLD}$git_user_name${RESET}"
fi

if [[ -z $(git config --get user.email) ]]; then
    git config --global user.email $git_email
    echo "No global git email was set, I have set it to ${BOLD}$git_email${RESET}"
fi


#==============================================================================================
# misc
#==============================================================================================
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
touch "$HOME/Templates/empty-file" # so you can create new documents from nautilus

cat <<EOL
=================================================================
Gnome:    settings  > details > choose default applications
          network   > wired   > connect automatically

          gnome software > install 'Hide Top Bar'

flatpak run org.mozilla.firefox https://addons.mozilla.org/en-GB/firefox/addon/privacy-badger17/ \
https://addons.mozilla.org/en-GB/firefox/addon/ublock-origin/ \
https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/

Firefox:  Preferences > Network Settings > Enable DNS over HTTPS
          about:config network.security.esni.enabled
          (test with https://www.cloudflare.com/ssl/encrypted-sni/)

          Privacy & Security > HTTPS-Only Mode > Enable HTTPS-Only Mode in all windows

          Vimium:   New tab URL           : pages/blank.html
                    Default search engine : https://duckduckgo.com/?q=


Fix Visual Studio Code keyboard input
-------------------------------------
go to terminal type 'ibus-setup'
go to Emoji tab, press the '...' next to Emoji choice to get 'select keyboard shortcut for switching' window
use the delete button to delete the shortcut and leave nothing there, press OK
Close

Use local rust docs with flatpak firefox
----------------------------------------
about:config > security.fileuri.strict_origin_policy = false
flatpak override --user --filesystem=~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc:ro org.mozilla.firefox
flatpak override --user --show org.mozilla.firefox

Force NPM to use your home directory for global packages
--------------------------------------------------------
mkdir "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"


Please reboot (or things may not work as expected)
=================================================================
EOL
