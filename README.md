# Mac Configuration Files

Personal dotfiles and configuration scripts for macOS, managed with **GNU Stow** and **Homebrew**.

## Included Configurations
- **Shell**: Zsh with Starship prompt, zoxide, fnm
- **Editor**: Neovim (nvim)
- **Terminal**: Ghostty, iTerm2
- **Tools**: Tmux, Ranger, k9s, rclone, Smug, Git

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/code/dotfiles
   ```

2. Run the bootstrap script:
   ```bash
   ./scripts/bootstrap.sh
   ```

This script will:
- Install Homebrew and dependencies (via `Brewfile`)
- Symlink configuration files using `stow`
- Apply macOS keyboard settings

## Atlassian TWG CLI

Jira skills use Atlassian's TWG CLI with OAuth. After bootstrap on a new machine, install TWG using the [official setup guide](https://developer.atlassian.com/cloud/twg-cli/getting-started/installation/). The installer requires an interactive terminal for consent and browser sign-in and installs Atlassian's agent skills. It is separate from Homebrew bootstrap.

Select `procurementsciences.atlassian.net` during setup. Keep TWG credentials and runtime state local; do not Stow them. Confirm `twg --version` and a native Jira read work. If the binary is not on PATH, use `$HOME/.local/bin/twg` and add `$HOME/.local/bin` to PATH.

The custom PSCI skills keep ticket defaults and description templates; the vendor `twg` and `twg-jira` skills supply Jira command guidance. Jira ticket creation does not need a shell API-token export.
