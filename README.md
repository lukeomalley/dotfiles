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

Linux uses the shared config unchanged (Zsh, Ghostty with Night Rock and Inconsolata, fnm, per-machine Git keys). `stow/omarchy` adds Hyprland overrides, the menu, workspace and clipboard plugins, and Voxtype dictation on Insert. `stow/hosts/omarchy` holds the ThinkPad's monitors and pointer settings; a new machine needs its own host folder named after its hostname.

```bash
./scripts/omarchy/packages.sh  # additions to the Omarchy base (packages/omarchy.txt)
./scripts/stow.sh
./scripts/omarchy/settings.sh  # keyd, fnm Node, Voxtype model, Zsh login shell
```

Log out and back in after the login shell changes. Keyd makes Caps Lock Escape on tap and Control on hold. Super+Ctrl+F opens Ghostty's quick terminal (Ghostty must be running); Super+F is fullscreen.

Not provisioned by bootstrap: the radar plugin ([omastorm](https://github.com/wesleygrimes/omastorm)) at `~/.config/omarchy/plugins/com.omastorm.radar`, and the Neovim Night Rock theme ([dark-rock-theme](https://github.com/lukeomalley/dark-rock-theme)) at `~/code/dark-rock-theme`.

After changes, check `hyprctl configerrors` and `ghostty +validate-config`.
