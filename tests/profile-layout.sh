#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
mock_dir=""
if ! command -v stow >/dev/null 2>&1; then
  mock_dir="$(mktemp -d)"
  trap 'rm -rf "$mock_dir"' EXIT
  printf '%s\n' '#!/usr/bin/env bash' '[[ " $* " == *" --no-folding "* ]] || exit 64' > "$mock_dir/stow"
  chmod +x "$mock_dir/stow"
  PATH="$mock_dir:$PATH"
fi
for required in stow/common stow/darwin stow/omarchy packages/Brewfile packages/omarchy.txt system/omarchy/etc/keyd/default.conf; do
  [[ -e "$repo_root/$required" ]] || { echo "missing: $required" >&2; fail=1; }
done
[[ ! -d "$repo_root/dotfiles" ]] || { echo "legacy dotfiles directory remains" >&2; fail=1; }
for profile in darwin omarchy; do
  "$repo_root/scripts/stow-profile" --profile "$profile" --target "$(mktemp -d)" --dry-run >/dev/null
done
if rg -n '/Users/luke|/opt/homebrew|Library/Group Containers|\bpbcopy\b|\bpbpaste\b' "$repo_root/stow/common" --glob '!*.md' --glob '!zsh/.config/zsh/platform/*'; then
  echo "platform-specific value in common profile" >&2; fail=1
fi
exit "$fail"
