# Set the path to include Homebrew binaries
export PATH=/opt/homebrew/bin:$PATH

# Set the path to the Oh My Zsh installation directory
export ZSH="$HOME/.oh-my-zsh"

# Set the default Oh My Zsh theme
ZSH_THEME="robbyrussell"

# Specify which plugins to load for Oh My Zsh
plugins=(git autojump zsh-syntax-highlighting node vscode npm yarn zsh-autosuggestions web-search)

source "$HOME/aliases.zsh"
source "$HOME/functions.zsh"

# Load the Oh My Zsh framework
source $ZSH/oh-my-zsh.sh

# Set the default code editor to VS Code Insiders
export EDITOR=nvim
export NVIM_CONFIG="$HOME/.config/nvim/init.lua"

# Set the style for the zsh-autosuggestions plugin
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"

# Enable the colorls plugin
source $(dirname $(gem which colorls))/tab_complete.sh

# Load the VS Code plugin for Zsh
source ~/.zsh/vscode/vscode.plugin.zsh

# Shell Startship
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
