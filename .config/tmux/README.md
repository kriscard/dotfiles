# Tmux Configuration

Modern tmux setup with plugin management via TPM.

## Setup

1. Install tmux plugins: `./install.sh tmux`
2. Or manually:
   - Start tmux: `tmux`
   - Install plugins: `prefix + I` (default: `Ctrl-a + I`)

## Key Bindings

- **Prefix**: `Ctrl-a`
- **SessionX**: `prefix + e` - Fuzzy session manager
- **Lazygit**: `prefix + g` - Open lazygit in new window
- **Copy mode**: `Escape` or `prefix + [`

## Plugins

- **TPM**: Plugin manager
- **SessionX**: Fuzzy session manager with tmuxinator support
- **Vim-tmux-navigator**: Seamless navigation between vim and tmux
- **Tmux-resurrect**: Save and restore tmux sessions
- **Catppuccin**: Beautiful theme
- **FZF integrations**: URL opener and general fuzzy finding
- **Tmux-yank**: Better copy/paste

## Theme

Uses Catppuccin theme with dynamic flavor support via `$THEME_FLAVOUR` environment variable.

## Plugin Management

- **Install**: `prefix + I`
- **Update**: `prefix + U`
- **Remove**: `prefix + alt + u`