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
idle_delay=1200
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
        sudo ln -s /usr/share/myspell "$HOME/.config/Code/Dictionaries"
        cat >>"$HOME/.bashrc" <<EOL
alias code="GTK_IM_MODULE=ibus code"
EOL
        cat >"$HOME/.config/Code/User/settings.json" <<'EOL'
// Place your settings in this file to overwrite the default settings
{
  // VS Code 1.45.1
  // General settings
  "editor.fontSize": 15,
  "markdown.preview.fontSize": 15,
  "terminal.integrated.fontSize": 15,
  "editor.renderWhitespace": "boundary",
  "editor.dragAndDrop": false,
  "editor.formatOnSave": true,
  "editor.minimap.enabled": false,
  "editor.detectIndentation": false,
  "editor.tabSize": 2,
  "workbench.activityBar.visible": false,
  "workbench.tree.renderIndentGuides": "none",
  "workbench.list.keyboardNavigation": "filter",
  "workbench.editor.limit.enabled": true,
  "workbench.editor.limit.value": 5,
  "window.menuBarVisibility": "hidden",
  "window.enableMenuBarMnemonics": false,
  "window.titleBarStyle": "custom",
  "files.restoreUndoStack": false,
  "files.defaultLanguage": "${activeEditorLanguage}",
  "git.autofetch": true,
  "git.enableSmartCommit": true,
  "git.decorations.enabled": false,
  "problems.showCurrentInStatus": true,
  "zenMode.restore": true,
  "terminal.integrated.env.linux": {
    "PS1": "$ "
  },
  "explorer.decorations.colors": false,
  "explorer.openEditors.visible": 0,
  "outline.problems.enabled": false,
  "search.followSymlinks": false,
  "breadcrumbs.enabled": false,
  "diffEditor.renderSideBySide": true,
  "diffEditor.ignoreTrimWhitespace": false,
  "eslint.packageManager": "pnpm",
  "omnisharp.enableRoslynAnalyzers": true,
  "omnisharp.enableEditorConfigSupport": true,
  // Privacy
  "telemetry.enableTelemetry": false,
  "extensions.showRecommendationsOnlyOnDemand": true,
  // Language settings
  "typescript.updateImportsOnFileMove.enabled": "always",
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[markdown]": {
    "editor.wordWrap": "wordWrapColumn",
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  // Shell extensions
  "shellformat.flag": "-i 4",
  "shellcheck.enableQuickFix": true,
  // Live Server extension
  "liveServer.settings.donotShowInfoMsg": true,
  "liveServer.settings.ChromeDebuggingAttachment": true,
  "liveServer.settings.AdvanceCustomBrowserCmdLine": "/usr/bin/chromium-browser --remote-debugging-port=9222",
  // Spellright extension
  "spellright.language": ["en_GB"],
  "spellright.notificationClass": "warning",
  "spellright.documentTypes": ["markdown", "plaintext"],
  // To get color emoji on the terminal on Linux
  "editor.fontFamily": "'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback', 'Noto Color Emoji'",
  "markdown.preview.fontFamily": "-apple-system, BlinkMacSystemFont, 'Segoe WPC', 'Segoe UI', 'Ubuntu', 'Droid Sans', sans-serif, 'Noto Color Emoji'",
  // Neo Vim
  "editor.scrollBeyondLastLine": false,
  "vscode-neovim.useCtrlKeysForInsertMode": false,
  "vscode-neovim.useCtrlKeysForNormalMode": true,
  "vscode-neovim.neovimInitPath": "/home/david/.config/nvim/init.vim",
  "vscode-neovim.neovimPath": "/home/david/bin/nvim",
  // Prettier
  "prettier.proseWrap": "never",
  "prettier.packageManager": "pnpm",
  // PlantUML
  "plantuml.server": "http://localhost:8080/"
  // "typescript.referencesCodeLens.enabled": true,
  // "javascript.referencesCodeLens.enabled": true,
}
EOL

        cat >"$HOME/.config/Code/User/keybindings.json" <<'EOL'
[
  // jk for vscode-neovim escape in insert mode
  {
    "command": "vscode-neovim.compositeEscape1",
    "key": "j",
    "when": "neovim.mode == insert",
    "args": "j"
  },
  {
    "command": "vscode-neovim.compositeEscape2",
    "key": "k",
    "when": "neovim.mode == insert",
    "args": "k"
  },
  // delete
  {
    "key": "capslock",
    "command": "deleteLeft",
    "when": "textInputFocus && !editorReadonly"
  },
  // navigate position back/forward in time
  {
    "key": "alt+left",
    "command": "workbench.action.navigateBack"
  },
  {
    "key": "alt+right",
    "command": "workbench.action.navigateForward"
  },
  // use alt h/j/k/l keys where possible
  //
  // navigate lists and explorer
  {
    "key": "alt+k",
    "command": "list.focusUp",
    "when": "listFocus && !inputFocus"
  },
  {
    "key": "alt+j",
    "command": "list.focusDown",
    "when": "listFocus && !inputFocus"
  },
  {
    "key": "alt+l",
    "command": "list.expand",
    "when": "listFocus && !inputFocus"
  },
  {
    "key": "alt+h",
    "command": "list.collapse",
    "when": "listFocus && !inputFocus"
  },
  // smart select
  {
    "key": "shift+alt+l",
    "command": "editor.action.smartSelect.expand",
    "when": "editorTextFocus"
  },
  {
    "key": "shift+alt+h",
    "command": "editor.action.smartSelect.shrink",
    "when": "editorTextFocus"
  },
  // select suggestion
  {
    "key": "alt+k",
    "command": "selectPrevSuggestion",
    "when": "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"
  },
  {
    "key": "alt+j",
    "command": "selectNextSuggestion",
    "when": "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"
  }
]
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
# improve ls and tree commands output
#==============================================================================================
cat >>"$HOME/.bashrc" <<'EOL'
alias ls="ls -ltha --color --group-directories-first" # l=long listing format, t=sort by modification time (newest first), h=human readable sizes, a=print hidden files
alias tree="tree -Catr --noreport --dirsfirst --filelimit 100" # -C=colorization on, a=print hidden files, t=sort by modification time, r=reversed sort by time (newest first)
EOL

#==============================================================================================
# misc
#==============================================================================================
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
touch "$HOME/Templates/empty-file" # so you can create new documents from nautilus

cat <<EOL
=================================================================
Use Gnome Software to install 'Hide Top Bar' 'Auto Move Windows'
Add the following Firefox extensions with:

firefox https://addons.mozilla.org/en-GB/firefox/addon/https-everywhere/ \
https://addons.mozilla.org/en-GB/firefox/addon/privacy-badger17/ \
https://addons.mozilla.org/en-GB/firefox/addon/ublock-origin/ \
https://addons.mozilla.org/en-US/firefox/addon/df-youtube/ \
https://addons.mozilla.org/en-US/firefox/addon/tabliss/

Change settings/details/default applications
Change tweaks/fonts/ to Subpixel (for LCD screens)
Select network > wired > connect automatically

For VS Code in Centos 8/8.1:

go to terminal type 'ibus-setup'
go to Emoji tab, press the '...' next to Emoji choice to get 'select keyboard shortcut for switching' window
use the delete button to delete the shortcut and leave nothing there, press OK
Close

Please reboot (or things may not work as expected)
=================================================================
EOL
