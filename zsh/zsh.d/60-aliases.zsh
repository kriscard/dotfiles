# Aliases

# Reload zsh config
alias reload!='RELOAD=1 source ~/.zshrc'

# AI and dotfiles
# Use claude-work for profile switching at work, plain claude at home
if [[ "$CLAUDE_ENV" == "work" ]]; then
  alias ai="claude-work"
else
  alias ai="claude"
fi
alias df-cli="$DOTFILES/dotfiles"

# Claude Code with environment-aware settings
# Usage: cw (claude work), ch (claude home), or just 'ai' with CLAUDE_ENV set
alias cw='CLAUDE_ENV=work claude-work'   # Force work profile (token-optimized)
alias ch='CLAUDE_ENV=home claude-work'   # Force home profile (full features)
alias claude-profile='echo "Current: ${CLAUDE_ENV:-home}"'  # Show active profile

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias root_level='cd $(git rev-parse --show-toplevel)'
alias root='~'

# Modern command replacements (eza, bat, fd, rg)
alias ls="eza --icons=always"
alias lls="eza --icons --git --long"
alias lt="eza --icons --git --tree"
alias la="eza --icons --git --all"
alias l='eza -l --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias cat="bat"
alias find="fd"
alias grep="rg"

# Disk usage
alias df='df -h'
alias du='du -h -c'
alias lpath='echo $PATH | tr ":" "\n"'

# macOS specific
alias ios='open -a /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
alias cleanup="fd -H '.DS_Store' -t f -x rm {}"
alias clsym="find -L . -name . -o -type d -prune -o -type l -exec rm {} +"

# Git
alias ggl="git pull"
alias ggp="git push"
alias gst="git status"
alias gd="git diff"
alias gc="git commit"
alias ga="git add"
alias gco="git checkout"
alias gb="git branch"
alias gf="git fetch"
alias gsu='git submodule update --init --recursive'
alias delete_all_branch='git branch | grep -v "master" | grep -v "main" | grep -v "dev" | grep -v "staging" | grep -v "production" | xargs git branch -D'

# Stow
alias unstow="stow -D ."
alias addstow="stow ."

# Neovim
alias v='nvim'

# tmux
alias ta='tmux attach'
alias tls='tmux ls'
alias tat='tmux attach -t'
alias td='tmux detach'
alias tns='tmux new-session -s'
alias tks='tmux kill-session -t'
alias tk='tmux kill-server'
alias tx='tmuxinator'

# Misc
alias K='clear'
alias rmf="rm -rf"

# zoxide
alias zi="zi"
alias ccd="cd"

# Lazy tools
alias lzd='lazydocker'
alias lzg='lazygit'

# fzf previews
alias preview="fzf --preview 'bat --color=always {}'"
alias pf="fzf --preview 'bat --color=always {}'"

# Obsidian CLI
obsread() { obsidian read path="$*" }
obssearch() { obsidian search query="$*" | head -20 | tail -n +2 }
obsnew() { obsidian create path="0 - Inbox/$1.md" content="# $1" silent && echo "Created: 0 - Inbox/$1.md" }
obstoday() { obsidian append path="2 - Areas/Daily Ops/$(date +%Y-%m-%d).md" content="- $*" silent }
obsopen() { obsidian open path="$*" }
obsweekly() { obsidian open path="2 - Areas/Daily Ops/Weekly/$(date +%Y)-W$(date +%V).md" }
obsyesterday() { obsidian open path="2 - Areas/Daily Ops/$(date -v-1d +%Y-%m-%d).md" }

# Node version management (via asdf)
alias node-use="asdf shell nodejs"
alias node-list="asdf list nodejs"
alias node-install="asdf install nodejs"
