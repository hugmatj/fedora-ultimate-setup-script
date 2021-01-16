#!/bin/bash

#==============================================================================
#
#         FILE: fedora-ultimate-install-script.sh
#        USAGE: sudo fedora-ultimate-install-script.sh
#
#  DESCRIPTION: Post-installation install script for Fedora 29/30/31/32 Workstation
#      WEBSITE: https://github.com/David-Else/fedora-ultimate-setup-script
#
# REQUIREMENTS: Fresh copy of Fedora 30/31/32 installed on your computer
#       AUTHOR: David Else
#      COMPANY: https://www.elsewebdevelopment.com/
#      VERSION: 5.1
#
#      TODO if ban.spellright ln -s /usr/share/myspell ~/.config/Code/Dictionaries
#      WineHQ repo set for Fedora 33
#==============================================================================

#==============================================================================
# script settings and checks
#==============================================================================
set -euo pipefail
exec 2> >(tee "error_log_$(date -Iseconds).txt")

GREEN=$(tput setaf 2)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [ "$(id -u)" != 0 ]; then
    echo "You're not root! Run script with sudo" && exit 1
fi

if [[ $(rpm -E %fedora) -lt 29 ]]; then
    echo >&2 "You must install at least ${GREEN}Fedora 29${RESET} to use this script" && exit 1
fi

# >>>>>> start of user settings <<<<<<

#==============================================================================
# common packages to install/remove *arrays can be left empty, but don't delete
#==============================================================================
packages_to_remove=(
    rhythmbox
    totem
    cheese
    gnome-photos
    gnome-documents
)

packages_to_install=(
    borgbackup
    ffmpeg
    keepassxc
    transmission-gtk
    fuse-exfat
    mpv
    gnome-tweaks
    mediainfo
    syncthing
    libva-intel-driver
    deadbeef
    chromium
    chromium-libs-media-freeworld
    lshw
    shotwell
    java-1.8.0-openjdk
    jack-audio-connection-kit
    mkvtoolnix-gui
    tldr
    dolphin-emu
    mame
    gnome-shell-extension-pomodoro
    gnome-shell-extension-auto-move-windows.noarch
    winehq-stable)

flathub_packages_to_install=(
    org.kde.krita
    org.kde.okular
    fr.handbrake.ghb
    net.sf.fuse_emulator)

#==============================================================================
# Ask for user input
#==============================================================================
clear
read -p "Are you going to use this machine for web development? (y/n) " -n 1 webdev
echo
echo

if [[ $webdev =~ ^[Yy]$ ]]; then
    #==========================================================================
    # packages for web development option * deno added if selected
    #==========================================================================
    developer_packages=(
        gh
        code
        php
        nodejs
        docker
        docker-compose
        nodejs
        composer
        ShellCheck
        zeal)

    composer_packages_to_install=(
        squizlabs/php_codesniffer
        wp-coding-standards/wpcs
        wp-cli/wp-cli-bundle)

    node_global_packages_to_install=(
        pnpm)

    packages_to_install+=("${developer_packages[@]}")

elif [[ ! $webdev =~ ^[Nn]$ ]]; then
    echo "Invalid selection" && exit 1
fi

# >>>>>> end of user settings <<<<<<

#==============================================================================
# display user settings
#==============================================================================
cat <<EOL
${BOLD}Packages to install${RESET}
${BOLD}-------------------${RESET}

DNF packages: ${GREEN}${packages_to_install[*]}${RESET}

Flathub packages: ${GREEN}${flathub_packages_to_install[*]}${RESET}

Composer packages: ${GREEN}${composer_packages_to_install[*]}${RESET}

Node packages: ${GREEN}${node_global_packages_to_install[*]}${RESET}

${BOLD}Packages to remove${RESET}
${BOLD}------------------${RESET}
DNF packages: ${GREEN}${packages_to_remove[*]}${RESET}

EOL
read -rp "Press enter to install, or ctrl+c to quit"

#==============================================================================
# add default and conditional repositories
#==============================================================================
echo "${BOLD}Adding repositories...${RESET}"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# note the spaces to make sure something like 'notnode' could not trigger 'nodejs' using [*]
case " ${packages_to_install[*]} " in
*' code '*)
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    ;;&
*' gh '*)
    dnf -y config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    ;;&
*' winehq-stable '*)
    dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/33/winehq.repo
    ;;
esac

#==============================================================================
# install packages
#==============================================================================
echo "${BOLD}Removing unwanted programs...${RESET}"
dnf -y remove "${packages_to_remove[@]}"

echo "${BOLD}Updating Fedora...${RESET}"
dnf -y --refresh upgrade

echo "${BOLD}Installing packages...${RESET}"
dnf -y install "${packages_to_install[@]}"

echo "${BOLD}Installing flathub packages...${RESET}"
flatpak install -y flathub "${flathub_packages_to_install[@]}"
flatpak uninstall -y --unused

#==============================================================================
# install extras conditionally
#==============================================================================
if [[ $webdev =~ ^[Yy]$ ]]; then
    curl -fsSL https://deno.land/x/install/install.sh | sh
fi

case " ${packages_to_install[*]} " in
*' composer '*)
    echo "${BOLD}Installing global composer packages...${RESET}"
    /usr/bin/su - "$SUDO_USER" -c "composer global require ${composer_packages_to_install[*]}"
    ;;&

*' nodejs '*)
    echo "${BOLD}Installing global NodeJS packages...${RESET}"
    npm install -g "${node_global_packages_to_install[@]}"
    ;;
esac

cat <<EOL
=============================================================================
Congratulations, everything is installed!

pip3 install --user ranger-fm youtube-dl trash-cli tldr

Now use the setup script...
=============================================================================
EOL
