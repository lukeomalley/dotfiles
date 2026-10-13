# Dotfiles

Shared configuration for macOS and Omarchy (Arch Linux), managed with GNU Stow. Clone to `~/code/dotfiles`. The Mac config is the source of truth.

To set up or check a computer, use the `setup-machine` skill (`.agents/skills/setup-machine/SKILL.md`). `scripts/check.sh` verifies a machine and changes nothing; run it after changes.

## Layout

- `stow/<layer>/<package>/` mirrors `$HOME`. `scripts/stow.sh` links `stow/common`, then `stow/<os>` (`darwin` or `omarchy`), then `stow/hosts/<hostname>` if it exists, e.g. `stow/common/git/.config/git/config` -> `~/.config/git/config`. Edits are live; re-run `stow.sh` only after adding or removing files.
- `packages/` lists what each OS installs (`Brewfile` on macOS). Keep it in sync with what is installed.
- `scripts/` holds the setup steps, shared at the top level and per-OS in `scripts/<os>/`. `bootstrap.sh` runs them in order.
- `system/<os>/` holds files for outside `$HOME` (e.g. `/etc`), installed explicitly, never stowed.

## Sharing between macOS and Linux

- Put config in `stow/common` by default. An OS layer is only for tools that exist on one OS (AeroSpace, Hyprland) or small per-OS files a shared file includes. `hosts/<hostname>` is only for one machine's hardware, e.g. monitors.
- Each file has exactly one owner. Layers add files; a later layer cannot override an earlier one's file, so stow fails on duplicates.
- Handle OS differences inside the shared file, never by copying it: check that a path exists (`[[ -x /opt/homebrew/bin/brew ]]`), try both locations, or use the app's optional include (Ghostty `config-file = ?local`). Ghostty ignores the other OS's options, and ssh skips a missing `Include`.

## Rules

- Stow runs with `--no-folding` so only files are linked, never directories. Keep it that way, or app runtime files leak into the repo.
- Stow links every file in a package, gitignored or not. Never leave untracked files (plugins, `node_modules`, generated files) inside a package.
- Track only files you configure, not caches or state. Prefer `~/.config/<tool>/`.
- Don't symlink by hand or create tracked files directly in `$HOME`; add them to a package and re-stow.
- Never commit secrets. The repo is public.
- Omarchy: track only user overrides, never `/usr/share/omarchy`. Don't run Omarchy theme, font or refresh commands on managed files; they replace links or write through them into the repo. After Hyprland changes, run `hyprctl reload` and `hyprctl configerrors`.
- Never use `stow --adopt`. Move a conflicting real file aside, then stow.
- When a shared file changes on one OS, re-verify it on the other.

## Environment

`stow/common/zsh/.zshenv` sets the standard XDG directories (`~/.config`, `~/.local/share`, `~/.cache`, `~/.local/state`) and `ZDOTDIR=~/.config/zsh`, and builds PATH for every shell type, so put env and PATH there rather than in `.zshrc`. Node versions come from fnm on both OSes.

## Secrets

`stow/common/zsh/.config/zsh/secrets.tpl` holds 1Password `op://` references. `update-secrets` renders it to `secrets.zsh` (gitignored), which `.zshrc` sources. Add new secrets to the template.

## Git and SSH keys

Each machine has its own passphrase-free key at `~/.ssh/id_ed25519`, used for GitHub auth and commit signing, so git never prompts. `scripts/git-keys.sh` creates it, registers it on GitHub, and writes `~/.ssh/allowed_signers` and GitHub's host keys.

- GitHub HTTPS auth uses the `gh` login. Don't put a GitHub token in the environment; `gh` would prefer it.
- Bitbucket is optional per machine: add the same public key there. Bitbucket repos use the email in `~/.config/git/identity-bitbucket`.
- Keep 1Password out of git and SSH.

## Scripts in ~/bin

- `notify` -- Push notification to Luke's devices via ntfy. Use it when a long task finishes, you need input, or you hit an unrecoverable error. Don't spam. `notify -t "Title" -p high -g white_check_mark "message"`
- `psql-llm` -- psql with clean CSV output for agents.
- `update-secrets` -- Regenerate `secrets.zsh`.
- `git-lg` / `git-lga` -- Compact git log (`git lg`).
- `yt-transcript` -- Print a YouTube video's transcript.
