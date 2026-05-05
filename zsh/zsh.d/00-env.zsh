# Environment Variables and PATH
# Consolidated from multiple locations for clarity and performance

# Homebrew (hardcoded for Apple Silicon - avoids slow $(brew --prefix))
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# Dotfiles
export DOTFILES="$HOME/.dotfiles"

# PATH configuration (ordered by priority, first = highest)
# asdf shims must precede Homebrew so asdf-managed tool versions (node, npm,
# pnpm, ...) win over Homebrew-installed copies of the same binaries.
path=(
  "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
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

# Theme
export THEME_FLAVOUR=macchiato
export BAT_THEME="Catppuccin Macchiato"

# Browser
export BROWSER="open -a Arc"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
