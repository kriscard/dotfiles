# Modern Brewfile - Optimized for Web Development
# Organized by category for better maintainability

# Homebrew Taps
tap "fsouza/prettierd"
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/cask-fonts"
tap "homebrew/services"
tap "koekeishiya/formulae"
tap "ngrok/ngrok"

# =============================================================================
# CORE SYSTEM TOOLS
# =============================================================================

# Essential CLI tools
brew "git"
brew "curl"
brew "wget"
brew "jq"
brew "htop"
brew "tldr"

# Modern command line tools (replacements for traditional tools)
brew "bat"          # Better cat
brew "eza"          # Modern ls replacement (instead of exa)
brew "fd"           # Better find
brew "ripgrep"      # Better grep
brew "fzf"          # Fuzzy finder
brew "zoxide"       # Smart cd command
brew "stow"         # Symlink management

# =============================================================================
# TERMINAL & SHELL
# =============================================================================

brew "tmux"
brew "starship"     # Fast shell prompt
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# =============================================================================
# DEVELOPMENT TOOLS
# =============================================================================

# Text Editor
brew "neovim"
brew "lua-language-server"

# Version Managers (modern alternatives)
brew "fnm"          # Fast Node Manager (better than nvm)
brew "pyenv"        # Python version management
brew "rbenv"        # Ruby version management

# Databases
brew "redis"
brew "libpq"        # PostgreSQL client

# Build Tools
brew "watchman"     # File watching

# Code Quality & Formatting
brew "fsouza/prettierd/prettierd"

# =============================================================================
# WEB DEVELOPMENT SPECIFIC
# =============================================================================

# Currently commented out - uncomment if needed
# brew "php"

# =============================================================================
# MACOS TOOLS
# =============================================================================

# Window Management
brew "koekeishiya/formulae/skhd"
brew "koekeishiya/formulae/yabai"

# =============================================================================
# GUI APPLICATIONS
# =============================================================================

# Terminals (keeping both as requested)
cask "kitty"
cask "ghostty"

# Development Tools
cask "docker"
cask "visual-studio-code"

# Development Mobile
cask "android-studio"
cask "android-commandlinetools"
cask "react-native-debugger"

# Databases
cask "popsql"
cask "postico"

# Fonts
cask "font-hack-nerd-font"
cask "font-fira-code-nerd-font"

# Productivity
cask "notion"
cask "todoist"
cask "discord"

# Utilities
cask "ngrok"

# Java (if needed for Android development)
cask "zulu11"

# =============================================================================
# VS CODE EXTENSIONS (Essential Only)
# =============================================================================

# Core Extensions
vscode "GitHub.copilot"
vscode "GitHub.copilot-labs"
vscode "esbenp.prettier-vscode"
vscode "dbaeumer.vscode-eslint"

# React/TypeScript Development
vscode "bradlc.vscode-tailwindcss"
vscode "dsznajder.es7-react-js-snippets"

# Theme & Icons
vscode "Catppuccin.catppuccin-vsc"
vscode "Catppuccin.catppuccin-vsc-icons"

# Git Integration
vscode "eamodio.gitlens"

# Utility Extensions
vscode "asvetliakov.vscode-neovim"
vscode "christian-kohler.npm-intellisense"
vscode "christian-kohler.path-intellisense"
vscode "formulahendry.auto-rename-tag"

# =============================================================================
# REMOVED PACKAGES (redundant or outdated)
# =============================================================================

# Removed:
# - autojump (replaced with zoxide)
# - python@3.10, python@3.11 (use pyenv instead)
# - awscli (install only when needed)
# - bluetoothconnector (rarely used)
# - bundletool (Android-specific, install when needed)
# - circleci (project-specific)
# - openldap, freetds, folly, etc. (rarely used dependencies)
# - gnupg (install when needed for security)
# - xclip (Linux tool, not needed on macOS)
# - romkatv/powerlevel10k (using starship instead)
# - Multiple VSCode extensions (keeping only essential ones)

# Note: If you need any of the removed packages, uncomment them above
# or install them individually with: brew install package-name