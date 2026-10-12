# Catching up another Mac

The work Mac (`psci-mbp`) went through a big cleanup in October 2026. Follow these steps on any other Mac to match it, then delete this file once every machine is done.

## What changed

- **History was rewritten** to remove a leaked token, so `git pull` will not work. Reset to `origin/main` instead.
- **Agent skills moved** out of this repo to the private `lukeomalley/agent-skills` repo at `~/code/agent-skills`.
- **Git keys**: each machine now has its own passphrase-free key at `~/.ssh/id_ed25519` for GitHub auth and commit signing. 1Password is no longer used for git or SSH, and `GITHUB_TOKEN` is gone from the environment; `gh` uses its own login.
- **Docker Desktop replaced by OrbStack**, without admin mode, so Homebrew's `kubectl` wins.
- **Removed**: OpenCode, Ollama, lazygit, coder, the Claude and OpenCode subagents, the Atlassian and Firecrawl MCP scripts, iTerm2, ranger, rclone, and several old `~/bin` scripts.
- **Brewfile** now matches what is installed (added Cursor, Chrome, Raycast, Slack, Spotify, Swift tools, yq, graphicsmagick, ghostscript).
- **AeroSpace** uses the 0.21 rule syntax; all workspaces are on the main monitor.

## Steps

1. **Reset the repo.** Check for anything unpushed first (`git status`, `git log origin/main..`), then:
   ```bash
   cd ~/code/dotfiles
   git fetch origin && git reset --hard origin/main
   git clean -ndx   # preview untracked/ignored files inside the repo
   git clean -fdx   # remove them; stow would otherwise link them into $HOME
   ```

2. **Re-stow and delete links to removed files.**
   ```bash
   ./scripts/stow.sh
   find ~ ~/Library/Application\ Support -maxdepth 4 -type l -lname '*code/dotfiles*' ! -exec test -e {} \; -print -delete 2>/dev/null
   ```
   `~/.zprofile` and `~/.zshrc` in `$HOME` are never read (zsh uses `~/.config/zsh`); delete them if present.

3. **Homebrew.**
   ```bash
   brew bundle --file=Brewfile
   brew bundle cleanup --file=Brewfile          # review what is not in the Brewfile
   ```
   Uninstall anything on the list you don't want (`brew bundle cleanup --force` removes all of it). Expect at least: `docker-desktop` (use `brew uninstall --zap --cask docker-desktop`), `opencode`, `opencode-desktop`, `ollama`, `lazygit`, `coder`, `ranger`, `rclone`. Then remove their leftover data, e.g. `~/.config/opencode`, `~/.local/share/opencode`, `~/.config/local/share/opencode`, `~/.ollama`, `~/.docker`.

4. **OrbStack.** Open it once, then:
   ```bash
   orb config set setup.use_admin false
   sudo rm -f /usr/local/bin/{docker,docker-compose,docker-credential-*,kubectl,kubectl.docker,cagent,orb,orbctl}
   ```
   In a new terminal, `which docker kubectl` should show `~/.orbstack/bin/docker` and `/opt/homebrew/bin/kubectl`.

5. **Agent skills.** If `~/.agents/skills` is a real directory (not a symlink), move it aside first.
   ```bash
   ./scripts/agent-skills.sh
   ```

6. **Git key.** If an old `~/.ssh/id_ed25519` exists and has a passphrase or an unknown purpose, delete it so a fresh one is made. Then:
   ```bash
   ./scripts/git-keys.sh personal-mbp   # pick a name for this machine
   ```
   On machines that use Bitbucket, add `~/.ssh/id_ed25519.pub` in Bitbucket (Personal settings > SSH keys) for both auth and signing.

7. **Secrets and shell.**
   ```bash
   update-secrets
   ```
   Open a new terminal so the old `SSH_AUTH_SOCK` and `GITHUB_TOKEN` are gone.

8. **tmux.** Plugins now live in `~/.config/tmux/plugins`: `./scripts/setup-tmux.sh`.

## Verify

```bash
echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK GITHUB_TOKEN=${GITHUB_TOKEN:-unset}"
ssh -T git@github.com                     # "Hi lukeomalley!"
gh auth status                            # logged in via keyring
brew bundle check --file=Brewfile
aerospace reload-config --warnings-as-errors
cd /tmp && git init -q t && cd t && git commit -q --allow-empty -m t && git log --format='%G?' -1   # G
```

## After every machine is caught up

- Delete the old 1Password SSH keys ("GitHub", "GitHub Signing", "Bitbucket") from 1Password, GitHub and Bitbucket, plus the 2021 `mac` RSA key on GitHub.
- Delete this file.
