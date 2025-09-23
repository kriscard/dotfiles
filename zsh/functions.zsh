# Useful development functions for faster workflow

# Quick directory creation and navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find and kill process by name
killport() {
    if [ -z "$1" ]; then
        echo "Usage: killport <port>"
        return 1
    fi
    lsof -ti tcp:"$1" | xargs kill -9
}

# Quick git commit with message
gcommit() {
    if [ -z "$1" ]; then
        echo "Usage: gcommit <commit_message>"
        return 1
    fi
    git add -A && git commit -m "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Show system information (manual neofetch)
sysinfo() {
    if command -v neofetch &> /dev/null; then
        neofetch
    else
        echo "System Information:"
        echo "OS: $(uname -s)"
        echo "Hostname: $(hostname)"
        echo "User: $(whoami)"
        echo "Shell: $SHELL"
        echo "Terminal: $TERM"
    fi
}

# Quick npm/yarn/pnpm project initialization
init-node() {
    local manager=${1:-npm}
    echo "Initializing Node.js project with $manager..."

    case $manager in
        npm)
            npm init -y
            ;;
        yarn)
            yarn init -y
            ;;
        pnpm)
            pnpm init
            ;;
        *)
            echo "Usage: init-node [npm|yarn|pnpm]"
            return 1
            ;;
    esac
}

