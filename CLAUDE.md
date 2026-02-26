# Dotfiles

Personal dev environment managed with GNU Stow. Configs live in `.config/`.

## Commands

```bash
dotfiles init            # Full environment setup
dotfiles packages        # Install Homebrew packages from Brewfile
dotfiles sync            # Sync config symlinks via Stow
dotfiles update          # Update dotfiles and packages
dotfiles doctor          # Health check — use to VERIFY any changes
dotfiles doctor --verbose
dotfiles backup          # Backup existing configs before changes
dotfiles ds_store        # Clean .DS_Store files
```

## Verification

After config changes, run `dotfiles doctor` to verify system health.
Test tmux changes: `tmux source-file ~/.config/tmux/tmux.conf`

## Key Variables

- `$DOTFILES` — path to this repo
- `$THEME_FLAVOUR` — Catppuccin variant (frappe/latte/macchiato/mocha); must be set before launching themed apps

## Gotchas

- Stow symlinks `.config/<app>/` → `~/.config/<app>/` — editing either side modifies the same file
- Neovim entry: `init.lua` → `require("kriscard")` — don't rename without updating both
- `.stow-local-ignore` controls what Stow skips — check it before adding top-level files
