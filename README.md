# Cross-platform dotfiles

One GNU Stow repository for shared shell/tool configuration, macOS, and
[Omarchy](https://omarchy.org/). Deployments are composed from layers:

```text
macOS   = stow/common + stow/darwin  + stow/hosts/<hostname> (if present)
Omarchy = stow/common + stow/omarchy + stow/hosts/<hostname> (if present)
```

Each child of a layer is an independent Stow package. Stow always uses
`--no-folding`, so only declared files become links and application-created
state stays outside Git.

## Layout

```text
packages/             Brewfile and explicitly added Omarchy packages
scripts/              detection, installation, deployment, and validation
stow/common/          portable configuration
stow/darwin/          macOS-only configuration
stow/omarchy/         Omarchy/Hyprland-only configuration
stow/hosts/<name>/    machine-specific packages (for example monitors)
system/omarchy/etc/   source copies of explicitly installed system files
tests/                repository-level checks
```

`/usr/share/omarchy` is package-owned and is never modified. This repository
tracks intentional user overrides only.

## Preview and deploy

Install GNU Stow first, then preview the complete selected profile:

```bash
./scripts/stow-profile --dry-run
./scripts/stow-profile
```

Useful options:

```bash
./scripts/stow-profile --profile darwin --dry-run
./scripts/stow-profile --profile omarchy --host omarchy --dry-run
./scripts/stow-profile --package nvim
./scripts/stow-profile --unstow --package nvim
```

Bootstrap installs missing declared packages, performs a full Stow preview,
deploys, applies platform setup, initializes TPM, optionally generates secrets,
and verifies the result:

```bash
./scripts/bootstrap
./scripts/bootstrap --dry-run
./scripts/bootstrap --skip-packages --skip-secrets --skip-tpm
./scripts/bootstrap --package nvim --skip-packages
```

Dry-run never installs packages, changes settings, clones TPM, or generates
secrets. Package installers do not perform a system-wide upgrade unless the
Darwin installer is explicitly passed `--upgrade`.

## Safely adopting an existing machine

Stow deliberately fails when a real target file exists. Never use `stow
--adopt` for this migration: it can silently replace repository content.

First create a report:

```bash
./scripts/adopt-existing --profile omarchy
```

Manually reconcile every `CONFLICT`. Once all remaining files are byte-for-byte
identical, this command backs them up under
`~/.local/state/dotfiles-backup/<timestamp>/`, records checksums, and removes
only those identical targets so Stow can create links:

```bash
./scripts/adopt-existing --profile omarchy --apply
./scripts/stow-profile --profile omarchy --dry-run
./scripts/stow-profile --profile omarchy
```

The adoption script refuses differing files and links owned elsewhere. It
operates on individual managed files, never entire configuration trees.

## Omarchy details

The Hyprland package loads Omarchy defaults from `/usr/share/omarchy` and then
user overrides. `input.lua` swaps physical Alt and Super. Caps Lock's
tap-Escape/hold-Control behavior is handled by keyd because XKB does not provide
the required dual-role behavior.

The keyd source is versioned at `system/omarchy/etc/keyd/default.conf`. Installing
it is a separate, privileged, opt-in action:

```bash
./scripts/configure-omarchy --install-keyd
```

Emergency keyd stop chord: `Backspace + Escape + Enter`. Roll back with
`./scripts/configure-omarchy --disable-keyd`; this preserves the configuration
as `/etc/keyd/default.conf.disabled`.

Voxtype uses the CPU-friendly Parakeet TDT int8 model with Insert as a
Hyprland-managed push-to-talk key. The config and binding are stowed; the model
and ONNX backend are installed separately because generated model data does not
belong in Git:

```bash
./scripts/configure-omarchy --install-voxtype
```

The current `monitors.lua` is host-specific under `stow/hosts/omarchy`. Rename
that host directory to the output of `hostname -s` on another machine.

After manual Omarchy deployment, validate the live session:

```bash
hyprctl reload
hyprctl configerrors
```

Omarchy updates should retain user files. Commit a checkpoint before updating.
`omarchy refresh hyprland` intentionally replaces user configuration (with
backups), so run it only when you intend to reconcile refreshed defaults.

## Shared configuration and secrets

Zsh loads `platform/darwin.zsh` or `platform/linux.zsh`. Git includes
`~/.config/git/platform`; SSH includes `~/.ssh/config.d/*.conf`. The selected
platform supplies those targets. Ghostty shares themes but has platform-specific
main configuration.

Secrets remain generated from `secrets.tpl` using 1Password's `op inject` via
`~/bin/update-secrets`; `secrets.zsh` is ignored. Never commit tokens, private
keys, generated credentials, runtime state, or backup files.

Changing the login shell is intentionally not automated. Test with `zsh -df`
and `zsh -lic 'echo shell-ok'`, then change it manually if desired.

## Validation and recovery

```bash
./tests/profile-layout.sh
./scripts/verify --profile omarchy
```

Validation checks shell syntax, optional ShellCheck/Zsh checks, profile leakage,
and, in a live Omarchy session, Hyprland errors. Also validate Git/SSH auth, a
signed test commit, Ghostty, Neovim, Tmux, Atuin, clipboard helpers, monitor
scale, and actual Alt/Super and Caps behavior on each machine.

Remove links with `stow-profile --unstow --package NAME`. Restore adopted files
from the timestamped backup if needed. Git tracks configuration history, not
untracked machine state.
