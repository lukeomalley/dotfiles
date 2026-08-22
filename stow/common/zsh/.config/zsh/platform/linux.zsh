for plugin in /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do [[ -r "$plugin" ]] && source "$plugin"; done
[[ -r /usr/share/fzf/completion.zsh && $- == *i* ]] && source /usr/share/fzf/completion.zsh
[[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
dotfiles-copy() { wl-copy; }
dotfiles-paste() { wl-paste --no-newline; }
