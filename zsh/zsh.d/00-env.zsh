# Environment Variables and PATH
# Consolidated from multiple locations for clarity and performance

# Homebrew (hardcoded for Apple Silicon - avoids slow $(brew --prefix))
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# Dotfiles
export DOTFILES="$HOME/.dotfiles"
export ZSH="$DOTFILES/zsh"

# PATH configuration (ordered by priority, first = highest)
path=(
  "$HOME/.local/bin"
  "$HOME/.dotfiles/bin"
  "$HOME/.config/bin"
  "/usr/local/opt/make/libexec/gnubin"
  "/usr/local/bin"
  "$HOME/Library/pnpm"
  "$HOME/.spicetify"
  "/Applications/Obsidian.app/Contents/MacOS"
  $path
)

# Remove duplicates while preserving order
typeset -U path
export PATH

# Editors
export EDITOR=nvim
export GIT_EDITOR=nvim
export NVIM_CONFIG="$HOME/.config/nvim/init.lua"

# Terminal
export TERM="xterm-ghostty"

# Theme
export THEME_FLAVOUR=macchiato
export BAT_THEME=catppuccin_macchiato

# Browser
export BROWSER=/usr/bin/arc

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
