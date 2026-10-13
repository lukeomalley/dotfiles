# Catching up other machines

The work Mac (`psci-mbp`) went through a big cleanup in October 2026 and is the source of truth. Follow **Other Macs** on any other Mac, or **Omarchy** on the Linux laptop. Delete this file once every machine is done.

## What changed

- **History was rewritten** to remove a leaked token, so `git pull` will not work. Reset to `origin/main` instead.
- **Cross-platform layout.** Packages moved from `dotfiles/` to `stow/common` (shared), `stow/darwin` (AeroSpace, Cursor) and `stow/omarchy`. `scripts/stow.sh` links common, then the OS layer, then `stow/hosts/<hostname>`. The Brewfile is now `packages/Brewfile`; Mac setup scripts are in `scripts/darwin/`. See `AGENTS.md` for the sharing rules.
- **Standard XDG folders.** Data is in `~/.local/share` (was `~/.config/local/share`), cache in `~/.cache` (was `~/.config/cache`), state in `~/.local/state`. zsh history is `~/.local/state/zsh/history`.
- **Agent skills** live in the private `lukeomalley/agent-skills` repo at `~/code/agent-skills`.
- **Git keys**: each machine has its own passphrase-free key at `~/.ssh/id_ed25519` for GitHub auth and commit signing. 1Password is no longer used for git or SSH, and no GitHub token is in the environment; `gh` uses its own login.
- **Atuin** only takes Ctrl-R (Up arrow is plain shell history) and its search box uses emacs keys: Ctrl-N/Ctrl-P move, Enter runs, Tab edits, Esc closes.
- **Docker Desktop replaced by OrbStack**, without admin mode, so Homebrew's `kubectl` wins.
- **Removed**: OpenCode, Ollama, lazygit, coder, the Claude and OpenCode subagents, the Atlassian and Firecrawl MCP scripts, iTerm2, ranger, rclone, and several old `~/bin` scripts.
- **AeroSpace** uses the 0.21 rule syntax; all workspaces are on the main monitor.

## Other Macs

Close every terminal and run `tmux kill-server` first, then work from a single new terminal.

1. **Reset the repo.** Check for anything unpushed (`git status`, `git log origin/main..`), then:
   ```bash
   cd ~/code/dotfiles
   git fetch origin && git reset --hard origin/main
   git clean -ndx   # preview untracked/ignored files inside the repo
   git clean -fdx   # remove them; stow would otherwise link them into $HOME
   ```

2. **Re-link.** Delete links into the old layout, then stow the new one:
   ```bash
   find ~ ~/Library/Application\ Support -maxdepth 4 -type l -lname '*code/dotfiles*' -delete 2>/dev/null
   ./scripts/stow.sh
   ```
   Delete `~/.zprofile` and `~/.zshrc` in `$HOME` if present; zsh reads `~/.config/zsh`.

3. **Move data to the standard XDG folders**, before opening another shell. Move state; let installs rebuild:
   ```bash
   setopt interactive_comments 2>/dev/null   # allow the comments below when pasted into zsh
   OLD=~/.config/local/share NEW=~/.local/share
   mkdir -p "$NEW/atuin" ~/.local/state/zsh
   # zsh history
   cat "$OLD/zsh/history" >> ~/.local/state/zsh/history 2>/dev/null
   # Atuin: history.db, key and session are pinned to $NEW/atuin by its config;
   # everything else (records.db, meta.db, host_id, ...) may be live in $OLD.
   sqlite3 "$OLD/atuin/records.db" 'PRAGMA wal_checkpoint(TRUNCATE);' 2>/dev/null
   for f in "$OLD"/atuin/*; do case ${f##*/} in history.db*|key|session) ;; *) mv -f "$f" "$NEW/atuin/";; esac; done
   # Move everything else that is not already in $NEW; compare by hand if both exist.
   # Skip mise and uv: their installs embed absolute paths, so they get reinstalled.
   for d in "$OLD"/*; do n=${d##*/}; case $n in atuin|zsh|mise|uv) continue;; esac; if [ -e "$NEW/$n" ]; then echo "check by hand: $n"; else mv "$d" "$NEW/"; fi; done
   rm -rf "$NEW/nvim/mason"   # Neovim reinstalls its language servers
   # Re-point absolute links and embedded paths at the new folder
   find "$NEW" -path "$NEW/pnpm/store" -prune -o -type l -lname "$OLD/*" -print | while read -r l; do t=$(readlink "$l"); ln -sfn "$NEW${t#$OLD}" "$l"; done
   grep -rlI --exclude-dir=store --exclude-dir=node_modules "$OLD" "$NEW" | while read -r f; do perl -pi -e "s#\Q$OLD\E#$NEW#g" "$f"; done
   mv ~/.config/local ~/.config/local.pre-xdg; mv ~/.config/cache ~/.config/cache.pre-xdg
   ```
   Then in a new terminal: `uv tool install ruff` for any uv tools you had, and open a code file in Neovim so Mason reinstalls servers (or `:MasonInstall basedpyright ruff tsgo eslint-lsp biome lua-language-server gopls emmet-ls clangd rust-analyzer`). Each pnpm project asks once to rebuild `node_modules` (its store moved); projects using mise reinstall tools on `mise install`. Delete the two `.pre-xdg` folders once everything works.

4. **Homebrew.**
   ```bash
   brew bundle --file=packages/Brewfile
   brew bundle cleanup --file=packages/Brewfile   # review what is not in the Brewfile
   ```
   Uninstall anything listed that you don't want (`--force` removes all of it). Expect at least `docker-desktop` (`brew uninstall --zap --cask docker-desktop`), `opencode`, `opencode-desktop`, `ollama`, `lazygit`, `coder`, `ranger`, `rclone`; then remove their data (`~/.config/opencode`, `~/.local/share/opencode`, `~/.ollama`, `~/.docker`).

5. **OrbStack.** Open it once, then:
   ```bash
   orb config set setup.use_admin false
   sudo rm -f /usr/local/bin/{docker,docker-compose,docker-credential-*,kubectl,kubectl.docker,cagent,orb,orbctl}
   ```

6. **Agent skills.** If `~/.agents/skills` is a real directory (not a symlink), move it aside first, then `./scripts/agent-skills.sh`.

7. **Git key.** If an old `~/.ssh/id_ed25519` exists with a passphrase or unknown purpose, delete it so a fresh one is made, then `./scripts/git-keys.sh personal-mbp` (pick this machine's name). On machines that use Bitbucket, add `~/.ssh/id_ed25519.pub` in Bitbucket (Personal settings > SSH keys) for auth and signing.

8. **Secrets, settings, tmux.** `update-secrets`, `./scripts/darwin/settings.sh`, `./scripts/setup-tmux.sh`. Open a new terminal.

### Verify

```bash
echo "XDG_DATA_HOME=$XDG_DATA_HOME HISTFILE=$HISTFILE GITHUB_TOKEN=${GITHUB_TOKEN:-unset}"
which node pnpm kubectl docker      # fnm node, /opt/homebrew/bin/kubectl, ~/.orbstack/bin/docker
ssh -T git@github.com               # "Hi lukeomalley!"
gh auth status
brew bundle check --file=packages/Brewfile
aerospace reload-config --warnings-as-errors
cd /tmp && git init -q t && cd t && git commit -q --allow-empty -m t && git log --format='%G?' -1   # G
```
Also try Ctrl-R in a new terminal and check no links are broken: `find ~ -maxdepth 4 -type l -lname '*code/dotfiles*' ! -exec test -e {} \; -print`.

## Omarchy

The old `feat/cross-platform-dotfiles` branch is retired. Start from `main`, port only the Omarchy-specific pieces from that branch, and keep everything else shared. The Mac config wins wherever they differ.

1. **Reset.** `git fetch origin && git checkout main && git reset --hard origin/main`. Keep the old branch around only as a reference until step 7.
2. **Make room for the shared config.** Omarchy ships its own files where stow will link ours (Git, Ghostty, Neovim, ...). Run `./scripts/stow.sh` once; for every conflict it reports, move the existing file aside (don't merge it into the repo). Also check `~/.gitconfig`: it loads after `~/.config/git/config` and must not override the identity or signing settings.
3. **Add the Omarchy layer**, following the sharing rules in `AGENTS.md` (shared by default, OS differences handled inside the shared file, one owner per file):
   - `stow/omarchy/`: Hyprland, voxtype, the Omarchy plugins (from the old branch).
   - `stow/hosts/<hostname>/`: this laptop's monitors and devices. `<hostname>` is `uname -n` up to the first dot.
   - `packages/omarchy.txt` with everything the shared config uses: zsh, zsh-autosuggestions, zsh-syntax-highlighting, fnm, wl-clipboard, the Inconsolata Nerd Font (`ttf-inconsolata-nerd`), stow, github-cli, git-delta, eza, bat, fd, fzf, ripgrep, zoxide, atuin, starship, direnv, neovim, tmux, lf, k9s, kubectl, jq, jless, 1password-cli, oxfmt, and so on.
   - `scripts/omarchy/packages.sh` (install that list) and `scripts/omarchy/settings.sh`, which must make zsh the login shell (`chsh -s /usr/bin/zsh`) and install `system/omarchy/` files such as the keyd config.
4. **Fix shared files only where Linux genuinely differs**, with an in-file check (see how `.zshenv` guards Homebrew and the zsh plugin loop tries both paths), never a copy. Ghostty ignores macOS-only options; use `stow/hosts/<hostname>/` with a Ghostty `local` file if the font size needs adjusting.
5. **Run it.** `./scripts/bootstrap.sh`, then log out and back in so zsh is the login shell. `./scripts/git-keys.sh omarchy` registers this machine's key.
6. **Don't run Omarchy's font or config-refresh tools** (`omarchy-font-set`, `omarchy-refresh-config`) on files the repo manages; they replace links with copies or write through them.
7. **Verify and finish.** Same checks as the Mac where they apply (`which node`, `ssh -T git@github.com`, a signed test commit, Ctrl-R, no broken links). Commit and push from Linux, then delete the old branch: `git push origin --delete feat/cross-platform-dotfiles`.

## After every machine is caught up

- Delete the old 1Password SSH keys ("GitHub", "GitHub Signing", "Bitbucket") from 1Password, GitHub and Bitbucket, plus the 2021 `mac` RSA key on GitHub.
- Delete this file.
