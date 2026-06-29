# External Tool Integrations
# Note: direnv is now cached in 40-lazy.zsh for faster startup

# Load environment from .env file (if exists)
if [[ -f "$DOTFILES/.env" ]]; then
  set -a
  source <(/usr/bin/grep -v '^#' "$DOTFILES/.env" | /usr/bin/grep -v '^$')
  set +a
fi
