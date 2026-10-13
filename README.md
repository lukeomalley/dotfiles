# Dotfiles

Personal configuration for macOS and Omarchy (Arch Linux), managed with **GNU Stow**. Most config is shared; each OS adds only what is unique to it.

```
stow/common/    shared by every machine (zsh, git, nvim, tmux, ghostty, ...)
stow/darwin/    macOS only (AeroSpace, Cursor)
stow/omarchy/   Omarchy only
stow/hosts/     one machine's hardware, e.g. monitors
packages/       what each OS installs (Brewfile on macOS)
scripts/        setup steps, shared and per-OS
.agents/skills/ the setup-machine skill for agents
```

## Included Configurations
- **Shell**: Zsh with Starship prompt, Atuin history, zoxide, fnm
- **Editors**: Neovim, Cursor (macOS)
- **Terminal**: Ghostty, Tmux (with Smug sessions)
- **Window manager**: AeroSpace (macOS), Hyprland (Omarchy)
- **AI agents**: Claude Code
- **Tools**: Git, lf, k9s, psql, SSH

## Setting up a computer

1. Clone the repository (on a Mac, run `xcode-select --install` first to get git):
   ```bash
   git clone https://github.com/lukeomalley/dotfiles.git ~/code/dotfiles
   ```

2. Open Claude Code or Codex in `~/code/dotfiles` and say "set up this computer". The [`setup-machine`](.agents/skills/setup-machine/SKILL.md) skill asks a few questions (machine name, personal or work), tells you what it needs from you, then runs the steps below for macOS or Omarchy and checks the result.

   Or run everything unattended:
   ```bash
   ./scripts/bootstrap.sh
   ```

Either way, setup:
- Installs packages (`packages/Brewfile` on macOS, `packages/omarchy.txt` on Omarchy)
- Links the configuration with `stow`
- Creates this machine's SSH key and registers it on GitHub for auth and commit signing
- Clones and links the agent skills
- Applies OS settings
- Installs tmux plugins
- Generates `secrets.zsh` from 1Password

`./scripts/check.sh` checks a machine against the repo at any time. It changes nothing.

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
