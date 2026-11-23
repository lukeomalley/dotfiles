# Loaded by every zsh (login, interactive, scripts, tmux panes), on macOS and
# Linux. Platform-specific lines check that their target exists.

# On macOS, skip /etc/zprofile (path_helper, ~4ms, also pushes Homebrew behind
# /usr/bin) and /etc/zshrc (locale fork + terminfo loop, ~10ms). Essential
# macOS defaults (LANG, system paths, COMBINING_CHARS, disable log) are handled
# directly here and in .zshrc.
if [[ $OSTYPE == darwin* ]]; then
    setopt NO_GLOBAL_RCS
    [[ -z ${LANG:-} ]] && export LANG=C.UTF-8
fi

# XDG base directories: the standard locations, set explicitly because many
# macOS tools only use them when these are set.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export DOTFILES="$HOME/code/dotfiles"

# Codex state/config directory. Keep explicit so terminal-launched Codex uses
# the same home as GUI-launched Codex.
export CODEX_HOME="$HOME/.codex"

export VISUAL="nvim"
export EDITOR="nvim"

# Go, pnpm, fnm, PostgreSQL
export GOPATH="$HOME/go"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export FNM_DIR="$XDG_DATA_HOME/fnm"
export PSQLRC="$XDG_CONFIG_HOME/psql/psqlrc"
export PSQL_HISTORY="$XDG_STATE_HOME/psql/history"
[[ -d "$XDG_STATE_HOME/psql" ]] || mkdir -p "$XDG_STATE_HOME/psql"

# Build PATH and fpath in one pass, then deduplicate once (avoiding repeated
# O(N^2) deduplication and environ re-export on each path+= mutation).
typeset -a _pre_path=("$PNPM_HOME")
typeset -a _post_path=()

# Preserve an active `fnm use` multishell; otherwise expose the default fnm
# Node install directly without spawning `fnm env` (~11ms) on every shell start.
if [[ -n ${FNM_MULTISHELL_PATH:-} && -d "$FNM_MULTISHELL_PATH/bin" ]]; then
    _pre_path+=("$FNM_MULTISHELL_PATH/bin")
elif [[ -d "$FNM_DIR/aliases/default/bin" ]]; then
    _pre_path+=("$FNM_DIR/aliases/default/bin")
fi

# Homebrew (macOS) -- static env avoids spawning `brew shellenv` (~20ms) on
# every shell invocation. Keg-only libpq and rustup come before /opt/homebrew/bin.
if [[ -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    [[ ":${INFOPATH:-}:" != *":/opt/homebrew/share/info:"* ]] && export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
    [[ -d /opt/homebrew/opt/libpq/bin ]] && _pre_path+=(/opt/homebrew/opt/libpq/bin)
    [[ -d /opt/homebrew/opt/rustup/bin ]] && _pre_path+=(/opt/homebrew/opt/rustup/bin)
    _pre_path+=(/opt/homebrew/bin /opt/homebrew/sbin)
fi

# macOS system paths (replaces /usr/libexec/path_helper from /etc/zprofile,
# placed after Homebrew so Homebrew tools are never shadowed).
if [[ $OSTYPE == darwin* ]]; then
    _post_path+=(/usr/local/bin /System/Cryptexes/App/usr/bin /usr/bin /bin /usr/sbin /sbin /Library/Apple/usr/bin)
fi

# Personal scripts, language toolchains, OrbStack, user CLIs.
# OrbStack is appended after Homebrew so Homebrew's kubectl wins over OrbStack's.
_post_path+=(
    "$HOME/bin"
    "$GOPATH/bin"
    "$HOME/.cargo/bin"
    "$HOME/.bun/bin"
)
if [[ -d "$HOME/.orbstack/bin" ]]; then
    _post_path+=("$HOME/.orbstack/bin")
    fpath+=("$HOME/.orbstack/shell/completions/zsh")
fi
_post_path+=("$HOME/.local/bin")

# Autoload bun completion on demand via compinit instead of sourcing 37KB at startup.
[[ -s "$HOME/.bun/_bun" ]] && fpath+=("$HOME/.bun")

path=($_pre_path $path $_post_path)
typeset -U path fpath
unset _pre_path _post_path
export PATH

# macOS clipboard commands on Linux (Wayland). Defined here, not in .zshrc, so
# non-interactive shells such as fzf key bindings get them too. Check paths
# directly to avoid forcing zsh to readdir-hash all of $PATH via $commands.
if [[ $OSTYPE != darwin* && -x /usr/bin/wl-copy && ! -x /usr/bin/pbcopy ]]; then
    pbcopy() { wl-copy "$@"; }
    pbpaste() { wl-paste --no-newline "$@"; }
fi
