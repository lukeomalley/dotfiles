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
- **Window manager**: AeroSpace (macOS)
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
