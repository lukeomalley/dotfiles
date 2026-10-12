#!/bin/bash
set -e

# Agent skills live in a private repo cloned to ~/code/agent-skills. Its
# bin/sync links the skills into ~/.agents and ~/.claude/skills.
REPO="lukeomalley/agent-skills"
DEST="$HOME/code/agent-skills"

if [ -d "$DEST/.git" ]; then
    git -C "$DEST" pull --ff-only || echo "Warning: could not update $DEST"
elif [ -e "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
    echo "Error: $DEST exists and is not a git repo; move it aside and re-run." >&2
    exit 1
else
    gh repo clone "$REPO" "$DEST"
fi

"$DEST/bin/sync"
