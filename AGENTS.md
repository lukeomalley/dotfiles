# Dotfiles

macOS configuration, managed with GNU Stow and Homebrew. Clone to `~/code/dotfiles` and run `scripts/bootstrap.sh` to set up a fresh Mac.

## Layout

- `dotfiles/<package>/` mirrors `$HOME`. `scripts/stow.sh` symlinks each file into place, e.g. `dotfiles/git/.config/git/config` -> `~/.config/git/config`. Edits are live; re-run `stow.sh` only after adding or removing files.
- `Brewfile` declares every package and app. Keep it in sync with what is installed.
- `scripts/` holds setup steps; `bootstrap.sh` runs them in order.

## Rules

- Stow runs with `--no-folding` so only files are linked, never directories. Keep it that way, or app runtime files leak into the repo.
- Stow links every file in a package, gitignored or not. Never leave untracked files (plugins, `node_modules`, generated files) inside a package.
- Track only files you configure, not caches or state. Prefer `~/.config/<tool>/`.
- Don't symlink by hand or create tracked files directly in `$HOME`; add them to a package and re-stow.
- Never commit secrets. The repo is public.

## Environment

`dotfiles/zsh/.zshenv` sets `XDG_CONFIG_HOME=~/.config`, `XDG_DATA_HOME=~/.config/local/share`, `XDG_CACHE_HOME=~/.config/cache` and `ZDOTDIR=~/.config/zsh`, and builds PATH for every shell type, so put env and PATH there rather than in `.zshrc`.

## Secrets

`dotfiles/zsh/.config/zsh/secrets.tpl` holds 1Password `op://` references. `update-secrets` renders it to `secrets.zsh` (gitignored), which `.zshrc` sources. Add new secrets to the template.

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
- `copy-dev-lite-llm-key` -- Copy the dev LiteLLM master key to the clipboard.
- `yt-transcript` -- Print a YouTube video's transcript.
