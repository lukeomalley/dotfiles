# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
# Shell Options
setopt nohashdirs
setopt login
# Aliases
alias -- run-help=man
alias -- taskmaster=task-master
alias -- tm=task-master
alias -- which-command=whence
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/opt/homebrew/Cellar/ripgrep/14.1.1/bin/rg'
fi
export PATH=/Users/luke/.pyenv/shims\:/opt/homebrew/opt/postgresql\@16/bin\:/Users/luke/.config/local/share/pnpm\:/Users/luke/.local/state/fnm_multishells/74657_1754933570974/bin\:/opt/homebrew/bin\:/opt/homebrew/sbin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\:/Applications/Wireshark.app/Contents/MacOS\:/opt/podman/bin\:/opt/homebrew/opt/postgresql\@16/bin\:/Users/luke/.config/local/share/pnpm\:/Users/luke/.local/state/fnm_multishells/52748_1754333805232/bin\:/Users/luke/code/vcpkg\:/Applications/Ghostty.app/Contents/MacOS\:/Users/luke/bin\:/Users/luke/go/bin\:/opt/homebrew/opt/fzf/bin\:/Users/luke/.local/bin\:/Users/luke/.local/bin
