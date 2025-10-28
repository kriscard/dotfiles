export ZSH=$DOTFILES/zsh

#################
# Configuration
#################

## PERSONAL CONFIG SECRET ##
source "$HOME/.dotfiles/work-config/config-secret-personal.zsh"

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


# config for TMUX
export TERM="xterm-ghostty"

# Set the path to include Homebrew binaries
export PATH=/opt/homebrew/bin:$PATH

# Set the path to DOTFILES folder
export DOTFILES="$HOME/.dotfiles"

# Set Nvim editor
export EDITOR=nvim
export GIT_EDITOR=nvim

# Using Starship instead of Oh My Zsh themes

# Lazy load autosuggestions and syntax highlighting for better performance
if [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Note: Using individual tools instead of Oh My Zsh for better performance
# Modern replacements: zoxide (for autojump), fnm (for node), starship (for prompt)

source "$HOME/.dotfiles/zsh/completions.zsh"
source "$HOME/.dotfiles/zsh/aliases.zsh"
source "$HOME/.dotfiles/zsh/functions.zsh"
# source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Set the default code editor to VS Code Insiders
export EDITOR=nvim
export NVIM_CONFIG="$HOME/.config/nvim/init.lua"

# Set the style for the zsh-autosuggestions plugin
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"

# Set default browser
export BROWSER=/usr/bin/arc

# Use autocompletion with tabs
bindkey '^I' autosuggest-accept

# Initialize Starship prompt (only if installed)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
fi

# # Rbenv
# eval "$(rbenv init - zsh)"
#
# pnpm
export PNPM_HOME="/Users/$USER/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
#
export PATH=$PATH:/Users/$USER/.spicetify

# GCC config
export PATH="/usr/local/bin:$PATH"

# Make config
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"

#PERSONAL CONFIG
if [[ $USER = 'kriscard' ]] || [[ $USER = 'christopher' ]]; then 
. /opt/homebrew/opt/asdf/libexec/asdf.sh
fi

export BAT_THEME=catppuccin_macchiatto

# # Initialize fnm (fast node manager) - only if installed
# if command -v fnm &> /dev/null; then
#     eval "$(fnm env --use-on-cd)"
# fi
#
# Load environment variables from dotfiles repo .env
if [ -f "$HOME/.dotfiles/.env" ]; then
  # Use set -a to auto-export, source to load silently, set +a to disable
  # This bypasses the grep→rg alias issue and produces no output
  set -a
  source <(/usr/bin/grep -v '^#' "$HOME/.dotfiles/.env" | /usr/bin/grep -v '^$')
  set +a
fi
