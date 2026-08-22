[[ -r "$XDG_CONFIG_HOME/zsh/aliases" ]] && source "$XDG_CONFIG_HOME/zsh/aliases"
[[ -r "$XDG_CONFIG_HOME/lf/lf.zsh" ]] && source "$XDG_CONFIG_HOME/lf/lf.zsh"
if [[ "${GHOSTTY_QUICK_TERMINAL:-}" == 1 ]]; then lf; exit; fi
if [[ -r "$XDG_CONFIG_HOME/zsh/secrets.zsh" ]]; then source "$XDG_CONFIG_HOME/zsh/secrets.zsh"; elif [[ $- == *i* ]]; then print -P '%F{yellow}secrets.zsh not found — run `update-secrets`%f'; fi
setopt AUTO_PARAM_SLASH AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
unsetopt CASE_GLOB
mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_DATA_HOME/zsh"
autoload -Uz compinit
if [[ -f "$XDG_CACHE_HOME/zsh/zcompdump" && -z "$(find "$XDG_CACHE_HOME/zsh/zcompdump" -mtime +1 2>/dev/null)" ]]; then compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump"; else compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"; fi
_comp_options+=(globdots)
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
command -v starship >/dev/null && eval "$(starship init zsh)"
unset RPROMPT
bindkey -v
export KEYTIMEOUT=1
zmodload zsh/complist
bindkey '^?' backward-delete-char
bindkey -M menuselect h vi-backward-char
bindkey -M menuselect j vi-down-line-or-history
bindkey -M menuselect k vi-up-line-or-history
bindkey -M menuselect l vi-forward-char
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
bindkey -r '^l'; bindkey -r '^g'; bindkey -s '^g' 'clear\n'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || eza --tree --color=always {}' --preview-window 'right:50%:wrap' --bind 'ctrl-/:toggle-preview' --bind 'ctrl-y:execute-silent(echo -n {} | dotfiles-copy)+abort' --bind 'enter:execute(nvim {})+abort'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} | head -200' --preview-window 'right:50%'"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v atuin >/dev/null && eval "$(atuin init zsh)"
command -v fnm >/dev/null && eval "$(fnm env)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=''
setopt share_history inc_append_history
export HISTFILE="$XDG_DATA_HOME/zsh/history" HISTSIZE=50000 SAVEHIST=50000
export GPG_TTY="$(tty 2>/dev/null || true)"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
case "$(uname -s)" in
  Darwin) [[ -r "$ZDOTDIR/platform/darwin.zsh" ]] && source "$ZDOTDIR/platform/darwin.zsh" ;;
  Linux) [[ -r "$ZDOTDIR/platform/linux.zsh" ]] && source "$ZDOTDIR/platform/linux.zsh" ;;
esac
