# External Tool Integrations

# direnv - auto-load .envrc files per directory
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# Load secrets from work config (if exists)
[[ -f "$DOTFILES/work-config/config-secret-personal.zsh" ]] && \
  source "$DOTFILES/work-config/config-secret-personal.zsh"

# Load environment from .env file (if exists)
if [[ -f "$DOTFILES/.env" ]]; then
  set -a
  source <(/usr/bin/grep -v '^#' "$DOTFILES/.env" | /usr/bin/grep -v '^$')
  set +a
fi
