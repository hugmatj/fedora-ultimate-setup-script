#!/bin/bash

#==============================================================================
#
#         FILE: centos-ultimate-install-script.sh
#        USAGE: sudo centos-ultimate-install-script.sh
#
#  DESCRIPTION: Post-installation install script for Centos 8.x Workstation
#      WEBSITE: https://github.com/David-Else/fedora-ultimate-setup-script
#
# REQUIREMENTS: Fresh copy of Centos 8.x installed on your computer
#       AUTHOR: David Else
#      COMPANY: https://www.elsewebdevelopment.com/
#      VERSION: 5.0
#
#      - select SOFTWARE / Software Selection / Base Environment > Workstation
#      - make user admin
#
# TODO if ban.spellright ln -s /usr/share/myspell ~/.config/Code/Dictionaries
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

if [[ $(rpm -E %centos) -lt 8 ]]; then
    echo >&2 "You must install at least ${GREEN}Centos 8${RESET} to use this script" && exit 1
fi

# >>>>>> start of user settings <<<<<<

#==============================================================================
# common packages to install/remove *arrays can be left empty, but don't delete
#==============================================================================
packages_to_remove=(
    rhythmbox
    totem
    cheese
    firefox
    gnome-boxes
    evolution
    pidgin
)

packages_to_install=(
    borgbackup
    ffmpeg
    youtube-dl
    keepassxc
    transmission-gtk
    lshw
    fuse-exfat
    mpv
    gnome-tweaks
    mediainfo
    syncthing
    libva-intel-driver
    deadbeef
    chromium
    ntfs-3g
    ImageMagick)

flathub_packages_to_install=(
    org.kde.krita
    org.kde.okular
    fr.handbrake.ghb
    org.mozilla.firefox
    org.gnome.Shotwell
    org.gnome.Boxes
    org.bunkus.mkvtoolnix-gui
    org.zealdocs.Zeal)

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
        code-1.45.1-1589445456.el7
        php
        podman)

    code_extensions=(
        asvetliakov.vscode-neovim
        ban.spellright
        bierner.markdown-preview-github-styles
        bierner.markdown-shiki
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        foxundermoon.shell-format
        jebbs.plantuml
        msjsdiag.debugger-for-chrome
        nicoespeon.abracadabra
        ritwickdey.LiveServer
        timonwong.shellcheck
        WallabyJs.quokka-vscode)

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

Visual Studio Code extensions: ${GREEN}${code_extensions[*]}${RESET}

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
dnf -y config-manager --enable PowerTools
dnf -y install epel-release
dnf -y install --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm

# note the spaces to make sure something like 'notnode' could not trigger 'nodejs' using [*]
case " ${packages_to_install[*]} " in
*' code '*)
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    ;;&
*' brave-browser '*)
    dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
    rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    ;;
esac

#==============================================================================
# install packages
#==============================================================================
echo "${BOLD}Removing unwanted programs...${RESET}"
dnf -y remove "${packages_to_remove[@]}"

echo "${BOLD}Updating Centos8...${RESET}"
dnf -y --refresh upgrade

echo "${BOLD}Installing packages...${RESET}"
dnf -y install "${packages_to_install[@]}"

echo "${BOLD}Installing flathub packages...${RESET}"
flatpak install -y flathub "${flathub_packages_to_install[@]}"
flatpak uninstall -y --unused

#==============================================================================
# install binaries
#==============================================================================
echo "${BOLD}Downloading and installing binaries...${RESET}"

curl -Of https://shellcheck.storage.googleapis.com/shellcheck-v0.7.0.linux.x86_64.tar.xz
echo "84e06bee3c8b8c25f46906350fb32708f4b661636c04e55bd19cdd1071265112d84906055372149678d37f09a1667019488c62a0561b81fe6a6b45ad4fae4ac0 ./shellcheck-v0.7.0.linux.x86_64.tar.xz" |
    sha512sum --check
tar -C /usr/local/bin/ -xf shellcheck-v0.7.0.linux.x86_64.tar.xz --no-anchored 'shellcheck' --strip=1

curl -LOf https://github.com/jgm/pandoc/releases/download/2.9.2.1/pandoc-2.9.2.1-linux-amd64.tar.gz
echo "37f791e766b4e91824814241709243436ba25447bf908626c1d588ba098161bb6c821a6aa4abd2096ae70a8a4207dc862d090abce2f0d64cf582421d6f0f96c6 ./pandoc-2.9.2.1-linux-amd64.tar.gz" |
    sha512sum --check
tar -C /usr/local/bin/ -xf pandoc-2.9.2.1-linux-amd64.tar.gz --no-anchored 'pandoc' --strip=2

#==============================================================================
# install extras conditionally
#==============================================================================
if [[ $webdev =~ ^[Yy]$ ]]; then
    curl -fsSL https://deno.land/x/install/install.sh | sh
    dnf -y module install nodejs:12/default
fi

case " ${packages_to_install[*]} " in
*' code '*)
    echo "${BOLD}Installing Visual Studio Code extensions...${RESET}"
    for extension in "${code_extensions[@]}"; do
        /usr/bin/su - "$SUDO_USER" -c "code --install-extension $extension"
    done
    ;;
esac

cat <<EOL
=============================================================================
Congratulations, everything is installed!

- Run 'sudo centos8-update-fonts.sh' to update abattis-cantarell-fonts

JavaScript developers, don't forget to install PNPM globally

Now use the setup script...
=============================================================================
EOL
