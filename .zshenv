# Minimal environment for ALL shells (including non-interactive)
# Full config is in zsh.d/*.zsh (loaded via .zshrc for interactive shells)

# Cargo/Rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# asdf shims — must precede Homebrew so asdf-managed tool versions win
# in non-interactive shells (scripts, cron, child shells) as well as interactive ones
if [[ -d "/opt/homebrew/opt/asdf/libexec" ]]; then
  export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
  [[ -d "$ASDF_DATA_DIR/shims" ]] && path=("$ASDF_DATA_DIR/shims" $path)
fi

# Full config is in zsh.d/*.zsh (loaded via .zshrc for interactive shells)
