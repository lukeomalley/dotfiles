# For Dotfiles
export XDG_CONFIG_HOME="$HOME/.config"

# Personal Binaries/Scripts
export PATH="$PATH:$HOME/bin"

# For Specific Data
export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"

# For Cache Files
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"

# Z Config File Dir
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Dotfile Dir
export DOTFILES="$HOME/dotfiles"

# Editor export EDITOR="nvim"
export VISUAL="nvim"

# Fzf config
export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Git Config
export GIT_CONFIG="$HOME/.config/.gitconfig"

# Kube Config
export KUBECONFIG="$HOME/.config/.kube/config"

# Go config
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export GO111MODULE=on

# Z config
export _Z_DATA="$XDG_DATA_HOME/.z"

