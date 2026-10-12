# 1Password Secrets Template
# Run `update-secrets` to generate secrets.zsh from this file.
# Format: export VAR_NAME="op: / / Vault / Item / Field"

export GITHUB_PERSONAL_ACCESS_TOKEN="op://Personal/GITHUB_PAT/credential"
export NODE_AUTH_TOKEN="op://Personal/GITHUB_PAT/credential"
export GITHUB_TOKEN="op://Personal/GITHUB_PAT/credential"

# Context7 MCP
export CONTEXT7_API_KEY="op://Personal/CONTEXT7_API_KEY/credential"

# ntfy push notifications (write-only to the 'agents' topic)
export NTFY_TOKEN="op://Personal/NTFY_TOKEN/credential"
