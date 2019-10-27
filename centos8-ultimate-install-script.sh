#!/bin/bash

# select SOFTWARE / Software Selection / Base Environment > Workstation
# when you create user tick 'make user administrator'
# FINAL tested 27/10/19, still unreleased syncthing wine

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

#==============================================================================
# common packages to install/remove *arrays can be left empty, but don't delete
#==============================================================================
packages_to_remove=(
    gnome-boxes
    firefox
    evolution
    rhythmbox
    totem
    pidgin
    cheese)

packages_to_install=(
    # brave-browser
    borgbackup
    ntfs-3g
    gnome-tweaks
    youtube-dl
    keepassxc
    lshw
    mpv
    deadbeef
    libva-intel-driver
    ffmpeg
    fuse-exfat)

flathub_packages_to_install=(
    org.kde.krita
    org.kde.okular
    org.gnome.Shotwell
    org.gnome.Boxes
    fr.handbrake.ghb
    org.bunkus.mkvtoolnix-gui
    com.transmissionbt.Transmission
    org.zealdocs.Zeal)

fedora_flatpak_packages_to_install=(
    org.mozilla.Firefox)

#==============================================================================
# Ask for user input
#==============================================================================
clear
read -p "Are you going to use this machine for web development? (y/n) " -n 1
echo
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    #==========================================================================
    # packages for software development option
    #==========================================================================
    developer_packages=(
        nodejs
        php
        code)

    node_global_packages_to_install=(
        pnpm)

    code_extensions=(
        ban.spellright
        bierner.markdown-preview-github-styles
        bmewburn.vscode-intelephense-client
        deerawan.vscode-dash
        esbenp.prettier-vscode
        foxundermoon.shell-format
        msjsdiag.debugger-for-chrome
        ritwickdey.LiveServer
        timonwong.shellcheck
        WallabyJs.quokka-vscode)

    packages_to_install+=("${developer_packages[@]}")

elif [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Invalid selection" && exit 1
fi

#==============================================================================
# display user settings
#==============================================================================
cat <<EOL
${BOLD}Packages to install${RESET}
${BOLD}-------------------${RESET}

DNF packages: ${GREEN}${packages_to_install[*]}${RESET}

Fedora Flatpak packages: ${GREEN}${fedora_flatpak_packages_to_install[*]}${RESET}
Flathub packages: ${GREEN}${flathub_packages_to_install[*]}${RESET}

NodeJS global packages: ${GREEN}${node_global_packages_to_install[*]}${RESET}

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
dnf -y config-manager --enable PowerTools
dnf -y install epel-release
dnf -y install --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

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

echo "${BOLD}Installing flatpak packages...${RESET}"
flatpak install -y flathub "${flathub_packages_to_install[@]}"
flatpak install -y fedora "${fedora_flatpak_packages_to_install[@]}"
flatpak uninstall -y --unused

echo "${BOLD}Downloading and installing binaries...${RESET}"
curl -Of https://shellcheck.storage.googleapis.com/shellcheck-v0.7.0.linux.x86_64.tar.xz
echo "84e06bee3c8b8c25f46906350fb32708f4b661636c04e55bd19cdd1071265112d84906055372149678d37f09a1667019488c62a0561b81fe6a6b45ad4fae4ac0 ./shellcheck-v0.7.0.linux.x86_64.tar.xz" |
    sha512sum --check
tar -C /usr/local/bin/ -xf shellcheck-v0.7.0.linux.x86_64.tar.xz --no-anchored 'shellcheck' --strip=1

curl -LOf https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-linux.tar.gz
echo "e99eb0471dda59e64c1451b4d110738e3802ad430a406b2b28234f0328a29d59d9942cf53635e2575abe792bd4aedf854339fbd16f9cb8bb0e642bcc42c6ede7 ./pandoc-2.7.3-linux.tar.gz" |
    sha512sum --check
tar -C /usr/local/bin/ -xf pandoc-2.7.3-linux.tar.gz --no-anchored 'pandoc' --strip=2

curl -LOf https://github.com/syncthing/syncthing/releases/download/v1.3.0/syncthing-linux-amd64-v1.3.0.tar.gz
echo "f70981750dffe089420f7f20ccf9df2f21e90acb168d5f8d691e01b4b5a1f8e67c9711bf8d35ee175fd2ee17048f6f17a03e7aec99143c86a069faebfa8c6073  ./syncthing-linux-amd64-v1.3.0.tar.gz" |
    sha512sum --check
tar -C /usr/local/bin/ -xf syncthing-linux-amd64-v1.3.0.tar.gz --no-anchored 'syncthing' --strip=1 --exclude='etc/*'

case " ${packages_to_install[*]} " in
*' nodejs '*)
    echo "${BOLD}Installing global NodeJS packages...${RESET}"
    npm install -g "${node_global_packages_to_install[@]}"
    ;;&
*' code '*)
    echo "${BOLD}Installing Visual Studio Code extensions...${RESET}"
    for extension in "${code_extensions[@]}"; do
        /usr/bin/su - "$SUDO_USER" -c "code --install-extension $extension"
    done
    ;;
esac

cat <<EOL
  =================================================================
  Congratulations, everything is installed!

  Now use the setup script...
  =================================================================
EOL
