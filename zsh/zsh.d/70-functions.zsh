# Utility Functions

# Shell startup profiling - diagnose what's slowing down shell startup
zsh-profile() {
  echo "Profiling zsh startup time..."
  echo ""

  # Quick timing
  local start end
  start=$(gdate +%s%3N 2>/dev/null || date +%s)
  zsh -i -c exit 2>/dev/null
  end=$(gdate +%s%3N 2>/dev/null || date +%s)

  if command -v gdate &>/dev/null; then
    echo "Total startup time: $((end - start))ms"
  else
    echo "Total startup time: ~$((end - start))s (install coreutils for ms precision)"
  fi
  echo ""

  # Detailed profiling with zprof
  echo "Detailed breakdown (top 10):"
  echo "─────────────────────────────────────────"
  ZPROF=1 zsh -i -c 'zprof | head -15' 2>/dev/null
  echo ""
  echo "Tip: Add 'zmodload zsh/zprof' at top of .zshrc for more detail"
}

# Quick directory creation and navigation
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Find and kill process by port
killport() {
  if [[ -z "$1" ]]; then
    echo "Usage: killport <port>"
    return 1
  fi
  lsof -ti tcp:"$1" | xargs kill -9 2>/dev/null || echo "No process on port $1"
}

# Quick git commit with message
gcommit() {
  if [[ -z "$1" ]]; then
    echo "Usage: gcommit <commit_message>"
    return 1
  fi
  git add -A && git commit -m "$1"
}

# Extract various archive formats
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.tar.xz)    tar xJf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *.zst)       unzstd "$1"      ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# System information
sysinfo() {
  if (( $+commands[neofetch] )); then
    neofetch
  elif (( $+commands[fastfetch] )); then
    fastfetch
  else
    echo "System Information:"
    echo "OS: $(uname -s) $(uname -r)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Shell: $SHELL"
    echo "Terminal: $TERM"
  fi
}

# Quick npm/yarn/pnpm project initialization
init-node() {
  local manager=${1:-pnpm}
  echo "Initializing Node.js project with $manager..."
  case $manager in
    npm)  npm init -y ;;
    yarn) yarn init -y ;;
    pnpm) pnpm init ;;
    *)    echo "Usage: init-node [npm|yarn|pnpm]"; return 1 ;;
  esac
}

# Sesh list with fzf
seshco() {
  sesh connect $(sesh list | fzf)
}
