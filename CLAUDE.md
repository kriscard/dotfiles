# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a personal dotfiles repository that manages development environment configurations using a modular approach. The main components are:

- **Configuration Management**: All configs stored in `.config/` directory with application-specific subdirectories
- **Installation System**: Modular `install.sh` script with separate functions for different components
- **Package Management**: Homebrew via `Brewfile` for consistent package installation across machines
- **Symlink Management**: Uses GNU Stow for creating symlinks (referenced but not implemented in current install.sh)

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

### Terminal Applications
- **Kitty/Ghostty/Alacritty**: Multiple terminal emulator configs
- **Spicetify** (`.config/spicetify/`): Spotify theming
- **Lazygit** (`.config/lazygit/`): Git TUI configuration

## Common Development Commands

### Initial Setup
```bash
# Complete environment setup
./install.sh all

# Individual components
./install.sh homebrew    # Install Homebrew and packages from Brewfile
./install.sh shell       # Configure zsh as default shell
./install.sh git         # Interactive git configuration setup
./install.sh terminfo    # Install custom terminal info files
./install.sh macos       # Apply macOS system preferences
./install.sh catppuccin  # Download Catppuccin theme variants
./install.sh backup      # Backup existing configs before installation
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
- **CLI Tools**: fd, bat, ripgrep, fzf, jq, tldr, htop, autojump

## Configuration Patterns
- Configs use XDG Base Directory specification (`.config/` directory)
- Theme consistency across applications using Catppuccin color scheme
- Extensive use of fuzzy finding (fzf) integration
- Vim-style keybindings across terminal applications
- Plugin-based extensibility for major tools (Neovim, Tmux)