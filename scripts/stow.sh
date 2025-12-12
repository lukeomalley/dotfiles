#!/bin/bash
set -e

# Navigate to dotfiles directory
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT/dotfiles"

# Stow all directories in dotfiles/ to $HOME
# --no-folding: Create symlinks for files only, not directories
#               This prevents runtime files from polluting the dotfiles repo
#               (e.g., Claude writes debug/history/cache files to ~/.claude)
for d in */; do
    [ -d "$d" ] || continue
    echo "Stowing ${d%/}..."
    stow -R --adopt --no-folding -t "$HOME" "${d%/}"
done

# Reset any changes that stow --adopt might have made to the repo
cd "$PROJECT_ROOT"
if git rev-parse --git-dir > /dev/null 2>&1; then
    git checkout -- dotfiles/ 2>/dev/null || true
fi

