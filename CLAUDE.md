# Dotfiles

Personal dev environment managed with GNU Stow. Home-facing configs live in `home/`.

## Layout

- `home/`: single Stow package targeting `~`
- `home/.config/`: app configs (Stow targets `~/.config/`)
- `home/.claude/`: Claude Code subsystem
  - `hooks/`: PostToolUse hooks: `format.py` (prettierd auto-format), `ts_lint.py` (ESLint reporter), `notification.py`; `update-marketplace.sh` to sync plugin marketplace
  - `scripts/integrations/`: Python CLI wrappers (github, gmail, jira, calendar); shared Google OAuth in `lib/google_auth.py`; entry point `query.py`
  - `scripts/launchd/`: macOS scheduled job plists
- `home/bin/`: personal scripts on `PATH`
- `Brewfile`: managed via `dotfiles packages`

## Commands

```bash
dotfiles init            # Full environment setup
dotfiles packages        # Install Homebrew packages from Brewfile
dotfiles sync            # Sync config symlinks via Stow
dotfiles update          # Update dotfiles and packages
dotfiles doctor          # Health check, use to VERIFY any changes
dotfiles doctor --verbose
dotfiles backup          # Backup existing configs before changes
dotfiles ds_store        # Clean .DS_Store files
```

## Verification

After config changes, run `dotfiles doctor` to verify system health.
Test tmux changes: `tmux source-file ~/.config/tmux/tmux.conf`

## Key Variables

- `$DOTFILES`: path to this repo
- `$THEME_FLAVOUR`: Catppuccin variant (frappe/latte/macchiato/mocha); pre-set to `macchiato` in `home/zsh/zsh.d/00-env.zsh`. Override per-shell if needed.

## Secrets

- `.env` (gitignored, repo root): API keys, sourced by `home/zsh/zsh.d/80-integrations.zsh`
- `home/.claude/scripts/integrations/.tokens/` (gitignored): OAuth tokens (Google, etc.)
- Never commit either; pre-commit hook + global safety rules enforce this

## Plugin Marketplace

After adding or modifying plugins in `home/.claude/plugins/`:

```bash
bash home/.claude/hooks/update-marketplace.sh
```

## Gotchas

- Stow symlinks `home/.config/<app>/` to `~/.config/<app>/`; editing either side modifies the same file
- Neovim entry: `init.lua` loads `require("kriscard")`; don't rename without updating both
- `.stow-local-ignore` controls what Stow skips inside `home/`; repo files outside `home/` are never stowed
