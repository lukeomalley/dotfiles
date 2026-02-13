# Dotfiles Repository

This repository is the single source of truth for macOS system configuration. Every config file lives here, tracked by git, and gets symlinked to its functional location on disk using GNU Stow. The goal: clone this repo on a fresh Mac, run bootstrap, and have a fully configured environment.

---

## Core Architecture

**Configs live here. Symlinks make them work.**

The `dotfiles/` directory contains stow packages. Each package mirrors the target filesystem structure relative to `$HOME`. When stowed, individual files get symlinked to where macOS and applications expect them.

```
dotfiles/zsh/.zshenv          -->  ~/.zshenv
dotfiles/zsh/.config/zsh/.zshrc  -->  ~/.config/zsh/.zshrc
dotfiles/git/.config/git/config  -->  ~/.config/git/config
dotfiles/bin/bin/review-pr       -->  ~/bin/review-pr
```

Git tracks the real files in this repo. The symlinks in `$HOME` point back here. Edits to either side are the same file.

---

## GNU Stow

Stow is the symlink manager. It takes a package directory and creates symlinks in a target directory (always `$HOME` for us).

### How stow.sh works

```bash
stow -R --adopt --no-folding -t "$HOME" "${package}"
```

The flags matter:

- **`-R` (restow)**: Removes then recreates symlinks. Cleans up stale links.
- **`--adopt`**: If a real file already exists at the target, stow moves it into the package directory and replaces it with a symlink. This prevents conflicts on first run.
- **`--no-folding`**: Only symlinks individual files, never entire directories. Without this, stow would symlink `~/.config/zsh/` as a directory symlink, and then runtime files (history, caches) would end up tracked by git. With `--no-folding`, only the specific config files get symlinked.
- **`-t "$HOME"`**: Target directory is always the user's home.

After stowing, the script runs `git checkout -- dotfiles/` to undo any changes `--adopt` pulled in. This keeps the repo clean.

### Adding a new package

1. Create a directory under `dotfiles/` named after the tool (e.g., `dotfiles/mytool/`)
2. Inside it, recreate the directory structure as it would appear relative to `$HOME`
3. Place your config files there
4. Run `./scripts/stow.sh` to create the symlinks

Example -- adding a hypothetical `wezterm` config:

```
dotfiles/wezterm/.config/wezterm/wezterm.lua
```

After stowing, this becomes `~/.config/wezterm/wezterm.lua` (a symlink).

### Removing a package

Delete the directory from `dotfiles/` and remove the symlinks manually, or run `stow -D <package>` from the `dotfiles/` directory.

---

## Homebrew

All system packages and applications are declared in the root `Brewfile`. This is the single source for what gets installed.

- **`brew` entries**: CLI tools and libraries (stow, git, neovim, tmux, ripgrep, fzf, etc.)
- **`cask` entries**: GUI applications (Ghostty, Docker Desktop, AeroSpace, 1Password CLI, etc.)

### Installing packages

```bash
brew bundle --file=Brewfile
```

Or run the full setup:

```bash
./scripts/homebrew.sh
```

### Adding a new package

Add the line to `Brewfile` and commit. The format is `brew "package-name"` for CLI tools or `cask "app-name"` for GUI apps. Keep the file sorted by category.

---

## Bootstrap Process

`scripts/bootstrap.sh` is the main entry point for setting up a fresh machine. It runs these steps in order:

1. **homebrew.sh** -- Installs Homebrew itself (if missing), then installs all packages from `Brewfile`
2. **amp.sh** -- Installs the Amp CLI
3. **stow.sh** -- Symlinks all dotfile packages to `$HOME`
4. **keyboard.sh** -- Sets fast key repeat (InitialKeyRepeat: 10, KeyRepeat: 1), disables press-and-hold
5. **macos.sh** -- Disables macOS animations, configures AeroSpace settings, enables ctrl+cmd window dragging
6. **setup-tmux.sh** -- Installs Tmux Plugin Manager (TPM)
7. **update-secrets** -- Generates `secrets.zsh` from 1Password template (if the script exists)

---

## Directory Structure

```
.
├── AGENTS.md              # This file -- project-level AI agent guidance
├── Brewfile               # Homebrew package declarations
├── README.md              # Human-readable overview
├── scripts/               # Setup and configuration scripts
│   ├── bootstrap.sh       # Main setup orchestrator
│   ├── homebrew.sh        # Homebrew install and package sync
│   ├── stow.sh            # Symlink all packages
│   ├── amp.sh             # Amp CLI installer
│   ├── keyboard.sh        # macOS keyboard settings
│   ├── macos.sh           # macOS system preferences
│   └── setup-tmux.sh      # Tmux plugin manager
└── dotfiles/              # Stow packages (each dir = one package)
    ├── aerospace/         # AeroSpace tiling window manager
    ├── amp/               # Amp AI coding assistant
    ├── atuin/             # Atuin shell history
    ├── bin/               # Personal scripts (~/ bin/)
    ├── claude/            # Claude AI editor
    ├── cursor/            # Cursor IDE settings
    ├── ghostty/           # Ghostty terminal
    ├── git/               # Git config and global ignore
    ├── iterm2/            # iTerm2 settings and color scheme
    ├── k9s/               # Kubernetes CLI tool
    ├── launchd/           # macOS Launch Agents
    ├── nvim/              # Neovim configuration
    ├── opencode/          # OpenCode AI editor
    ├── ranger/            # Ranger file manager
    ├── rclone/            # Rclone cloud sync
    ├── smug/              # Smug tmux session manager
    ├── ssh/               # SSH configuration
    ├── starship/          # Starship prompt
    ├── tmux/              # Tmux configuration
    └── zsh/               # Zsh shell (zshenv, zshrc, aliases)
```

---

## Key Conventions

### XDG Base Directory

Most configs follow the XDG spec. The environment is set in `dotfiles/zsh/.zshenv`:

- `XDG_CONFIG_HOME` = `~/.config`
- `XDG_DATA_HOME` = `~/.config/local/share`
- `XDG_CACHE_HOME` = `~/.config/cache`
- `ZDOTDIR` = `~/.config/zsh` (moves zsh config out of `$HOME`)

When adding a new tool's config, prefer placing it under `.config/<tool>/` rather than as a dotfile in `$HOME`.

### Secrets Management

Secrets are not committed to git. The system uses 1Password CLI:

- `dotfiles/zsh/.config/zsh/secrets.tpl` -- 1Password template with `op://` references
- `~/bin/update-secrets` -- Runs `op inject` to generate `secrets.zsh` from the template
- `secrets.zsh` is in `.gitignore`

Never commit API keys, tokens, or credentials. Use the 1Password template pattern instead.

### Personal Scripts

Scripts in `dotfiles/bin/bin/` get symlinked to `~/bin/`, which is on `$PATH`. These are small utilities:

- `update-secrets` -- Regenerate secrets from 1Password
- `cloudsync` -- rclone bisync with GNU Parallel
- `review-pr` -- Interactive PR review with fzf and amp
- `notes` -- Open notes directory in nvim
- `start-*` -- MCP server launchers (opencode-web, atlassian-mcp, firecrawl-mcp)
- `animations-on` / `animations-off` -- Toggle macOS animations
- `git-lg` / `git-lga` -- Git log formatting (these work as `git lg` because git resolves `git-*` scripts on PATH)

### The --no-folding Rule

This is the most important stow flag for this repo. Without it, stow creates directory-level symlinks (e.g., `~/.config/zsh` -> `dotfiles/zsh/.config/zsh`). That means any file an application writes to that directory ends up in the git repo. With `--no-folding`, only individual files get symlinked, so runtime artifacts stay local.

If you see a stow package picking up unwanted files, check that `--no-folding` is being used.

---

## Working with This Repo

### Editing configs

Just edit the files in this repo. The symlinks mean changes are immediately live. No need to re-stow after editing.

### After adding new files to an existing package

Run `./scripts/stow.sh` to create symlinks for the new files.

### After creating a new package

1. Create the directory structure under `dotfiles/`
2. Run `./scripts/stow.sh`
3. If the tool needs a Homebrew package, add it to `Brewfile`

### Checking what's symlinked

```bash
ls -la ~/.config/<tool>/
```

Symlinked files will show `->` pointing back to this repo.

### If stow complains about conflicts

A real file exists where stow wants to place a symlink. The `--adopt` flag handles this by pulling the existing file into the repo and replacing it with a symlink. The subsequent `git checkout` resets the repo to its committed state. If you actually want the existing file's contents, skip the git checkout step.

---

## What Not To Do

- **Don't create files directly in `$HOME` config dirs** if you want them tracked. Create them in the stow package and re-stow.
- **Don't commit secrets.** Use the 1Password template pattern.
- **Don't manually symlink.** Let stow manage all symlinks for consistency.
- **Don't remove `--no-folding`** from the stow command. Runtime files will leak into git.
- **Don't add stow packages for configs that contain only runtime data** (caches, history databases, etc.). Only track files you actually configure.
