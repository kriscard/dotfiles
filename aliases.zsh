# Define an alias to reload the .zshrc file
alias reload='source ~/.zshrc'

# Define aliases for the colorls plugin
alias lc='colorls -lA --sd'
alias ls='colorls --sd'

# Define aliases for various Git and directory-related tasks
alias root_level='cd $(git rev-parse --show-toplevel)'
alias root='~'
alias delete_all_branch='git branch | grep -v "master" | xargs git branch -D'
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

# Define an alias for nvim
alias v='nvim'

