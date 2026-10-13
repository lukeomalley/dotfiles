# Loaded by every zsh (login, interactive, scripts, tmux panes), on macOS and
# Linux. Platform-specific lines check that their target exists.

# Homebrew (macOS)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# XDG base directories: the standard locations, set explicitly because many
# macOS tools only use them when these are set.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Personal scripts
export PATH="$PATH:$HOME/bin"

export DOTFILES="$HOME/code/dotfiles"

# Codex state/config directory. Keep explicit so terminal-launched Codex uses
# the same home as GUI-launched Codex.
export CODEX_HOME="$HOME/.codex"

export VISUAL="nvim"
export EDITOR="nvim"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Rust. Homebrew's rustup is keg-only, so its cargo/rustc proxies are not on
# PATH by default; ~/.cargo/bin holds binaries from `cargo install`.
[[ -d /opt/homebrew/opt/rustup/bin ]] && export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="$PATH:$HOME/.cargo/bin"

# Bun
export PATH="$PATH:$HOME/.bun/bin"

# OrbStack (docker, docker compose, orb). Appended so Homebrew's kubectl wins
# over the one OrbStack bundles.
if [[ -d "$HOME/.orbstack/bin" ]]; then
    export PATH="$PATH:$HOME/.orbstack/bin"
    fpath+=("$HOME/.orbstack/shell/completions/zsh")
fi

# PostgreSQL client. Homebrew's libpq is keg-only.
[[ -d /opt/homebrew/opt/libpq/bin ]] && export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PSQLRC="$XDG_CONFIG_HOME/psql/psqlrc"
export PSQL_HISTORY="$XDG_STATE_HOME/psql/history"
[[ -d "$XDG_STATE_HOME/psql" ]] || mkdir -p "$XDG_STATE_HOME/psql"

# macOS clipboard commands on Linux (Wayland). Defined here, not in .zshrc, so
# non-interactive shells such as fzf key bindings get them too.
if (( ! $+commands[pbcopy] && $+commands[wl-copy] )); then
    pbcopy() { wl-copy "$@"; }
    pbpaste() { wl-paste --no-newline "$@"; }
fi
