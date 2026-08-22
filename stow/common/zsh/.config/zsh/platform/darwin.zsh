[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)
[[ -d "${HOMEBREW_PREFIX:-}/opt/libpq/bin" ]] && export PATH="$HOMEBREW_PREFIX/opt/libpq/bin:$PATH"
[[ -r "${HOMEBREW_PREFIX:-}/opt/fzf/shell/completion.zsh" && $- == *i* ]] && source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
[[ -r "${HOMEBREW_PREFIX:-}/opt/fzf/shell/key-bindings.zsh" ]] && source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
[[ -r "${HOMEBREW_PREFIX:-}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r "${HOMEBREW_PREFIX:-}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
dotfiles-copy() { pbcopy; }
dotfiles-paste() { pbpaste; }
