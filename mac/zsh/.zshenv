# For Dotfiles
export XDG_CONFIG_HOME="$HOME/.config"

# Personal Binaries/Scripts
export PATH="$PATH:$HOME/bin"

# For Specific Data
export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"

# For Cache Files
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"

export DOTFILES="$HOME/dotfiles/mac"

# Maximum events for internal history
export HISTSIZE=10000

# Maximum events in history file
export SAVEHIST=10000

export EDITOR="nvim"
export VISUAL="nvim"

# Fzf config
export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Go config
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export GO111MODULE=on

# Z config
export _Z_DATA="$XDG_DATA_HOME/.z"
