# Security Policy

## Reporting a Vulnerability

If you discover a security issue in these dotfiles (e.g., accidentally committed secrets, insecure script patterns), please:

1. **Open an issue** on this repository, or
2. **Contact me directly** via GitHub

## Secret Management

This repository follows a strict separation between configuration and secrets:

| File | Purpose | Committed |
|------|---------|-----------|
| `.env.example` | Documents required environment variables | Yes |
| `.env` | Contains actual API keys and tokens | **No** |
| `*-secret-*.zsh` | Machine-specific secret configs | **No** |

### Required Secrets

See `.env.example` for the full list of environment variables needed:

- `GITHUB_PERSONAL_ACCESS_TOKEN` - GitHub API access
- `CONTEXT7_API_KEY` - Library documentation MCP server
- `OBSIDIAN_API_KEY` - Local Obsidian REST API
- `NTFY_TOPIC` - Push notification topic

### Setting Up Secrets

```bash
# Copy the example file
cp .env.example .env

# Edit with your actual values
$EDITOR .env
```

## What's Excluded

The `.gitignore` excludes:

- **Environment files**: `.env`, `.env.local`
- **Application state**: Session files, history, caches
- **Machine-specific configs**: Work configurations, local overrides
- **Sensitive app data**: GitHub CLI tokens, 1Password configs, Raycast data

## Security Practices

- All secrets loaded via environment variables, never hardcoded
- Git hooks and push protection prevent accidental secret commits
- Sensitive directories explicitly ignored in `.gitignore`
