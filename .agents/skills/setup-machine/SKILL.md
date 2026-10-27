---
name: setup-machine
description: Set up a new or existing computer (macOS or Omarchy Linux) with these dotfiles - packages, config links, Git keys, secrets and OS settings - then verify it. Use when asked to onboard, set up, bootstrap or check a machine.
---

# Set up a machine

Get this computer onto the dotfiles in `~/code/dotfiles`. Read `AGENTS.md` first. The scripts in `scripts/` do the known work; your job is to run them in order, handle whatever is different about this machine, and keep the user informed.

`scripts/check.sh` checks everything and changes nothing. Run it at the start, after any step you're unsure of, and at the end.

## 1. Ask

Run `scripts/check.sh` and look around first, so you only ask what you can't see. Then ask, in one message:

1. **Machine name** for its SSH key on GitHub. Suggest one, e.g. `psci-mbp` or `personal-mbp`.
2. **Personal or work machine?** Personal machines also get Bitbucket; work machines are GitHub only.
3. **Only if check.sh shows real files or old links where the repo's links go:** is this a machine with older dotfiles? If its data still lives in `~/.config/local` (the pre-October 2026 layout), follow the old catch-up guide from git history: `git show "$(git rev-list -1 HEAD -- CATCH-UP.md)^:CATCH-UP.md"`.

On Omarchy, also confirm the hostname. It names the machine's hardware folder (`stow/hosts/<hostname>`), so a generic or reused one should be changed first (`hostnamectl set-hostname <name>`).

## 2. Tell

Before running anything, list what you'll need from the user, then wait for a go:

- Their password for steps that use sudo (see "Steps that need a password").
- Approving a GitHub one-time code in the browser (`git-keys.sh`).
- The 1Password app signed in, with Settings > Developer > "Integrate with 1Password CLI" on, for `update-secrets`.
- Personal machines: pasting the public key into Bitbucket.
- Omarchy: logging out and back in at the end, after the shell changes to zsh.

## 3. Run

Detect the OS with `uname -s` (`scripts/os.sh` maps it to `darwin` or `omarchy`). Run the steps in this order, one at a time. If a step fails, find out why before moving on.

| Step | macOS (`darwin`) | Omarchy (`omarchy`) |
|---|---|---|
| Before | `xcode-select --install` if `git` is missing | Stop unless the `omarchy` command exists; other Linux distros aren't supported |
| Packages | `scripts/darwin/packages.sh`: Homebrew, `packages/Brewfile`, Rust | `scripts/omarchy/packages.sh`: `packages/omarchy.txt` via `omarchy pkg add`, AUR fallback |
| Hardware | Nothing usually | If `stow/hosts/<hostname>` is missing, create it from `hyprctl monitors` and `hyprctl devices`, modeled on `stow/hosts/omarchy` |
| Links | `scripts/stow.sh` | `scripts/stow.sh` |
| Git keys | `scripts/git-keys.sh <name>` | `scripts/git-keys.sh <name>` |
| Agent skills | `scripts/agent-skills.sh` | `scripts/agent-skills.sh` |
| Settings | `scripts/darwin/settings.sh`: keyboard, defaults, AeroSpace | `scripts/omarchy/settings.sh`: keyd, fnm Node, voxtype model, zsh login shell |
| Apps | Open OrbStack once, then `orb config set setup.use_admin false`. Open AeroSpace and Ghostty. | `hyprctl reload`; ask whether they want the Neovim theme from the README |
| tmux | `scripts/setup-tmux.sh` | `scripts/setup-tmux.sh` |
| Secrets | `update-secrets` | `update-secrets` |

**Personal machines, after Git keys:** copy `~/.ssh/id_ed25519.pub` to the clipboard (`pbcopy <` or `wl-copy <`), and open https://bitbucket.org/account/settings/ssh-keys/. The user adds it as an authentication key and again as a signing key. Then run `ssh -T -o StrictHostKeyChecking=accept-new git@bitbucket.org` to trust the host and confirm.

### Steps that need a password

Your shell usually has no terminal, so `sudo` can't prompt. When a step needs it (installing Homebrew, some casks, `pmset` in macOS settings, pacman on Omarchy), give the user the exact command to run in their own terminal, wait, then check the result. Omarchy's `settings.sh` falls back to a graphical `pkexec` prompt on its own.

### When things go wrong

- **Stow conflicts:** a real file is where a link should go. Look at it. Move it to `~/.local/state/dotfiles-backup/<date>/` and re-run `stow.sh`. Never `stow --adopt`, and never merge the machine's file into the repo unless the user asks.
- **Agent skills or secrets fail:** continue and report it at the end. Both depend on logins that can be fixed later.
- **A shared file misbehaves on this OS:** fix it inside that file with a check, as `AGENTS.md` describes, never by copying it into an OS layer. Commit only if the user agrees, and say in the message that the other OS needs re-checking.
- **Something is missing from the scripts:** if you had to do a step by hand that every new machine will need, suggest adding it to the right script.

## 4. Verify and report

Open a new shell and run `scripts/check.sh` until every check passes or only expected ones fail. On personal machines, Bitbucket must show PASS. Then tell the user briefly:

- What was set up, and anything you changed in the repo.
- What is left for them, e.g. log out and back in (Omarchy, and macOS for key repeat), or a login that failed.
