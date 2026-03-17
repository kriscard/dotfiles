# Minimal environment for ALL shells (including non-interactive)
# Full config is in zsh.d/*.zsh (loaded via .zshrc for interactive shells)

# Cargo/Rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Full config is in zsh.d/*.zsh (loaded via .zshrc for interactive shells)
