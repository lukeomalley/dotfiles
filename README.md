# Mac Configuration Files

Personal dotfiles and configuration scripts for macOS, managed with **GNU Stow** and **Homebrew**.

## Included Configurations
- **Shell**: Zsh with Starship prompt, Atuin history, zoxide, fnm
- **Editors**: Neovim, Cursor
- **Terminal**: Ghostty, Tmux (with Smug sessions)
- **Window manager**: AeroSpace
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
- Install Homebrew and dependencies (via `Brewfile`)
- Symlink configuration files using `stow`
- Create this machine's SSH key and register it on GitHub for auth and commit signing
- Clone and link the agent skills
- Apply macOS keyboard and system settings
- Install tmux plugins
- Generate `secrets.zsh` from 1Password

## Git Keys

Each machine gets its own SSH key, so commits are signed and pushed without prompts. Bootstrap asks for a machine name (e.g. `psci-mbp`) and opens a GitHub login in the browser once. To use Bitbucket on a machine, add `~/.ssh/id_ed25519.pub` in Bitbucket for auth and signing.

## Agent Skills

Agent skills live in their own private repo, [lukeomalley/agent-skills](https://github.com/lukeomalley/agent-skills), cloned to `~/code/agent-skills`. Its `bin/sync` links the skills into `~/.agents/skills` (read by Codex, Cursor, OpenCode, Copilot, and Gemini) and `~/.claude/skills` (Claude Code). Bootstrap runs `scripts/agent-skills.sh` to clone and link them. See that repo's README for adding and updating skills.
