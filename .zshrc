export ZSH=$DOTFILES/zsh

#################
# Configuration
#################

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
plugins=(git autojump npm zsh-syntax-highlighting zsh-autosuggestions)

source "$HOME/zsh/aliases.zsh"
source "$HOME/zsh/functions.zsh"

# Load the Oh My Zsh framework
source $ZSH/oh-my-zsh.sh

# Set the default code editor to VS Code Insiders
export EDITOR=nvim
export NVIM_CONFIG="$HOME/.config/nvim/init.lua"

# Set the style for the zsh-autosuggestions plugin
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"

# Set default browser
export BROWSER=/usr/bin/arc

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
#
export PATH=$PATH:/Users/kriscard/.spicetify

# GCC config
export PATH="/usr/local/bin:$PATH"

# Make config
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"

#PERSONAL CONFIG
if [[ $USER = 'kriscard' ]]; then 
. /opt/homebrew/opt/asdf/libexec/asdf.sh
fi

## WORK CONFIG ##
if [[ $USER = 'chriscardoso' ]]; then
  ### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
  export PATH="/Users/chriscardoso/.rd/bin:$PATH"
  ### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
  
  source "$HOME/.dotfiles/work-config/config.zsh"
fi
