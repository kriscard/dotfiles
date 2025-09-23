# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a personal dotfiles repository that manages development environment configurations using a modern CLI approach. The main components are:

- **Configuration Management**: All configs stored in `.config/` directory with application-specific subdirectories
- **CLI Management System**: Modern `dotfiles` CLI tool with commands for installation, updates, diagnostics, and maintenance
- **Package Management**: Homebrew via `Brewfile` for consistent package installation across machines
- **Symlink Management**: GNU Stow integration for creating and managing configuration symlinks

## Key Configuration Areas

### Neovim (`.config/nvim/`)
- Modern Lua-based configuration using Lazy.nvim plugin manager
- Modular structure with plugins organized in `lua/plugins/` 
- Main config entry point: `init.lua` → `require("kriscard")`
- Plugin lock file: `lazy-lock.json` tracks exact plugin versions

### Tmux (`.config/tmux/`)
- Extensive plugin ecosystem via TPM (Tmux Plugin Manager)
- Custom theme using Catppuccin with multiple flavor support
- Key plugins: vim-tmux-navigator, tmux-sessionx, tmux-resurrect
- Configuration loads themes dynamically based on `$THEME_FLAVOUR` environment variable

### Window Management
- **Yabai** (`.config/yabai/`): Tiling window manager for macOS
- **SKHD** (`.config/skhd/`): Hotkey daemon for macOS window management
- **Karabiner** (`.config/karabiner/`): Keyboard customization

### Terminal Applications & Tools
- **Kitty/Ghostty**: Modern terminal emulator configurations with Catppuccin theming
- **Spicetify** (`.config/spicetify/`): Spotify theming
- **Lazygit** (`.config/lazygit/`): Git TUI configuration
- **Starship** (`.config/starship.toml`): Cross-shell prompt configuration
- **GH-Dash** (`.config/gh-dash/`): GitHub CLI dashboard for PRs and issues
- **Sketchybar** (`.config/sketchybar/`): macOS menu bar customization

## Common Development Commands

### Initial Setup
```bash
# Complete environment setup
dotfiles init

# Individual components
dotfiles packages        # Install Homebrew and packages from Brewfile
dotfiles sync           # Sync configuration files only
dotfiles macos          # Apply macOS system preferences
dotfiles backup         # Backup existing configs before installation

# Diagnostics and maintenance
dotfiles doctor         # Run system health check
dotfiles doctor --verbose  # Detailed diagnostics
dotfiles ds_store       # Clean .DS_Store files from dotfiles

# Update system
dotfiles update         # Update dotfiles and packages
```

### Tmux Management
```bash
# Reload tmux configuration
tmux source-file ~/.config/tmux/tmux.conf

# Install/update tmux plugins (from within tmux)
<prefix> + I  # Install plugins
<prefix> + U  # Update plugins
<prefix> + alt + u  # Uninstall plugins
```

### Neovim Plugin Management
```bash
# Lazy.nvim commands (within Neovim)
:Lazy          # Open plugin manager
:Lazy update   # Update all plugins
:Lazy sync     # Sync plugins to lazy-lock.json state
```

## Important Environment Variables
- `$DOTFILES`: Should point to this repository directory
- `$THEME_FLAVOUR`: Controls Catppuccin theme variant (frappe, latte, macchiato, mocha)

## Development Tools Available
- **Homebrew packages**: See `Brewfile` for complete list including neovim, tmux, fzf, ripgrep, bat, gh, etc.
- **Languages**: Python (pyenv), Ruby (rbenv), Node.js, PHP, Java
- **Development**: Docker, Android Studio, VS Code with extensive extensions
- **Modern CLI Tools**: eza (ls), bat (cat), fd (find), ripgrep (grep), zoxide (cd), fzf, jq, tldr, htop
- **Git Tools**: lazygit, gh (GitHub CLI), gh-dash (GitHub dashboard)
- **File Management**: Standard macOS Finder integration with shell navigation tools

## Configuration Patterns
- Configs use XDG Base Directory specification (`.config/` directory)
- Theme consistency across applications using Catppuccin color scheme
- Extensive use of fuzzy finding (fzf) integration
- Vim-style keybindings across terminal applications
- Plugin-based extensibility for major tools (Neovim, Tmux)