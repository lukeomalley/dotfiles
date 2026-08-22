# Dotfiles repository guidance

This is one cross-platform GNU Stow repository:

- macOS: `stow/common` + `stow/darwin` + optional `stow/hosts/<hostname>`.
- Omarchy: `stow/common` + `stow/omarchy` + optional host layer.
- Every immediate child of a layer is a separate Stow package.

Always retain `stow -R --no-folding`. Never stow a whole profile as one package,
use `stow --adopt` during migration, or place runtime state in a package. A real
target conflict must be backed up and reconciled explicitly with
`scripts/adopt-existing` before deployment.

Portable configuration belongs in `common`; platform integrations and absolute
platform paths belong in `darwin` or `omarchy`; machine-specific display and
hardware configuration belongs in `hosts/<hostname>`. Prefer shared base files
with platform includes for Zsh, Git, and SSH.

Never edit `/usr/share/omarchy`; it is read-only packaged reference material.
Track only intentional user overrides under `stow/omarchy`. Files destined for
`/etc` live as source under `system/` and require an explicit installation step.

Package installation, Stow deployment, system configuration, login-shell
changes, and secrets generation are distinct operations. Bootstrap must remain
idempotent. Dry-run must not mutate the machine. Never implicitly upgrade the
whole system.

Secrets are generated from 1Password templates. Never commit credentials,
private keys, generated `secrets.zsh`, backup files, caches, histories, or other
runtime data. Public SSH keys are intentional.

Before committing changes:

1. Run `bash -n scripts/* tests/*`.
2. Run ShellCheck when installed.
3. Run `tests/profile-layout.sh`.
4. Search `stow/common` for platform-only paths and commands.
5. Review staged and unstaged diffs for secrets and backup/runtime files.
6. Validate real app behavior separately on each host.

Do not modify live `~/.config`, `/etc`, services, or the login shell unless a
user explicitly requests deployment after reviewing the migration.
