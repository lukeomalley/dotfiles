# When ZDOTDIR is already set in the environment before zsh starts (e.g. a
# child shell spawned from a process that inherited ZDOTDIR from a parent
# shell), zsh reads $ZDOTDIR/.zshenv instead of ~/.zshenv. Without this file,
# none of the env in ~/.zshenv would load (PATH, XDG_*, etc.).
#
# Source ~/.zshenv so the canonical env is always applied regardless of how
# zsh was invoked.
[[ -r "$HOME/.zshenv" ]] && source "$HOME/.zshenv"
