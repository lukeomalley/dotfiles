#!/bin/bash

# Neovim
mkdir -p "$XDG_CONFIG_HOME/nvim"
mkdir -p "$XDG_CONFIG_HOME/nvim/undo"
ln -sf "$DOTFILES/nvim/init.vim" "$XDG_CONFIG_HOME/nvim"
ln -sf "$DOTFILES/nvim/lua" "$XDG_CONFIG_HOME/nvim"
ln -sf "$DOTFILES/nvim/plugin" "$XDG_CONFIG_HOME/nvim"
ln -sf "$DOTFILES/nvim/after" "$XDG_CONFIG_HOME/nvim"

# X
rm -rf "$XDG_CONFIG_HOME/X11"
ln -s "$DOTFILES/X11" "$XDG_CONFIG_HOME"

# i3
rm -rf "$XDG_CONFIG_HOME/i3"
ln -s "$DOTFILES/i3" "$XDG_CONFIG_HOME"

# Zsh
mkdir -p "$XDG_CONFIG_HOME/zsh"
ln -sf "$DOTFILES/zsh/.zshenv" "$XDG_CONFIG_HOME/zsh"
ln -sf "$DOTFILES/zsh/.zshrc" "$XDG_CONFIG_HOME/zsh"
ln -sf "$DOTFILES/zsh/aliases" "$XDG_CONFIG_HOME/zsh/aliases"

# Zsh Autocomplete
rm -rf "$XDG_CONFIG_HOME/zsh/external"
ln -sf "$DOTFILES/zsh/external" "$XDG_CONFIG_HOME/zsh"

# Fonts
mkdir -p "$XDG_DATA_HOME"
cp -rf "$DOTFILES/fonts" "$XDG_DATA_HOME"

# Dunst Notifications
mkdir -p "$XDG_CONFIG_HOME/dunst"
ln -sf "$DOTFILES/dunst/dunstrc" "$XDG_CONFIG_HOME/dunst/dunstrc"

# Tmux
mkdir -p "$XDG_CONFIG_HOME/tmux"
ln -sf "$DOTFILES/tmux/tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"

# Devilspie
mkdir -p "$HOME/.devilspie"
ln -sf "$DOTFILES/devilspie/opacity.ds" "$HOME/.devilspie/opacity.ds"

[ ! -d "$XDG_CONFIG_HOME/tmux/plugins" ] \
&& git clone https://github.com/tmux-plugins/tpm \
"$XDG_CONFIG_HOME/tmux/plugins/tpm"
