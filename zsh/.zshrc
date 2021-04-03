# Aliases
source "$XDG_CONFIG_HOME/zsh/aliases"

setopt AUTO_PARAM_SLASH
unsetopt CASE_GLOB

autoload -Uz compinit; compinit

# Autocomplete hidden files
_comp_options+=(globdots)
source ~/dotfiles/zsh/external/completion.zsh
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

# Syntax Highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# bd
source ~/dotfiles/zsh/external/bd.zsh

# Scripts
source $DOTFILES/zsh/scripts.sh

# fzf
if [ $(command -v "fzf") ]; then
  source /usr/share/fzf/completion.zsh
  source /usr/share/fzf/key-bindings.zsh
fi

# Auto startx on login
if [ "$(tty)" = "/dev/tty1" ];
then
  pgrep i3 || exec startx "$XDG_CONFIG_HOME/X11/.xinitrc"
fi

# Z
. /usr/share/z/z.sh

# Clear the terminal
bindkey -r '^l'
bindkey -r '^g'
bindkey -s '^g' 'clear\n'
