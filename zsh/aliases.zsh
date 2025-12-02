# reload zsh confihhhh
alias reload!='RELOAD=1 source ~/.zshrc'

# AI and dotfiles management
alias ai="claude"
alias df-cli="~/.dotfiles/dotfiles"  # Dotfiles CLI shortcut

# Filesystem aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Helpers
alias grep='grep --color=auto'
alias df='df -h' # disk free, in Gigabytes, not bytes
alias du='du -h -c' # calculate disk usage for a folder

alias lpath='echo $PATH | tr ":" "\n"' # list the PATH separated by new lines

# Applications
alias ios='open -a /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Recursively delete `.DS_Store` files
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"
# remove broken symlinks
alias clsym="find -L . -name . -o -type d -prune -o -type l -exec rm {} +"

# Delete merged branches
alias delete_all_branch='git branch | grep -v "master" | grep -v "main" | grep -v "dev" | grep -v "staging" | grep -v "production" | xargs git branch -D'

# Update git submodules
alias gsu='git submodule update --init --recursive'

#git aliases
alias ggl="git pull"
alias ggp="git push"
alias gst="git status"
alias gd="git diff"
alias gc="git commit"
alias ga="git add"
alias gco="git checkout"
alias gb="git branch"
alias gf="git fetch"

# Upate Stow symlink
alias unstow="stow -D ." # Unstow
alias addstow="stow ." # Add stow

alias rmf="rm -rf"

# Define aliases for various Git and directory-related tasks
alias root_level='cd $(git rev-parse --show-toplevel)'
alias root='~'
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

# Define an alias for nvim
alias v='nvim'

# tmux aliases
alias ta='tmux attach'
alias tls='tmux ls'
alias tat='tmux attach -t'
alias td='tmux detach'
alias tns='tmux new-session -s'
alias tks='tmux kill-session -t'
alias tk='tmux kill-server'
alias tx='tmuxinator'

# clear terminal
alias K='clear'


# Modern command replacements
alias ls="eza --icons=always"
alias lls="eza --icons --git --long"
alias lt="eza --icons --git --tree"
alias la="eza --icons --git --all"
alias l='eza -l --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'

# Note: zoxide is initialized in completions.zsh and automatically replaces cd
alias zi="zi"  # Interactive zoxide
alias ccd="cd"  # Traditional cd with path completion for exploring new directories

# Lazydocker alias 
alias lzd='lazydocker'

# alias for lazygit
alias lzg='lazygit'

# Modern tool aliases
alias cat="bat"           # Better cat with syntax highlighting
alias find="fd"           # Better find
alias grep="rg"           # Better grep

# fzf previews
alias preview="fzf --preview 'bat --color=always {}'"
alias pf="fzf --preview 'bat --color=always {}'"  # Shorter version

# Node version management with fnm
alias node-use="fnm use"
alias node-list="fnm list"
alias node-install="fnm install"
