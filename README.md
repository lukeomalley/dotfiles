# Dotfiles

Personal configuration for macOS and Omarchy (Arch Linux), managed with **GNU Stow**. Most config is shared; each OS adds only what is unique to it.

```
stow/common/    shared by every machine (zsh, git, nvim, tmux, ghostty, ...)
stow/darwin/    macOS only (AeroSpace, Cursor)
stow/omarchy/   Omarchy only
stow/hosts/     one machine's hardware, e.g. monitors
packages/       what each OS installs (Brewfile on macOS)
scripts/        setup steps, shared and per-OS
```

## Included Configurations
- **Shell**: Zsh with Starship prompt, Atuin history, zoxide, fnm
- **Editors**: Neovim, Cursor (macOS)
- **Terminal**: Ghostty, Tmux (with Smug sessions)
- **Window manager**: AeroSpace (macOS), Hyprland (Omarchy)
- **AI agents**: Claude Code
- **Tools**: Git, lf, k9s, psql, SSH

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/lukeomalley/dotfiles.git ~/code/dotfiles
   ```

2. Run the bootstrap script:
   ```bash
   ./scripts/bootstrap.sh
   ```

This script will:
- Install packages (Homebrew and `packages/Brewfile` on macOS)
- Symlink configuration files using `stow`
- Create this machine's SSH key and register it on GitHub for auth and commit signing
- Clone and link the agent skills
- Apply OS settings (keyboard and system defaults on macOS)
- Install tmux plugins
- Generate `secrets.zsh` from 1Password

## Git Keys

Each machine gets its own SSH key, so commits are signed and pushed without prompts. Bootstrap asks for a machine name (e.g. `psci-mbp`) and opens a GitHub login in the browser once. To use Bitbucket on a machine, add `~/.ssh/id_ed25519.pub` in Bitbucket for auth and signing.

## Agent Skills

Agent skills live in their own private repo, [lukeomalley/agent-skills](https://github.com/lukeomalley/agent-skills), cloned to `~/code/agent-skills`. Its `bin/sync` links the skills into `~/.agents/skills` (read by Codex, Cursor, OpenCode, Copilot, and Gemini) and `~/.claude/skills` (Claude Code). Bootstrap runs `scripts/agent-skills.sh` to clone and link them. See that repo's README for adding and updating skills.

## Omarchy

The shared Mac configuration is used unchanged, including Ghostty's Night Rock
theme and Inconsolata font, Zsh, fnm, and per-machine Git keys. Linux additions
live in `stow/omarchy`: Hyprland overrides, menu/workspace/clipboard plugins,
and Parakeet dictation on Insert. Super+Ctrl+F invokes Ghostty's quick file
browser (replacing Omarchy's tiled-fullscreen shortcut); Super+F is fullscreen.
Ghostty must be running for its global shortcut to be registered.

`stow/hosts/omarchy` contains this laptop's Acer/external display layout and
pointer settings. Another host needs its own monitor configuration.

Setup steps can be run individually:

```bash
./scripts/omarchy/packages.sh  # missing additions to the Omarchy base; no system upgrade
./scripts/stow.sh             # configuration links only
./scripts/omarchy/settings.sh # keyd, fnm Node/tools, Voxtype model, Zsh login shell
```

Settings installs the versioned `/etc/keyd` files only when different, backing
up existing copies first. Caps Lock is Escape on tap and Control on hold;
the Flow84 has separate Alt/Super mappings. System files and downloaded models
are never stowed. Log out and back in after changing the login shell.

For an existing machine, back up conflicting files before stowing. Remove only
verified links owned by the old dotfiles checkout, and keep generated secrets,
history, plugins and caches outside the packages. Do not run Omarchy theme/font
or refresh commands on repository-managed files: they may overwrite symlinks
or write through them. The radar plugin is separately installed and is not
vendored here.

After deployment, check `hyprctl configerrors`, `ghostty +validate-config`,
a fresh Zsh shell, `fnm current`, GitHub authentication and signed commits.
Also check the menu/clipboard/workspace plugins, dictation, keyboard mappings
and monitor unplug/replug behavior. Mac behavior must be rechecked on a Mac
if a shared file changes.
