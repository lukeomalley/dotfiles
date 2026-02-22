# 1Password Secrets Template
# Run `update-secrets` to generate secrets.zsh from this file.
# Format: export VAR_NAME="op: / / Vault / Item / Field"

# Various LLM Providers
export GEMINI_API_KEY="op://Personal/GEMINI_API_KEY/credential"
export ANTHROPIC_API_KEY="op://Personal/ANTHROPIC_API_KEY/credential"
export OPENAI_API_KEY="op://Personal/OPENAI_API_KEY/credential"
export GITHUB_PERSONAL_ACCESS_TOKEN="op://Personal/GITHUB_PAT/credential"
export NODE_AUTH_TOKEN="op://Personal/GITHUB_PAT/credential"

# BigQuery MCP Server Configuration
export BIGQUERY_PROJECT="op://Personal/BIGQUERY_PROJECT/credential"
export BIGQUERY_LOCATION="op://Personal/BIGQUERY_LOCATION/credential"
export BIGQUERY_KEY_FILE="op://Personal/BIGQUERY_KEY_FILE/credential"

# Fireflies AI Meeting Notes
export FIREFLIES_API_KEY="op://Personal/FIREFLIES_API_KEY/credential"

# Context7 MCP
export CONTEXT7_API_KEY="op://Personal/CONTEXT7_API_KEY/credential"
