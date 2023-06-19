#!/bin/bash

# Neovim
mkdir -p "$XDG_CONFIG_HOME/nvim"
mkdir -p "$XDG_CONFIG_HOME/nvim/undo"
ln -sf "$DOTFILES/nvim/init.lua" "$XDG_CONFIG_HOME/nvim"
ln -sf "$DOTFILES/nvim/lua" "$XDG_CONFIG_HOME/nvim"
ln -sf "$DOTFILES/nvim/plugin" "$XDG_CONFIG_HOME/nvim"
ln -sf "$DOTFILES/nvim/after" "$XDG_CONFIG_HOME/nvim"

# Zsh
mkdir -p "$XDG_CONFIG_HOME/zsh"
ln -sf "$DOTFILES/zsh/.zshenv" "$HOME"
ln -sf "$DOTFILES/zsh/.zshrc" "$XDG_CONFIG_HOME/zsh"
ln -sf "$DOTFILES/zsh/aliases" "$XDG_CONFIG_HOME/zsh/aliases"

# Zsh Autocomplete
rm -rf "$XDG_CONFIG_HOME/zsh/external"
ln -sf "$DOTFILES/zsh/external" "$XDG_CONFIG_HOME/zsh"

# Fonts
mkdir -p "$XDG_DATA_HOME"
cp -rf "$DOTFILES/fonts" "$XDG_DATA_HOME"

# Ranger
mkdir -p "$XDG_CONFIG_HOME/ranger"
ln -sf "$DOTFILES/ranger/rc.conf" "$XDG_CONFIG_HOME/ranger"

# Alacritty
mkdir -p "$XDG_CONFIG_HOME/alacritty"
ln -sf "$DOTFILES/alacritty/alacritty.yml" "$XDG_CONFIG_HOME/alacritty"

# Helix
mkdir -p "$XDG_CONFIG_HOME/helix"
ln -sf "$DOTFILES/helix/config.toml" "$XDG_CONFIG_HOME/helix"
ln -sf "$DOTFILES/helix/themes" "$XDG_CONFIG_HOME/helix"

# Binary/Scripts
mkdir -p "$HOME/bin"
ln -sf "$DOTFILES/bin/"* "$HOME/bin"

# Wezterm
mkdir -p "$XDG_CONFIG_HOME/wezterm"
ln -sf "$DOTFILES/wezterm/wezterm.lua" "$XDG_CONFIG_HOME/wezterm"
