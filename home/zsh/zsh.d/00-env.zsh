# Environment Variables and PATH
# Consolidated from multiple locations for clarity and performance

# Homebrew (hardcoded for Apple Silicon - avoids slow $(brew --prefix))
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# Dotfiles
export DOTFILES="$HOME/.dotfiles"

# PATH configuration (ordered by priority, first = highest)
# mise shims keep managed tools ahead of Homebrew in shells that do not run
# interactive activation, such as scripts and GUI-launched processes.
path=(
  "${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims"
  "$HOME/bin"
  "$HOME/.local/bin"
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
export BROWSER='open -a "Google Chrome"'
export PLANNOTATOR_BROWSER="Google Chrome"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
