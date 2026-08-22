export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export DOTFILES="${DOTFILES:-$HOME/code/dotfiles}"
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export VISUAL=nvim EDITOR=nvim
export KUBECONFIG="$HOME/.kube/config"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$HOME/.bun/bin:$PATH"
export GO111MODULE=on
export _Z_DATA="$XDG_DATA_HOME/.z"
export PSQLRC="$XDG_CONFIG_HOME/psql/psqlrc"
export PSQL_HISTORY="$XDG_DATA_HOME/psql/history"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export PATH="$PNPM_HOME:$PATH"
mkdir -p "$XDG_DATA_HOME/psql"
case "$(uname -s)" in
  Darwin) [[ -r "$ZDOTDIR/platform/darwin-env.zsh" ]] && source "$ZDOTDIR/platform/darwin-env.zsh" ;;
  Linux) [[ -r "$ZDOTDIR/platform/linux-env.zsh" ]] && source "$ZDOTDIR/platform/linux-env.zsh" ;;
esac
