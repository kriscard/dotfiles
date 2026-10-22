# Minimal environment for ALL shells (including non-interactive)
# Full config is in zsh.d/*.zsh (loaded via .zshrc for interactive shells)

# Cargo/Rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Homebrew (Apple Silicon): avoid spawning brew for every child shell.
export HOMEBREW_PREFIX="/opt/homebrew"
path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" $path)

# asdf shims — must precede Homebrew so asdf-managed tool versions win
# in non-interactive shells (scripts, cron, child shells) as well as interactive ones
export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
[[ -d "$ASDF_DATA_DIR/shims" ]] && path=("$ASDF_DATA_DIR/shims" $path)

# Full config is in zsh.d/*.zsh (loaded via .zshrc for interactive shells)
