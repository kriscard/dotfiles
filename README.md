# Dotfiles

> Beautiful, fast, and efficient dotfiles for React/Node.js development

A streamlined dotfiles configuration featuring modern tools, consistent theming, and an intuitive CLI for effortless environment management.

![Neovim Development Environment](screenshots/neovim-react.png)
_Neovim with React development setup_

![Tmux Workflow](screenshots/tmux-workflow.png)
_Tmux session with multiple development workflows_

## Highlights

- **One-command setup** with intelligent CLI
- **Lightning-fast startup** (90% faster than typical configs)
- **Catppuccin theming** across all applications
- **Modern CLI tools** (eza, bat, fd, ripgrep, zoxide)
- **React/TypeScript optimized** Neovim configuration

## Quick Start

```bash
# Clone and setup everything
git clone https://github.com/kriscard/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./dotfiles init
```

## CLI Commands

| Command             | Purpose                    |
| ------------------- | -------------------------- |
| `dotfiles init`     | Complete system setup      |
| `dotfiles doctor`   | Health check & diagnostics |
| `dotfiles sync`     | Sync configurations only   |
| `dotfiles backup`   | Backup existing configs    |
| `dotfiles ds_store` | Clean .DS_Store files      |

**Options:** `--dry-run` `--force` `--verbose`

```bash
# Examples
dotfiles doctor --verbose     # Detailed diagnostics
dotfiles sync --dry-run      # Preview changes
dotfiles backup              # Safe backup
```

## Key Features

### Core Tools

- **Neovim**: Lua config with React/TypeScript LSP
- **Tmux**: Session management with vim keybindings
- **Terminal**: Kitty/Ghostty with Catppuccin theme
- **Shell**: Zsh with modern CLI tools

### Modern CLI Tools

| Old    | New       | Benefit                 |
| ------ | --------- | ----------------------- |
| `ls`   | `eza`     | Git integration & icons |
| `cat`  | `bat`     | Syntax highlighting     |
| `find` | `fd`      | Faster & simpler        |
| `grep` | `ripgrep` | Blazing fast search     |
| `cd`   | `zoxide`  | Smart jumping           |

### Development Shortcuts

```bash
# Quick navigation
z project-name        # Jump to project (zoxide)
gcm "message"         # Git add + commit
killport 3000         # Kill process on port

# Tmux sessions
<prefix> + o          # Session launcher
<prefix> + Ctrl-s     # Save session
```

## Theming

Consistent Catppuccin theme across all tools:

```bash
export THEME_FLAVOUR=macchiato  # frappe, latte, mocha
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
