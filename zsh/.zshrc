# ZSH Configuration Entry Point
# Modular configuration in zsh.d/

export ZDOTDIR="${ZDOTDIR:-$HOME}"
export ZSH="$HOME/.dotfiles/zsh"

# Source all configuration files in order (00-env, 10-options, etc.)
for config_file in "$ZSH/zsh.d"/*.zsh(N); do
  source "$config_file"
done
unset config_file
