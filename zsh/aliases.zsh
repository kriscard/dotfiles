# reload zsh config
alias reload!='RELOAD=1 source ~/.zshrc'

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
alias delete_all_branch='git branch | grep -v "master" | grep -v "main" | grep -v "dev" | grep -v "production" | xargs git branch -D'

# use exa if available
if [[ -x "$(command -v exa)" ]]; then
  alias ll="exa --icons --git --long"
  alias l="exa --icons --git --all --long"
else
  alias l="ls -lah ${colorflag}"
  alias ll="ls -lFh ${colorflag}"
fi

alias lls="colorls"
alias lla="colorls -a"
alias lld="colors -l | grep ^d"
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
alias tns='tmux new-session -s'
alias tks='tmux kill-session -t'
alias tk='tmux kill-server'
alias tx='tmuxinator'

# clear terminal
alias K='clear'
