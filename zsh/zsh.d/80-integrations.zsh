# External Tool Integrations

# direnv - auto-load .envrc files per directory
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# Load environment from .env file (if exists)
if [[ -f "$DOTFILES/.env" ]]; then
  set -a
  source <(/usr/bin/grep -v '^#' "$DOTFILES/.env" | /usr/bin/grep -v '^$')
  set +a
fi

# Claude Code - auto-update plugin marketplace on shell start
if (( $+commands[claude] )); then
  claude plugin marketplace update kriscard/kriscard-claude-plugins &>/dev/null &
fi
