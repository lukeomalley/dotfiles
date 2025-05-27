# Aliases
source "$XDG_CONFIG_HOME/zsh/aliases"

setopt AUTO_PARAM_SLASH
unsetopt CASE_GLOB

autoload -Uz compinit
compinit -i

# Autocomplete hidden files
_comp_options+=(globdots)
source $DOTFILES/zsh/external/completion.zsh
fpath=($ZDOTDIR/external $fpath)

# Pretify Prompt
autoload -Uz prompt_purification_setup
prompt_purification_setup

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
autoload -Uz cursor_mode && cursor_mode

# Edit commands in nvim
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# bd
source $DOTFILES/zsh/external/bd.zsh

# Scripts
source $DOTFILES/zsh/scripts.sh

# fzf
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# Auto-completion
[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2>/dev/null

# Key bindings
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

# Z
. $(brew --prefix)/etc/profile.d/z.sh

# fnm
eval "$(fnm env)"

# History
setopt share_history
setopt inc_append_history
export HISTFILE="$ZDOTDIR/.zhistory"
export HISTSIZE=50000
export HISTFILESIZE=$HISTSIZE
export SAVEHIST=$HISTSIZE

# git
export GPG_TTY=$(tty)

# direnv
export DIRENV_LOG_FORMAT=""
eval "$(direnv hook zsh)"

# pnpm
export PNPM_HOME="/Users/luke/.config/local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Created by `pipx` on 2024-06-30 17:37:54
export PATH="$PATH:/Users/luke/.local/bin"

# Pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


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
