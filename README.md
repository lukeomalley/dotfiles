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

[oma-cast](https://github.com/typecraft-dev/oma-cast) is the default launcher on **Super+Space** (Command+Space on the Mac keyboard). The existing Omarchy bar menu and other menu shortcuts remain available.

Setup installs a pinned upstream revision with `scripts/omarchy/oma-cast.sh`; rerun that script to install it on an existing machine after pulling these dotfiles. It includes compatibility for Omarchy 4.0.5's IPC and overlay window components. To update it, change the revision in that script, rerun it, and run `omarchy restart shell` to clear cached QML.

The plugin is installed under `~/.config/omarchy/plugins/typecraft.oma-cast-managed`, outside the Stow packages; `shell.json` enables it and `bindings.lua` owns the shortcut. Control it from the terminal with `omarchy-shell oma-cast toggle` (or `show` / `hide`). The upstream install/setup commands are unnecessary. `scripts/check.sh` checks its backend health.

Omarchy uses adaptive pointer acceleration, physical touchpad clicks (no tap-to-click), and disables the touchpad while typing. The settings script installs a libinput quirk so typing through keyd still suppresses the touchpad; log out and back in after first installing it. Libinput also provides hardware-dependent palm detection. Alt/Super are swapped by default; `intel-mac-omarchy` overrides this in its host `devices.lua` so Command remains Super.

Setup also installs `system/omarchy/hosts/<hostname>/logind-keep-online.conf` when present. On `intel-mac-omarchy`, this keeps the laptop online with its lid closed on charger power. Apply just the libinput and host lid settings with `./scripts/omarchy/system-settings.sh`; this leaves Voxtype and other app setup alone. Existing system files are backed up before replacement, and unchanged files are left alone.

### Updating an existing Omarchy machine

These settings require Omarchy 4 with Lua-configured Hyprland and `omarchy-shell`.
To apply the launcher, faster animations, and input/system settings without
rerunning the full app setup:

```bash
cd ~/code/dotfiles
git pull --ff-only
./scripts/stow.sh
./scripts/omarchy/oma-cast.sh
./scripts/omarchy/system-settings.sh
hyprctl reload
hyprctl configerrors
```

Stop and resolve any Stow conflict by backing up the conflicting real file;
never use `stow --adopt`. Log out and back in to activate the libinput change,
then run `./scripts/check.sh`.

The faster animations, launcher, and touchpad preferences apply to all Omarchy
machines. Apple keyboard/display settings and lid-closed behavior apply only to
`intel-mac-omarchy`; other hosts keep their own hardware configuration. Wi-Fi
profiles and their reconnect/power-saving settings remain machine-local.

Not provisioned by bootstrap: the Neovim Night Rock theme ([dark-rock-theme](https://github.com/lukeomalley/dark-rock-theme)) at `~/code/dark-rock-theme`.

After changes, check `hyprctl configerrors` and `ghostty +validate-config`.
