#!/usr/bin/env bash
set -uo pipefail

# Check that this machine matches the dotfiles: links, shell, tools, Git keys
# and per-OS apps. Prints PASS/FAIL/SKIP per check and exits non-zero if any
# check fails. Changes nothing, so it is safe to run before and after setup.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/os.sh"
host="$(uname -n)"
host="${host%%.*}"
failures=0

pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s: %s\n' "$1" "$2"; failures=$((failures + 1)); }
skip() { printf 'SKIP  %s: %s\n' "$1" "$2"; }

# What an interactive zsh reports, as key=value lines (filled in below).
shell_report=""
shell_value() { sed -n "s/^$1=//p" <<<"$shell_report"; }
shell_path() { local path; path="$(shell_value "$1")"; echo "${path:-$1 not found}"; }

echo "Machine: $OS, host $host"

# Links: every file in the layers is linked into $HOME.
if [[ -d "$ROOT/stow/hosts/$host" ]]; then
    pass "host layer stow/hosts/$host"
elif [[ "$OS" == omarchy ]]; then
    fail "host layer" "stow/hosts/$host is missing; add this machine's monitors and devices"
else
    skip "host layer" "none for $host (only needed for machine-specific hardware)"
fi

linked=0
unlinked=()
for layer in common "$OS" "hosts/$host"; do
    [[ -d "$ROOT/stow/$layer" ]] || continue
    for package in "$ROOT/stow/$layer"/*/; do
        while IFS= read -r file; do
            target="$HOME/${file#"$package"}"
            if [[ -L "$target" && "$target" -ef "$file" ]]; then
                linked=$((linked + 1))
            else
                unlinked+=("${target#"$HOME"/}")
            fi
        done < <(find "$package" \( -type f -o -type l \))
    done
done
if ((${#unlinked[@]} == 0)); then
    pass "links ($linked files)"
else
    fail "links" "${#unlinked[@]} not linked (run scripts/stow.sh): ${unlinked[*]:0:5}"
fi

broken="$(find "$HOME" "$HOME/Library/Application Support" -maxdepth 4 -type l \
    -lname "*code/dotfiles*" ! -exec test -e {} \; -print 2>/dev/null)"
[[ -z "$broken" ]] && pass "no broken links" || fail "broken links" "$(tr '\n' ' ' <<<"$broken")"

# Shell: run a real interactive zsh and read what it sees.
if [[ "$OS" == darwin ]]; then
    login_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
else
    login_shell="$(getent passwd "$USER" | cut -d: -f7)"
fi
[[ "$login_shell" == */zsh ]] && pass "login shell zsh" || fail "login shell" "$login_shell"

if command -v zsh >/dev/null; then
    zsh_errors_file="$(mktemp)"
    shell_report="$(zsh -i -c '
        print -r -- "data=$XDG_DATA_HOME"
        print -r -- "hist=$HISTFILE"
        print -r -- "token=${GITHUB_TOKEN:+set}${GH_TOKEN:+set}"
        print -r -- "node=${commands[node]-}"
        print -r -- "docker=${commands[docker]-}"
        print -r -- "kubectl=${commands[kubectl]-}"
        for tool in git gh stow atuin fzf zoxide direnv starship nvim tmux fnm delta op; do
            (( $+commands[$tool] )) || print -r -- "missing=$tool"
        done' </dev/null 2>"$zsh_errors_file")"
    # Without a terminal, zsh always warns that it cannot enable zle.
    startup_errors="$(grep -v "can't change option: zle" "$zsh_errors_file")"
    rm -f "$zsh_errors_file"

    [[ -z "$startup_errors" ]] && pass "zsh starts cleanly" \
        || fail "zsh startup" "$(head -3 <<<"$startup_errors" | tr '\n' ' ')"
    [[ "$(shell_value data)" == "$HOME/.local/share" && "$(shell_value hist)" == "$HOME/.local/state/zsh/history" ]] \
        && pass "XDG directories and history" \
        || fail "XDG directories" "XDG_DATA_HOME=$(shell_value data) HISTFILE=$(shell_value hist)"
    [[ -z "$(shell_value token)" ]] && pass "no GitHub token in the environment" \
        || fail "GitHub token" "GITHUB_TOKEN or GH_TOKEN is set; gh would use it instead of its login"
    [[ "$(shell_value node)" == *fnm* ]] && pass "node from fnm" \
        || fail "node" "$(shell_path node) is not from fnm (run fnm install --lts)"
    missing="$(shell_value missing | tr '\n' ' ')"
    [[ -z "$missing" ]] && pass "core tools" || fail "core tools" "missing $missing"
else
    fail "zsh" "not installed"
fi

# Git and keys
[[ -f "$HOME/.ssh/id_ed25519" ]] && pass "SSH key" \
    || fail "SSH key" "~/.ssh/id_ed25519 missing (run scripts/git-keys.sh)"

# ssh -T always exits 1 on GitHub and Bitbucket, so read the greeting instead.
ssh_greeting() { ssh -n -T -o BatchMode=yes -o ConnectTimeout=10 "$@" 2>&1; }

[[ "$(ssh_greeting git@github.com)" == *"successfully authenticated"* ]] \
    && pass "GitHub SSH" || fail "GitHub SSH" "ssh -T git@github.com failed (run scripts/git-keys.sh)"

env -u GH_TOKEN -u GITHUB_TOKEN gh auth status --hostname github.com >/dev/null 2>&1 \
    && pass "gh login" || fail "gh login" "not logged in (run scripts/git-keys.sh)"

printf 'protocol=https\nhost=github.com\n\n' \
    | GIT_TERMINAL_PROMPT=0 git credential fill 2>/dev/null | grep -q '^password=' \
    && pass "GitHub HTTPS credentials" || fail "GitHub HTTPS credentials" "gh credential helper returned nothing"

test_repo="$(mktemp -d)"
git -C "$test_repo" init -q && git -C "$test_repo" commit -q --allow-empty -m check 2>/dev/null
[[ "$(git -C "$test_repo" log -1 --format=%G? 2>/dev/null)" == G ]] && pass "signed commits" \
    || fail "signed commits" "test commit is not signed and verified"
rm -rf "$test_repo"

if [[ "$(ssh_greeting -o StrictHostKeyChecking=yes git@bitbucket.org)" == *authenticated* ]]; then
    pass "Bitbucket SSH"
else
    skip "Bitbucket SSH" "not set up (personal machines only)"
fi

# Secrets, agent skills, tmux
[[ -s "$HOME/.config/zsh/secrets.zsh" ]] && pass "secrets.zsh" \
    || fail "secrets.zsh" "missing (run update-secrets)"
[[ -d "$HOME/code/agent-skills/.git" && -d "$HOME/.agents/skills" ]] && pass "agent skills" \
    || fail "agent skills" "not cloned or linked (run scripts/agent-skills.sh)"
[[ -d "$HOME/.config/tmux/plugins/tpm" ]] && pass "tmux plugins" \
    || fail "tmux plugins" "TPM missing (run scripts/setup-tmux.sh)"

# Per-OS apps
ghostty="$(command -v ghostty || echo /Applications/Ghostty.app/Contents/MacOS/ghostty)"
[[ -x "$ghostty" ]] && "$ghostty" +validate-config >/dev/null 2>&1 && pass "Ghostty config" \
    || fail "Ghostty config" "ghostty missing or +validate-config failed"

if [[ "$OS" == darwin ]]; then
    brew bundle check --no-upgrade --file="$ROOT/packages/Brewfile" >/dev/null 2>&1 \
        && pass "Brewfile installed" || fail "Brewfile" "run brew bundle check --verbose --file=packages/Brewfile"
    if pgrep -xq AeroSpace; then
        aerospace reload-config --warnings-as-errors >/dev/null 2>&1 && pass "AeroSpace config" \
            || fail "AeroSpace config" "aerospace reload-config --warnings-as-errors failed"
    else
        fail "AeroSpace" "not running (open -a AeroSpace)"
    fi
    [[ "$(shell_value docker)" == "$HOME/.orbstack/bin/docker" ]] && pass "docker from OrbStack" \
        || fail "docker" "$(shell_path docker) is not OrbStack's (open OrbStack once)"
    [[ "$(shell_value kubectl)" == /opt/homebrew/bin/kubectl ]] && pass "kubectl from Homebrew" \
        || fail "kubectl" "$(shell_path kubectl) shadows Homebrew's (orb config set setup.use_admin false)"
else
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        hypr_errors="$(hyprctl configerrors 2>&1 | tr -d '[:space:]')"
        [[ -z "$hypr_errors" ]] && pass "Hyprland config" || fail "Hyprland config" "see hyprctl configerrors"
    else
        skip "Hyprland config" "not in a Hyprland session"
    fi
    systemctl is-active --quiet keyd && pass "keyd" || fail "keyd" "not running (run scripts/omarchy/settings.sh)"
    systemctl --user is-active --quiet voxtype && pass "voxtype" \
        || fail "voxtype" "not running (run scripts/omarchy/settings.sh)"
fi

echo
if ((failures)); then
    echo "$failures check(s) failed."
    exit 1
fi
echo "All checks passed."
