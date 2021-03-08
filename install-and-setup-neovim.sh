#!/bin/bash

# Undo merge
# Install Neovim 0.5 and set it up in as minimal way as possible to be more like Visual Studio Code
# On first run it will give an error as the plugins are not installed yet, type :PlugInstall and then restart
# Deno LSP needs "package.json", "tsconfig.json" or ".git" in the project root directory to run
# Deno can be used for frontend by adding /// <reference lib="dom" /> to every file that needs it

# (p)npm install -g prettier vscode-json-languageserver bash-language-server typescript typescript-language-server
# curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux -o ~/.local/bin/rust-analyzer
# chmod +x ~/.local/bin/rust-analyzer

# Install Neovim 0.5 nightly
curl -LOf https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
chmod u+x ./nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim

# Install vimplug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Make directories
mkdir -p "$HOME"/.config/nvim/colors
mkdir -p "$HOME"/.config/nvim/plugged

# Download nvcode color scheme for treesitter
curl https://raw.githubusercontent.com/ChristianChiarulli/nvcode-color-schemes.vim/master/colors/nvcode.vim -o "$HOME/.config/nvim/colors/nvcode.vim"
