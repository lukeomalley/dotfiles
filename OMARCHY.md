# Omarchy handoff

For the agent setting up this repo on the Omarchy (Arch Linux + Hyprland) laptop. Read this and `AGENTS.md` before changing anything. The Mac side is done and verified; your job is to add the Linux pieces without changing how the Mac works. When you're finished, move any lasting rules into `AGENTS.md` and delete this file.

## Decisions already made

- **One repo, shared by default.** The Mac config is the source of truth. Linux should match it, not keep Omarchy's defaults, except where Linux genuinely needs something different.
- **No duplicate files.** OS differences live inside the shared file (a path check, or trying both locations), or in an app's optional include. An OS layer only holds tools that exist on that OS. Each file has exactly one owner; stow layers add files and never override each other.
- **zsh** is the shell on both machines, with the shared `.zshenv`/`.zshrc`. Omarchy defaults to bash; switch the login shell. Don't install `omarchy-zsh`; the shared config replaces it.
- **Node comes from fnm**, not mise (Omarchy's bash init uses mise, but that only runs in bash).
- **Ghostty uses the shared config** with the Night Rock theme and the Inconsolata Nerd Font, not Omarchy's theme switcher.
- **Standard XDG directories** (`~/.local/share`, `~/.cache`, `~/.local/state`), set in `.zshenv`. Omarchy already uses these.
- **Git**: each machine has its own passphrase-free SSH key for GitHub auth and signing (`scripts/git-keys.sh`). No 1Password in git or SSH, and no GitHub token in the environment.
- **Atuin** only takes Ctrl-R, with emacs keys in its search box.
- **Cursor and AeroSpace are Mac-only.**

## Already prepared for Linux (verify each)

| Where | What it does on Linux | Check |
|---|---|---|
| `stow/common/zsh/.zshenv` | Skips Homebrew, rustup, libpq and OrbStack lines (their paths don't exist). Defines `pbcopy`/`pbpaste` as `wl-copy`/`wl-paste` wrappers when `pbcopy` is missing. | `type pbcopy`; Ctrl-T then Ctrl-Y copies a path; `jfmt` alias works |
| `stow/common/zsh/.config/zsh/.zshrc` | Loads zsh-autosuggestions and zsh-syntax-highlighting from `/usr/share/zsh/plugins`; fzf via `fzf --zsh`; fnm, zoxide, atuin, direnv, starship. | New shell starts with no errors; suggestions and highlighting show |
| `stow/common/git/.config/git/config` | `gh` credential helper prefixed with `/opt/homebrew/bin` on PATH, which is a no-op on Linux. | `git config --get-all credential.https://github.com.helper`; HTTPS push works |
| `stow/common/ghostty/.config/ghostty/config` | macOS-only options are ignored. Ends with `config-file = ?local` for per-host overrides. | `ghostty +validate-config`; font renders |
| `stow/common/ssh/.ssh/config` | `Include ~/.orbstack/ssh/config` is skipped when the file is missing. | `ssh -T git@github.com` |
| `scripts/os.sh`, `scripts/stow.sh`, `scripts/bootstrap.sh` | `uname -s` = Linux maps to the `omarchy` layer. The host layer is `stow/hosts/$(uname -n)` up to the first dot. | `./scripts/stow.sh` links common, omarchy and your host folder |

The quick-terminal keybind in Ghostty uses macOS `global:` keys; bind the quick terminal in Hyprland instead.

## Where your files go

```
stow/omarchy/<package>/...      Linux-only tools, mirroring $HOME (hypr, voxtype, omarchy)
stow/hosts/<hostname>/<pkg>/... this laptop's hardware only (monitors, devices, a Ghostty `local` font size)
packages/omarchy.txt            packages beyond the Omarchy base, one per line
scripts/omarchy/packages.sh     installs packages/omarchy.txt (bootstrap calls it)
scripts/omarchy/settings.sh     chsh to zsh, installs system/omarchy files, one-time setup (bootstrap calls it)
system/omarchy/...              files outside $HOME (e.g. /etc/keyd), installed by settings.sh, never stowed
```

Scripts follow the Mac ones: `#!/usr/bin/env bash`, `set -e`, find the repo with `ROOT="$(cd "$(dirname "$0")/../.." && pwd)"`, safe to re-run, no flags.

## Porting from `origin/feat/cross-platform-dotfiles`

That branch predates a big cleanup, so port only the Omarchy-specific pieces, and rename paths into the layout above.

**Port:**
- `stow/omarchy/hypr` (the five Hyprland `.lua` files)
- `stow/omarchy/omarchy`: the `luke.menu` plugin and `shell.json`
- `stow/omarchy/voxtype`
- `stow/hosts/omarchy/hypr-monitors`, moved to `stow/hosts/<actual hostname>/`
- `config/omarchy/plugins/luke.workspaces`. The old script copied it instead of stowing it. Find out why; stow it like `luke.menu` if Omarchy follows links there.
- `system/omarchy/etc/keyd/default.conf`
- The voxtype model setup and the `omarchy pkg add` install logic from `scripts/configure-omarchy` and `scripts/install-packages-omarchy`, simplified into the two scripts above.

**Don't port:**
- `stow/omarchy/ghostty`: use the shared config.
- `git-platform` and `ssh-platform`: 1Password signing and its SSH agent are gone.
- Anything from that branch's `stow/common`: it carries the old inventory (opencode, ranger, rclone, lazygit, old agents, old bin scripts).
- `detect-profile`, `stow-profile`, `verify`, `adopt-existing`, and the `tests/` folder.
- `rclone` and `ranger` in its package list.

**Starter `packages/omarchy.txt`:** check names against pacman and the AUR, and drop anything Omarchy already ships.

`stow zsh zsh-autosuggestions zsh-syntax-highlighting fnm wl-clipboard ttf-inconsolata-nerd github-cli git-delta atuin zoxide fzf fd bat eza direnv starship neovim tmux lf k9s kubectl jq jless keyd voxtype-bin playerctl 1password-cli`, plus whatever the shared Neovim config needs (e.g. `oxfmt`).

## Steps

1. Reset to `main` (history was rewritten): `git fetch origin && git reset --hard origin/main`.
2. Add the files above. Write `scripts/omarchy/packages.sh` and `settings.sh`, and run the packages step.
3. Run `./scripts/stow.sh`. For each conflict it reports, move Omarchy's existing file aside, don't merge it into the repo. Check `~/.gitconfig`: it must not override the identity or signing settings in `~/.config/git/config`.
4. Run `./scripts/omarchy/settings.sh`, which includes `chsh -s /usr/bin/zsh`. Then log out and back in.
5. Run `./scripts/git-keys.sh omarchy`, then `./scripts/agent-skills.sh`, `./scripts/setup-tmux.sh` and `update-secrets`.
6. Only if a shared file misbehaves on Linux: fix it inside that file with a check, and make sure the Mac behaves exactly the same afterwards. Say so in the commit message so the Mac side can re-verify.

## Watch out for

- Omarchy's `omarchy-font-set` and `omarchy-refresh-config` rewrite config files. On a stowed file they replace the link with a copy, or write through it into the repo. Don't use them on files the repo manages; check `git status` after any Omarchy tool touches config.
- Theme or font changes made through Omarchy's menus can hit the same files.
- Keep stow's `--no-folding`, and never leave untracked files inside a package.

## Done when

- `./scripts/stow.sh` runs clean, and no links are broken: `find ~ -maxdepth 4 -type l -lname '*code/dotfiles*' ! -exec test -e {} \; -print`.
- A new Ghostty window opens zsh with Night Rock and Inconsolata, and Ctrl-R (Atuin), Ctrl-T (fzf) and `pbcopy` work.
- `which node` points into fnm, `ssh -T git@github.com` works, and a test commit shows `G`.
- The Mac would see no changes to shared files, or only Linux checks it can ignore.
- Changes are committed and pushed, `git push origin --delete feat/cross-platform-dotfiles` is done, any lasting rules are in `AGENTS.md`, and this file is deleted.
