# Minimal environment for ALL shells (including non-interactive)
# Full config is in zsh.d/*.zsh (loaded via .zshrc for interactive shells)

# Cargo/Rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Essential CLI tools for scripts and non-interactive shells (Claude Code, cron, etc.)
export PATH="/Applications/Obsidian.app/Contents/MacOS:$PATH"
