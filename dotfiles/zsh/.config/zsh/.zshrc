# Aliases
source "$XDG_CONFIG_HOME/zsh/aliases"

# Secrets
source "$XDG_CONFIG_HOME/zsh/secrets.zsh"

setopt AUTO_PARAM_SLASH
unsetopt CASE_GLOB

autoload -Uz compinit
# Save compdump to cache directory instead of config directory
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"


# Autocomplete hidden files
_comp_options+=(globdots)


# Pretify Prompt
# autoload -Uz prompt_purification_setup
# prompt_purification_setup

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

# Vim Cursor
# autoload -Uz cursor_mode && cursor_mode

# Edit commands in nvim
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# fzf
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

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

# Auto-completion
[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2>/dev/null

# Key bindings (Ctrl+T file search, Alt+C cd, Ctrl+R overridden by Atuin)
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# Clear the terminal
bindkey -r '^l'
bindkey -r '^g'
bindkey -s '^g' 'clear\n'

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Zsh Autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Zsh Syntax Highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Zoxide (better cd)
eval "$(zoxide init zsh)"

# Atuin (better shell history)
eval "$(atuin init zsh)"

# fnm
eval "$(fnm env)"

# History
setopt share_history
setopt inc_append_history
# Store history in data directory instead of config directory to avoid git pollution
[[ ! -d "$XDG_DATA_HOME/zsh" ]] && mkdir -p "$XDG_DATA_HOME/zsh"
export HISTFILE="$XDG_DATA_HOME/zsh/history"
export HISTSIZE=50000
export HISTFILESIZE=$HISTSIZE
export SAVEHIST=$HISTSIZE

# direnv
export DIRENV_LOG_FORMAT=""
eval "$(direnv hook zsh)"

# pnpm
export PNPM_HOME="/Users/luke/.config/local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Created by `pipx` on 2024-06-30 17:37:54
export PATH="$PATH:/Users/luke/.local/bin"

# gnupg
export GPG_TTY=$(tty)

# Homebrew completions
# https://docs.brew.sh/Shell-Completion
# if type brew &>/dev/null
# then
#   HOMEBREW_PREFIX="$(brew --prefix)"
#   if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
#   then
#     source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
#   else
#     for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
#     do
#       [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
#     done
#   fi
# fi
#
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/luke/.docker/completions $fpath)
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
# End of Docker CLI completions
