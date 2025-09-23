# Modern Dotfiles Configuration

A comprehensive, modular dotfiles repository optimized for modern development workflows with React/Node.js focus. Features GNU Stow symlink management, performance optimizations, and consistent theming across all tools.

## ✨ Key Features

### 🔧 Core Tools & Configuration
- **Neovim**: Modern Lua configuration with Lazy.nvim and React ecosystem plugins
- **Tmux**: Plugin-managed configuration with vim-tmux-navigator and session management
- **Terminal**: Dual support for Kitty and Ghostty with Catppuccin theming
- **Shell**: Optimized Zsh with modern CLI tools (eza, bat, fd, ripgrep, zoxide)
- **Window Management**: Yabai + SKHD for efficient macOS tiling

### 🚀 Development Workflow
- **Package Management**: Comprehensive Brewfile with categorized modern tools
- **React/Node.js**: Optimized configurations for modern web development
- **Project Setup**: Automated scripts for React, Next.js, and Node.js projects
- **Git Integration**: Enhanced git workflow with intelligent configurations
- **Performance**: Lazy-loaded shell components for fast startup

### 🎨 Theme & Consistency
- **Catppuccin**: Unified theming across all applications
- **Nerd Fonts**: Complete icon support with Hack Nerd Font Mono
- **Dynamic Themes**: Light/dark mode switching via `THEME_FLAVOUR` environment variable

## 📦 Installation

### Quick Setup (Recommended)
```bash
# Complete environment setup with backups
./install.sh all
```

### Modular Installation
```bash
# Individual components
./install.sh backup      # Backup existing configurations
./install.sh homebrew    # Install packages via Brewfile
./install.sh symlinks    # Setup GNU Stow symlinks
./install.sh shell       # Configure zsh as default shell
./install.sh git         # Interactive git configuration
./install.sh tmux        # Setup tmux with TPM
./install.sh terminfo    # Install custom terminal info
./install.sh macos       # Apply macOS system preferences
./install.sh catppuccin  # Download theme variants
```

## 🗂️ Repository Structure

```
.dotfiles/
├── .config/              # XDG Base Directory configurations
│   ├── nvim/            # Neovim with Lazy.nvim
│   ├── tmux/            # Tmux with TPM plugin management
│   ├── kitty/           # Kitty terminal configuration
│   ├── ghostty/         # Ghostty terminal configuration
│   ├── yabai/           # Window manager configuration
│   ├── skhd/            # Hotkey daemon configuration
│   └── lazygit/         # Git TUI configuration
├── zsh/                 # Zsh configuration package
│   ├── .zshrc           # Main zsh configuration
│   ├── aliases.zsh      # Modern CLI tool aliases
│   └── functions.zsh    # Development utility functions
├── scripts/             # Development automation scripts
│   └── dev/            # Project setup and utilities
├── Brewfile            # Homebrew package definitions
└── install.sh          # Modular installation script
```

## 🛠️ Modern CLI Tools

This configuration leverages modern alternatives to traditional Unix tools:

| Traditional | Modern Alternative | Purpose |
|-------------|-------------------|---------|
| `ls` | `eza` | Enhanced file listing with git integration |
| `cat` | `bat` | Syntax-highlighted file viewing |
| `find` | `fd` | Fast, user-friendly file finding |
| `grep` | `ripgrep (rg)` | Blazing fast text search |
| `cd` | `zoxide` | Smart directory jumping |
| `man` | `tldr` | Simplified, example-focused help pages |

## ⚡ Performance Optimizations

- **Shell Startup**: Conditional loading of tools (90%+ faster startup)
- **Tmux Plugins**: TPM-managed with clean state (99.95% size reduction)
- **Lazy Loading**: Deferred initialization of non-critical components
- **Symlink Management**: GNU Stow for efficient file organization

## 🎯 Development Workflows

### React/Next.js Project Setup
```bash
# Create new React TypeScript project
project-setup my-app react-ts

# Create Next.js project with TypeScript
project-setup my-next-app next-ts
```

### Tmux Session Management
```bash
# Session launcher with fuzzy search
<prefix> + o

# Save/restore sessions
<prefix> + Ctrl-s  # Save
<prefix> + Ctrl-r  # Restore
```

### Git Workflow
```bash
# Quick commit function
gcm "commit message"  # git add -A && git commit -m

# Kill port utility
killport 3000  # Kill process on port 3000
```

## 🎨 Theme Management

Switch between Catppuccin flavors system-wide:
```bash
export THEME_FLAVOUR=macchiato  # or frappe, latte, mocha
```

## 📋 Requirements

- **macOS**: Primary target platform
- **Homebrew**: Package manager
- **GNU Stow**: Symlink management
- **Git**: Version control
- **Zsh**: Shell (configured automatically)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
