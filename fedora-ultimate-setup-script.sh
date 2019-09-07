#!/bin/bash

#==============================================================================
#
#         FILE: fedora-ultimate-setup-script.sh
#        USAGE: fedora-ultimate-setup-script.sh
#
#  DESCRIPTION: Post-installation setup script for Fedora 29 Workstation
#      WEBSITE: https://www.elsewebdevelopment.com/
#
# REQUIREMENTS: Fresh copy of Fedora 29/30 installed on your computer
#               https://dl.fedoraproject.org/pub/fedora/linux/releases/30/Workstation/x86_64/iso/
#       AUTHOR: David Else
#      COMPANY: Else Web Development
#      VERSION: 3
#==============================================================================

#==============================================================================
# script settings
#==============================================================================
set -euo pipefail

GREEN=$(tput setaf 2)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [ "$(id -u)" != 0 ]; then
    echo "You're not root! Use sudo ./fedora-ultimate-setup-script.sh"
    exit 1
fi

# start of user settings
# note: if you delete packages you might need to remove their settings later

#==============================================================================
# git settings
#==============================================================================
git_email='example@example.com'
git_user_name='example-name'

#==============================================================================
# gnome settings
#==============================================================================
idle_delay=1200
title_bar_buttons_on="true"
clock_show_date="true"
capslock_delete="true"
night_light="true"

#==============================================================================
# packages to remove
#==============================================================================
packages_to_remove=(gnome-photos gnome-documents rhythmbox totem cheese)

#==============================================================================
# packages to install
#==============================================================================
fedora=(shotwell sendmail java-1.8.0-openjdk jack-audio-connection-kit
    gnome-shell-extension-auto-move-windows.noarch dolphin-emu
    gnome-shell-extension-pomodoro syncthing nodejs php php-json
    phpmyadmin php-mysqlnd php-opcache composer mariadb-server mediainfo
    mame borgbackup gnome-tweaks chromium ShellCheck zeal youtube-dl
    keepassxc transmission-gtk lshw fuse-exfat mpv mkvtoolnix-gui tldr)

rpmfusion=(libva-intel-driver chromium-libs-media-freeworld ffmpeg)

WineHQ=(winehq-stable)

vscode=(code)

flathub_packages_to_install=(org.kde.krita org.kde.okular fr.handbrake.ghb net.sf.fuse_emulator)

composer_packages_to_install=(squizlabs/php_codesniffer wp-coding-standards/wpcs wp-cli/wp-cli-bundle)

code_extensions=(ban.spellright
    bierner.markdown-preview-github-styles
    bmewburn.vscode-intelephense-client
    deerawan.vscode-dash
    esbenp.prettier-vscode
    foxundermoon.shell-format
    msjsdiag.debugger-for-chrome
    ritwickdey.LiveServer
    timonwong.shellcheck
    WallabyJs.quokka-vscode)

dnf_packages_to_install+=("${fedora[@]}" "${rpmfusion[@]}" "${WineHQ[@]}" "${vscode[@]}")

# end of user settings

#==============================================================================
# display packages to be installed and ask user for computer's name
#==============================================================================
clear
echo -e "${BOLD}dnf packages to install: ${RESET}${GREEN}${dnf_packages_to_install[*]}${RESET}\n"
echo -e "${BOLD}flathub packages to install: ${RESET}${GREEN}${flathub_packages_to_install[*]}${RESET}\n"
echo -e "${BOLD}composer packages to install: ${RESET}${GREEN}${composer_packages_to_install[*]}${RESET}\n"
echo -e "${BOLD}visual studio code extensions to install: ${RESET}${GREEN}${code_extensions[*]}${RESET}\n"

read -rp "What is this computer's name? [$HOSTNAME] " hostname
if [[ ! -z "$hostname" ]]; then
    hostnamectl set-hostname "$hostname"
fi

#==============================================================================
# add repositories
#==============================================================================
echo "${BOLD}Adding repositories...${RESET}"
dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/30/winehq.repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

#==============================================================================
# update/install/remove packages
#==============================================================================
echo "${BOLD}Removing unwanted programs...${RESET}"
dnf -y remove "${packages_to_remove[@]}"

echo "${BOLD}Updating Fedora, enabling module streams, and installing packages...${RESET}"
dnf -y --refresh upgrade
dnf module enable nodejs:12
dnf -y install "${fedora[@]}"

echo "${BOLD}Installing flathub packages...${RESET}"
flatpak install -y flathub "${flathub_packages_to_install[@]}"

echo "${BOLD}Installing composer packages...${RESET}"
/usr/bin/su - "$USERNAME" -c "composer global require ${composer_packages_to_install[*]}"

echo "${BOLD}Installing Visual Studio Code extensions...${RESET}"
for extension in "${code_extensions[@]}"; do
    /usr/bin/su - "$USERNAME" -c "code --install-extension $extension"
done

#==============================================================================
# setup gnome desktop gsettings
#==============================================================================
echo "${BOLD}Setting up gnome desktop gsettings...${RESET}"

gsettings set org.gnome.desktop.session \
    idle-delay $idle_delay
gsettings set org.gnome.shell.extensions.auto-move-windows \
    application-list "['org.gnome.Nautilus.desktop:2', 'org.gnome.Terminal.desktop:3', 'code.desktop:1', 'firefox.desktop:1']"
gsettings set org.gnome.shell enabled-extensions \
    "['pomodoro@arun.codito.in', 'auto-move-windows@gnome-shell-extensions.gcampax.github.com']"

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

#==============================================================================
# setup pulse audio
#
# *pacmd list-sinks | grep sample and see bit-depth available for interface
# *pulseaudio --dump-re-sample-methods and see re-sampling available
#
# *MAKE SURE your interface can handle s32le 32bit rather than the default 16bit
#==============================================================================
echo "${BOLD}Setting up Pulse Audio...${RESET}"
sed -i "s/; default-sample-format = s16le/default-sample-format = s32le/g" /etc/pulse/daemon.conf
sed -i "s/; resample-method = speex-float-1/resample-method = speex-float-10/g" /etc/pulse/daemon.conf
sed -i "s/; avoid-resampling = false/avoid-resampling = true/g" /etc/pulse/daemon.conf

#==============================================================================
# setup jack audio for real time use
#==============================================================================
usermod -a -G jackuser "$USERNAME" # Add current user to jackuser group
tee /etc/security/limits.d/95-jack.conf <<EOL
# Default limits for users of jack-audio-connection-kit

@jackuser - rtprio 98
@jackuser - memlock unlimited

@pulse-rt - rtprio 20
@pulse-rt - nice -20
EOL

#==============================================================================
# setup MPV
#==============================================================================
mkdir -p "/home/$USERNAME/.config/mpv"
cat >"/home/$USERNAME/.config/mpv/mpv.conf" <<EOL
profile=gpu-hq
hwdec=auto
fullscreen=yes
EOL

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

#==================================================================================================
# setup PHP dev environment
#
# use 'phpcbf --standard=WordPress file.php' to autofix and format Wordpress code
# use 'composer global show / outdated / update' to manage these packages
#==================================================================================================
echo "${BOLD}Setting up PHP dev environment...${RESET}"

"/home/$USERNAME/.config/composer/vendor/bin/phpcs" --config-set installed_paths ~/.config/composer/vendor/wp-coding-standards/wpcs
"/home/$USERNAME/.config/composer/vendor/bin/phpcs" --config-set default_standard PSR12
"/home/$USERNAME/.config/composer/vendor/bin/phpcs" --config-show

# add composer global executables to the PATH
cat >>"/home/$USERNAME/.bash_profile" <<EOL
PATH=$PATH:$HOME/.config/composer/vendor/bin
EOL

# change PHP settings to mirror the production server
upload_max_filesize=128M # namesco default setting
post_max_size=128M       # namesco default setting
max_execution_time=60    # namesco default setting

for key in upload_max_filesize post_max_size max_execution_time; do
    sed -i "s/^\($key\).*/\1 = $(eval echo \${$key})/" /etc/php.ini
done

#==============================================================================
# setup visual studio code * 'EOL' stops parameter expansion in here-doc
#==============================================================================
cat >"/home/$USERNAME/.config/Code/User/settings.json" <<'EOL'
// Place your settings in this file to overwrite the default settings
{
  // VS Code 1.36 general settings
  "editor.renderWhitespace": "all",
  "editor.dragAndDrop": false,
  "editor.formatOnSave": true,
  "editor.minimap.enabled": false,
  "editor.detectIndentation": false,
  "editor.tabSize": 2,
  "workbench.activityBar.visible": false,
  "workbench.tree.renderIndentGuides": "none",
  "workbench.list.keyboardNavigation": "filter",
  "window.menuBarVisibility": "toggle",
  "zenMode.restore": true,
  "zenMode.centerLayout": false,
  "zenMode.fullScreen": false,
  "git.autofetch": true,
  "git.enableSmartCommit": true,
  "git.decorations.enabled": false,
  "npm.enableScriptExplorer": true,
  "explorer.decorations.colors": false,
  "search.followSymlinks": false,
  // Privacy
  "telemetry.enableTelemetry": false,
  "extensions.showRecommendationsOnlyOnDemand": true,
  // Language settings
  "javascript.preferences.quoteStyle": "single",
  "typescript.updateImportsOnFileMove.enabled": "always",
  "files.exclude": {
    "**/*.js": { "when": "$(basename).ts" },
    "**/*.js.map": true
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  // Shell Format extension
  "shellformat.flag": "-i 4",
  // Live Server extension
  "liveServer.settings.donotShowInfoMsg": true,
  "liveServer.settings.ChromeDebuggingAttachment": true,
  "liveServer.settings.AdvanceCustomBrowserCmdLine": "/usr/bin/chromium-browser --remote-debugging-port=9222",
  // Prettier extension
  "prettier.singleQuote": true,
  "prettier.trailingComma": "all",
  "prettier.proseWrap": "always",
  // Spellright extension
  "spellright.language": ["English (British)"],
  "spellright.documentTypes": ["markdown", "latex", "plaintext"]
  // "typescript.referencesCodeLens.enabled": true,
  // "javascript.referencesCodeLens.enabled": true,
}
EOL

#==============================================================================================
# make a few little changes to finish up
#==============================================================================================
echo "Xft.lcdfilter: lcdlight" >>"/home/$USERNAME/.Xresources"
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p
touch /home/$USERNAME/Templates/empty-file # so you can create new documents from nautilus
cat >>"/home/$USERNAME/.bashrc" <<EOL
alias ls="ls -ltha --color --group-directories-first" # l=long listing format, t=sort by modification time (newest first), h=human readable sizes, a=print hidden files
alias tree="tree -Catr --noreport --dirsfirst --filelimit 100" # -C=colorization on, a=print hidden files, t=sort by modification time, r=reversed sort by time (newest first)
EOL

cat <<EOL
  ===================================================
  REBOOT NOW!!!! (or things may not work as expected)
  shutdown -r
  ===================================================
EOL
