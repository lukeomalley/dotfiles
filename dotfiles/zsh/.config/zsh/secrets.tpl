# 1Password Secrets Template
# Run `update-secrets` to generate secrets.zsh from this file.
# Format: export VAR_NAME="op: / / Vault / Item / Field"

# npm auth for @procurement-sciences packages on GitHub Packages. GitHub itself
# (git and gh) uses the gh CLI login, not a token in the environment.
export NODE_AUTH_TOKEN="op://Personal/GITHUB_PAT/credential"

# Context7 MCP
export CONTEXT7_API_KEY="op://Personal/CONTEXT7_API_KEY/credential"

# ntfy push notifications (write-only to the 'agents' topic)
export NTFY_TOKEN="op://Personal/NTFY_TOKEN/credential"
