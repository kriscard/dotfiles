export ZSH=$DOTFILES/zsh

#################
# Configuration
#################

# define the code directory
# This is where my code exists and where I want the `c` autocomplete to work from exclusively
if [[ -d ~/code ]]; then
    export CODE_DIR=~/code
elif [[ -d ~/Developer ]]; then
    export CODE_DIR=~/Developer
elif [[ -d ~/Northone ]]; then
    export CODE_DIR=~/Northone
elif [[ -d ~/Projects ]]; then
    export CODE_DIR=~/Projects
fi

# display how long all tasks over 10 seconds take
export REPORTTIME=10
export KEYTIMEOUT=1              # 10ms delay for key sequences
export THEME_FLAVOUR=macchiato

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY          # write the history file in the ":start:elapsed;command" format.
setopt HIST_REDUCE_BLANKS        # remove superfluous blanks before recording entry.
setopt SHARE_HISTORY             # share history between all sessions.
setopt HIST_IGNORE_ALL_DUPS      # delete old recorded entry if new entry is a duplicate.

# Set the path to include Homebrew binaries
export PATH=/opt/homebrew/bin:$PATH

# Set the path to the Oh My Zsh installation directory
export ZSH="$HOME/.oh-my-zsh"

# Set the path to DOTFILES folder
export DOTFILES="$HOME/.dotfiles"

# Set Nvim editor
export EDITOR=nvim
export GIT_EDITOR=nvim

# Set the default Oh My Zsh theme
ZSH_THEME="robbyrussell"

# Specify which plugins to load for Oh My Zsh
plugins=(git autojump zsh-syntax-highlighting node vscode npm yarn zsh-autosuggestions web-search)

source "$HOME/zsh/aliases.zsh"
source "$HOME/zsh/functions.zsh"

# Load the Oh My Zsh framework
source $ZSH/oh-my-zsh.sh

# Set the default code editor to VS Code Insiders
export EDITOR=nvim
export NVIM_CONFIG="$HOME/.config/nvim/init.lua"

# Set the style for the zsh-autosuggestions plugin
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"

# Enable the colorls plugin
source $(dirname $(gem which colorls))/tab_complete.sh

# Set default browser
export BROWSER=/usr/bin/brave-browser

# Load the VS Code plugin for Zsh
source ~/.zsh/vscode/vscode.plugin.zsh

# Shell Startship
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

# Rbenv
eval "$(rbenv init - zsh)"

# pnpm
export PNPM_HOME="/Users/kriscard/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH=$PATH:/Users/kriscard/.spicetify
