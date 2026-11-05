# Minimal environment for ALL shells (including non-interactive)
# Full config is in zsh.d/*.zsh (loaded via .zshrc for interactive shells)

# Cargo/Rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Homebrew (Apple Silicon): avoid spawning brew for every child shell.
export HOMEBREW_PREFIX="/opt/homebrew"
path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" $path)

# mise shims keep managed tools available to non-interactive shells and GUI apps.
export MISE_DATA_DIR="${MISE_DATA_DIR:-$HOME/.local/share/mise}"
[[ -d "$MISE_DATA_DIR/shims" ]] && path=("$MISE_DATA_DIR/shims" $path)

# Full config is in zsh.d/*.zsh (loaded via .zshrc for interactive shells)
