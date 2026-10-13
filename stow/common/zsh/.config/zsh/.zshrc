# Aliases
source "$XDG_CONFIG_HOME/zsh/aliases"

# lf
[[ -r "$XDG_CONFIG_HOME/lf/lf.zsh" ]] && source "$XDG_CONFIG_HOME/lf/lf.zsh"

if [[ "${GHOSTTY_QUICK_TERMINAL:-}" == "1" ]]; then
  lf
  exit
fi

# Secrets (generated from secrets.tpl via `update-secrets`; absent until then)
if [[ -r "$XDG_CONFIG_HOME/zsh/secrets.zsh" ]]; then
  source "$XDG_CONFIG_HOME/zsh/secrets.zsh"
elif [[ $- == *i* ]]; then
  print -P "%F{yellow}secrets.zsh not found — run \`update-secrets\` to generate it from secrets.tpl%f"
fi

setopt AUTO_PARAM_SLASH
unsetopt CASE_GLOB

# Ensure zsh cache directory exists for zcompdump
[[ ! -d "$XDG_CACHE_HOME/zsh" ]] && mkdir -p "$XDG_CACHE_HOME/zsh"

# Optimized compinit - only regenerate zcompdump once per day for faster startup
# Using -C skips the security check which saves ~200ms
autoload -Uz compinit
if [[ -f "$XDG_CACHE_HOME/zsh/zcompdump" ]]; then
  # Regenerate if zcompdump is older than 24 hours
  if [[ -n $(find "$XDG_CACHE_HOME/zsh/zcompdump" -mtime +1 2>/dev/null) ]]; then
    compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
  else
    compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump"
  fi
else
  compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
fi

# Autocomplete hidden files
_comp_options+=(globdots)

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"
# Unset right prompt to prevent $(…) being printed on rapid Ctrl+C
# See: https://github.com/spaceship-prompt/spaceship-prompt/issues/644
unset RPROMPT

# Push the current directory visited on to the stack
setopt AUTO_PUSHD

# Do not store duplicate directories in the stack
setopt PUSHD_IGNORE_DUPS

# Do not print the directory stack after using pushd or popd
setopt PUSHD_SILENT

# Vim Keybinds
bindkey -v
export KEYTIMEOUT=1
zmodload zsh/complist
bindkey "^?" backward-delete-char

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# Edit commands in nvim
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

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

# Completion and key bindings (Ctrl+T file search, Alt+C cd, Ctrl+R overridden by Atuin)
source <(fzf --zsh)

# Clear the terminal
bindkey -r '^l'
bindkey -r '^g'
bindkey -s '^g' 'clear\n'

# Zsh plugins, from Homebrew on macOS or the system package on Arch
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  for dir in /opt/homebrew/share /usr/share/zsh/plugins; do
    [[ -r "$dir/$plugin/$plugin.zsh" ]] && { source "$dir/$plugin/$plugin.zsh"; break; }
  done
done

# Zoxide (better cd)
eval "$(zoxide init zsh)"

# Atuin (better shell history) on Ctrl-R; Up arrow stays plain shell history
eval "$(atuin init zsh --disable-up-arrow)"

# fnm
eval "$(fnm env)"

# History
setopt share_history
setopt inc_append_history
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=50000
export SAVEHIST=$HISTSIZE

# direnv
export DIRENV_LOG_FORMAT=""
eval "$(direnv hook zsh)"

# pnpm
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export PATH="$PNPM_HOME:$PATH"

# User-installed CLIs (twg, cursor-agent, amp)
export PATH="$PATH:$HOME/.local/bin"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
