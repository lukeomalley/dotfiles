# Homebrew (prepends /opt/homebrew/bin to PATH). Loaded here so every shell
# type (login, non-login, interactive, tmux panes) can find brew-installed tools.
eval "$(/opt/homebrew/bin/brew shellenv)"

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

# Disable macOS shell sessions (prevents .zsh_sessions directory)
export SHELL_SESSION_HISTORY=0

# Dotfile Dir
export DOTFILES="$HOME/code/dotfiles"

# 1Password SSH agent: serves SSH keys (stored in 1Password) for both auth and
# git SSH commit signing. git signing runs `ssh-keygen -Y sign`, which uses
# SSH_AUTH_SOCK rather than ssh_config's IdentityAgent, so it must be exported
# here for every shell type.
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Editor export EDITOR="nvim"
export VISUAL="nvim"
export EDITOR="nvim"

# Note: FZF config moved to .zshrc where it uses fd instead of rg

# Kube Config
export KUBECONFIG="$HOME/.kube/config"

# Go config
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export GO111MODULE=on

# Bun
export PATH="$PATH:$HOME/.bun/bin"

# Z config
export _Z_DATA="$XDG_DATA_HOME/.z"

# vckpg
export VCPKG_ROOT=/Users/luke/code/vcpkg
export PATH=$VCPKG_ROOT:$PATH

# PostgreSQL client (libpq is keg-only, so its bin is not symlinked by brew)
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PSQLRC="$XDG_CONFIG_HOME/psql/psqlrc"
export PSQL_HISTORY="$XDG_DATA_HOME/psql/history"
[[ -d "$XDG_DATA_HOME/psql" ]] || mkdir -p "$XDG_DATA_HOME/psql"

