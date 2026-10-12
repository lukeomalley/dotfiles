#!/bin/bash
set -euo pipefail

# Give this machine its own SSH key for GitHub auth and commit signing. The key
# has no passphrase, so git and agents never wait on a prompt. Safe to re-run.
#
# Usage: git-keys.sh [machine-name]   e.g. git-keys.sh psci-mbp
#
# Bitbucket is optional: on machines that need it, add ~/.ssh/id_ed25519.pub
# in Bitbucket under Personal settings > SSH keys (for auth and signing).

KEY="$HOME/.ssh/id_ed25519"

# gh must use its own login, not a token from the environment.
unset GH_TOKEN GITHUB_TOKEN

if [[ ! -f "$KEY" ]]; then
    name="${1:-}"
    [[ -n "$name" ]] || read -rp "Name for this machine's key (e.g. psci-mbp): " name
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    ssh-keygen -q -t ed25519 -N "" -C "$name" -f "$KEY"
fi
name="$(cut -d' ' -f3 "$KEY.pub")"
pub="$(cut -d' ' -f1,2 "$KEY.pub")"

# Log in once in the browser, with the scopes needed to register keys.
scopes="admin:public_key,admin:ssh_signing_key"
if ! gh auth status >/dev/null 2>&1; then
    gh auth login --hostname github.com --web --git-protocol https --scopes "$scopes"
elif ! gh api user/ssh_signing_keys >/dev/null 2>&1; then
    gh auth refresh --hostname github.com --scopes "$scopes"
fi

gh api --paginate user/keys --jq '.[].key' | grep -qxF "$pub" \
    || gh ssh-key add "$KEY.pub" --type authentication --title "$name"
gh api --paginate user/ssh_signing_keys --jq '.[].key' | grep -qxF "$pub" \
    || gh ssh-key add "$KEY.pub" --type signing --title "$name"

# Trust GitHub's published host keys so a first SSH clone never stops at a
# host key prompt.
ssh-keygen -F github.com >/dev/null \
    || gh api meta --jq '.ssh_keys[] | "github.com " + .' >> "$HOME/.ssh/known_hosts"

# Trust every signing key on the GitHub account (one per machine) when
# verifying commits locally, for any of my email addresses.
rm -f "$HOME/.ssh/allowed_signers"
gh api --paginate user/ssh_signing_keys --jq '.[].key' | sed 's/^/* /' > "$HOME/.ssh/allowed_signers"

echo "Git key '$name' is set up for GitHub auth and signing."
