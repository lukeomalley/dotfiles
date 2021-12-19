# Aliases
source "$XDG_CONFIG_HOME/zsh/aliases"

setopt AUTO_PARAM_SLASH
unsetopt CASE_GLOB

autoload -Uz compinit; compinit

# Autocomplete hidden files
_comp_options+=(globdots)
source $DOTFILES/zsh/external/completion.zsh
fpath=($ZDOTDIR/external $fpath)

# Pretify Prompt
autoload -Uz prompt_purification_setup; prompt_purification_setup

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
if [ $(command -v "fzf") ]; then
  source /usr/share/fzf/completion.zsh
  source /usr/share/fzf/key-bindings.zsh
fi

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
