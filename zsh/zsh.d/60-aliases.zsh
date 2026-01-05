# Aliases

# Reload zsh config
alias reload!='RELOAD=1 source ~/.zshrc'

# AI and dotfiles
alias ai="claude"
alias df-cli="$DOTFILES/dotfiles"

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

# Node version management
alias node-use="fnm use"
alias node-list="fnm list"
alias node-install="fnm install"
