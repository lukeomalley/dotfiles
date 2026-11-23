# Ghostty quick file browser: skip shell setup and launch lf immediately.
if [[ "${GHOSTTY_QUICK_TERMINAL:-}" == "1" ]]; then
  lf
  exit
fi

# Essentials skipped from /etc/zshrc on macOS (NO_GLOBAL_RCS in .zshenv).
setopt COMBINING_CHARS
[[ $OSTYPE == darwin* ]] && disable log
[[ ${TERM_PROGRAM:-} == Apple_Terminal && -r /etc/zshrc_Apple_Terminal ]] && source /etc/zshrc_Apple_Terminal

# Aliases & lf helper
source "$XDG_CONFIG_HOME/zsh/aliases"
[[ -r "$XDG_CONFIG_HOME/lf/lf.zsh" ]] && source "$XDG_CONFIG_HOME/lf/lf.zsh"

# Secrets (generated from secrets.tpl via `update-secrets`; absent until then)
if [[ -r "$XDG_CONFIG_HOME/zsh/secrets.zsh" ]]; then
  source "$XDG_CONFIG_HOME/zsh/secrets.zsh"
elif [[ $- == *i* ]]; then
  print -P "%F{yellow}secrets.zsh not found — run \`update-secrets\` to generate it from secrets.tpl%f"
fi

# Shell options & history
setopt AUTO_PARAM_SLASH AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT SHARE_HISTORY INC_APPEND_HISTORY
unsetopt CASE_GLOB

[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=50000
export SAVEHIST=$HISTSIZE

# Cache directory for compiled init scripts and zcompdump
_zsh_cache_dir="$XDG_CACHE_HOME/zsh"
[[ -d "$_zsh_cache_dir" ]] || mkdir -p "$_zsh_cache_dir"

# Resolve a CLI binary path without triggering zsh's full $PATH readdir hash
# (first access to $commands[...] scans every directory in $PATH, ~2-5ms).
_zsh_bin() {
  if [[ -x "/opt/homebrew/bin/$1" ]]; then
    REPLY="/opt/homebrew/bin/$1"
  elif [[ -x "/usr/bin/$1" ]]; then
    REPLY="/usr/bin/$1"
  elif [[ -x "/usr/local/bin/$1" ]]; then
    REPLY="/usr/local/bin/$1"
  else
    REPLY="${commands[$1]-}"
    [[ -n $REPLY ]] || return 1
  fi
}

# Source a cached, zcompiled tool init script; regenerate automatically when
# the binary or optional config file is newer than the cache.
_zsh_source_cached() {
  local cache_file="$1" bin_path="$2" extra_dep="$3" generator="$4"
  if [[ ! -s "$cache_file" || "$bin_path" -nt "$cache_file" || ( -n "$extra_dep" && -e "$extra_dep" && "$extra_dep" -nt "$cache_file" ) ]]; then
    local tmp_file="${cache_file}.tmp.$$"
    if "$generator" >| "$tmp_file" && [[ -s "$tmp_file" ]]; then
      command mv -f "$tmp_file" "$cache_file"
      zcompile "$cache_file" 2>/dev/null
    else
      command rm -f "$tmp_file"
      return 1
    fi
  elif [[ ! -f "${cache_file}.zwc" || "$cache_file" -nt "${cache_file}.zwc" ]]; then
    zcompile "$cache_file" 2>/dev/null
  fi
  source "$cache_file"
}

# Starship (synchronous -- needed before the first prompt draws)
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
_zsh_gen_starship() {
  setopt localoptions extendedglob
  local init_code prompt2
  init_code="$(command starship init zsh)" || return 1
  prompt2="$(command starship prompt --continuation)" || prompt2="∙ "
  # Bake PROMPT2 as a literal so shell startup avoids a second starship fork.
  init_code="${init_code/PROMPT2=\"\$\([^)]#\)\"/PROMPT2=${(qq)prompt2}}"
  print -r -- "$init_code"
}
if _zsh_bin starship; then
  _zsh_source_cached "$_zsh_cache_dir/starship.zsh" "$REPLY" "$STARSHIP_CONFIG" _zsh_gen_starship
  # Unset right prompt to prevent $(...) being printed on rapid Ctrl+C
  # See: https://github.com/spaceship-prompt/spaceship-prompt/issues/644
  unset RPROMPT
fi

# Vim keybinds & edit-command-line
bindkey -v
export KEYTIMEOUT=1
bindkey "^?" backward-delete-char

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Clear the terminal
bindkey -r '^l'
bindkey -r '^g'
bindkey -s '^g' 'clear\n'

# fzf config - use fd for faster searching (respects .gitignore)
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

# Ctrl+T: file search with bat preview
# Enter opens in nvim, Ctrl+/ toggle preview, Ctrl+Y copy path
export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || eza --tree --color=always {}'
  --preview-window 'right:50%:wrap'
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)+abort'
  --bind 'enter:execute(nvim {})+abort'"

# Alt+C: directory search with tree preview
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --color=always --icons {} | head -200'
  --preview-window 'right:50%'"

# Zoxide (cached; compdef is wired once compinit loads)
_zsh_gen_zoxide() { command zoxide init zsh; }
_zsh_bin zoxide && _zsh_source_cached "$_zsh_cache_dir/zoxide.zsh" "$REPLY" "" _zsh_gen_zoxide

# fnm: default Node is already on PATH from .zshenv; initialize a per-shell
# multishell lazily only when `fnm` is actually invoked.
if [[ -z ${FNM_MULTISHELL_PATH:-} ]] && _zsh_bin fnm; then
  fnm() {
    unfunction fnm
    eval "$(command fnm env)"
    command fnm "$@"
  }
fi

# direnv: inline hook skips the startup `direnv hook zsh` fork (~8ms) and guards
# `direnv export zsh` (~6.5ms/prompt) behind a pure-zsh .envrc ancestor check.
if _zsh_bin direnv; then
  export DIRENV_LOG_FORMAT=""
  _direnv_hook() {
    setopt localoptions localtraps
    if [[ ! -o interactive || $ZSH_SUBSHELL -ne 0 ]]; then
      return
    fi
    if [[ -z ${DIRENV_DIR:-} ]]; then
      local dir=$PWD
      while true; do
        [[ -e "$dir/.envrc" ]] && break
        [[ "$dir" == / ]] && return
        dir=${dir:h}
      done
    fi
    local vars
    vars="$(command direnv export zsh)"
    trap -- '' SIGINT
    eval "$vars"
    trap - SIGINT
  }
  typeset -ag precmd_functions chpwd_functions
  (( ${precmd_functions[(I)_direnv_hook]} )) || precmd_functions=(_direnv_hook $precmd_functions)
  (( ${chpwd_functions[(I)_direnv_hook]} )) || chpwd_functions=(_direnv_hook $chpwd_functions)
fi

# Interactive-only tools (completions, fzf, autosuggestions, atuin, syntax
# highlighting) load on the first ZLE event-loop tick right after prompt #1
# renders, using a zero-fork /dev/null fd watch.
_zsh_gen_fzf() { command fzf --zsh; }
_zsh_gen_atuin() { command atuin init zsh --disable-up-arrow; }

# Generate an RFC 9562 UUIDv7 in pure zsh so atuin init skips `$(atuin uuid)`.
_zsh_init_atuin_session() {
  if [[ -z ${ATUIN_SESSION:-} || ${ATUIN_SHLVL:-} != "$SHLVL" ]]; then
    zmodload zsh/datetime
    local ms=${${EPOCHREALTIME/./}[1,13]}
    printf -v ATUIN_SESSION '%012x7%03x%x%03x%03x%03x%03x%03x' \
      "$ms" \
      $(( RANDOM & 0xfff )) \
      $(( 8 | (RANDOM & 3) )) \
      $(( RANDOM & 0xfff )) \
      $(( RANDOM & 0xfff )) \
      $(( RANDOM & 0xfff )) \
      $(( RANDOM & 0xfff )) \
      $(( RANDOM & 0xfff ))
    export ATUIN_SESSION
    export ATUIN_SHLVL=$SHLVL
  fi
}

_zsh_defer_load() {
  local fd=$1
  zle -F "$fd"
  exec {fd}<&-
  unset _zsh_defer_fd

  # Completions: regenerate at most once per 24h (or when zsh config changes),
  # using zstat instead of forking `find`, and compile zcompdump to .zwc.
  local zcompdump="$_zsh_cache_dir/zcompdump"
  local needs_compinit_rebuild=0
  if [[ ! -f "$zcompdump" || "$ZDOTDIR/.zshrc" -nt "$zcompdump" || "$HOME/.zshenv" -nt "$zcompdump" ]]; then
    needs_compinit_rebuild=1
  else
    zmodload -F zsh/stat b:zstat
    local -A dump_stat
    zstat -H dump_stat "$zcompdump" 2>/dev/null
    (( EPOCHSECONDS - ${dump_stat[mtime]:-0} > 86400 )) && needs_compinit_rebuild=1
  fi

  autoload -Uz compinit
  if (( needs_compinit_rebuild )); then
    compinit -d "$zcompdump"
    zcompile "$zcompdump" 2>/dev/null
  else
    compinit -C -d "$zcompdump"
    [[ ! -f "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc" ]] && zcompile "$zcompdump" 2>/dev/null
  fi

  _comp_options+=(globdots)
  zmodload zsh/complist
  bindkey -M menuselect 'h' vi-backward-char
  bindkey -M menuselect 'j' vi-down-line-or-history
  bindkey -M menuselect 'k' vi-up-line-or-history
  bindkey -M menuselect 'l' vi-forward-char
  (( $+functions[__zoxide_z_complete] )) && compdef __zoxide_z_complete z

  # fzf completion & keybindings (Ctrl+T, Alt+C; Ctrl+R overridden by Atuin below)
  _zsh_bin fzf && _zsh_source_cached "$_zsh_cache_dir/fzf.zsh" "$REPLY" "" _zsh_gen_fzf

  # zsh-autosuggestions (manual rebind avoids re-wrapping all widgets every prompt)
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1
  local plugin_dir
  for plugin_dir in /opt/homebrew/share /usr/share/zsh/plugins; do
    if [[ -r "$plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
      source "$plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
      break
    fi
  done

  # Atuin (after fzf so Ctrl+R belongs to Atuin, after autosuggestions so it
  # prepends the atuin suggestion strategy)
  if _zsh_bin atuin; then
    _zsh_init_atuin_session
    _zsh_source_cached "$_zsh_cache_dir/atuin.zsh" "$REPLY" "$XDG_CONFIG_HOME/atuin/config.toml" _zsh_gen_atuin
  fi

  # zsh-syntax-highlighting, followed by _zsh_autosuggest_start so autosuggest
  # wraps syntax-highlighting widgets in the order zsh-autosuggestions expects.
  for plugin_dir in /opt/homebrew/share /usr/share/zsh/plugins; do
    if [[ -r "$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
      source "$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      break
    fi
  done
  (( $+functions[_zsh_autosuggest_start] )) && _zsh_autosuggest_start
  [[ -n $BUFFER ]] && (( $+functions[_zsh_highlight] )) && _zsh_highlight

  unset _zsh_cache_dir
  unfunction _zsh_bin _zsh_defer_arm _zsh_defer_load _zsh_source_cached \
    _zsh_gen_starship _zsh_gen_zoxide _zsh_gen_fzf _zsh_gen_atuin \
    _zsh_init_atuin_session 2>/dev/null
}

_zsh_defer_arm() {
  precmd_functions=(${precmd_functions:#_zsh_defer_arm})
  [[ -o zle ]] || return
  exec {_zsh_defer_fd}</dev/null
  zle -F "$_zsh_defer_fd" _zsh_defer_load
}
precmd_functions+=(_zsh_defer_arm)
