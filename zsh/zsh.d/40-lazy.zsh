# Lazy Loading for Heavy Tools
# Caches init output for faster shell startup

ZSH_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$ZSH_CACHE" ]] || mkdir -p "$ZSH_CACHE"

# Lazy init helper - caches command output, regenerates when binary changes
_lazy_init() {
  local cmd=$1
  local cache_file="$ZSH_CACHE/${cmd}-init.zsh"
  local bin_path

  # Find binary location
  bin_path="$(whence -p $cmd 2>/dev/null)"
  [[ -z "$bin_path" ]] && return 1

  # Regenerate if cache missing or binary newer than cache
  if [[ ! -f "$cache_file" || "$bin_path" -nt "$cache_file" ]]; then
    case $cmd in
      starship) starship init zsh --print-full-init > "$cache_file" 2>/dev/null ;;
      zoxide)   zoxide init zsh > "$cache_file" 2>/dev/null ;;
      atuin)    atuin init zsh --disable-up-arrow > "$cache_file" 2>/dev/null ;;
    esac
  fi

  [[ -f "$cache_file" ]] && source "$cache_file" 2>/dev/null
}

# Initialize tools with caching (only in interactive shells)
if [[ -o interactive ]]; then
  (( $+commands[starship] )) && _lazy_init starship
  (( $+commands[zoxide] )) && _lazy_init zoxide
  (( $+commands[atuin] )) && _lazy_init atuin
fi

# Starship config location
export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"

# asdf - lazy loaded for faster startup
# Shims are added to PATH immediately so tools work, but full asdf.sh
# is deferred until `asdf` command is actually used
if [[ -d "/opt/homebrew/opt/asdf/libexec" ]]; then
  # Add shims to PATH immediately (tools like node, npm work right away)
  export ASDF_DIR="/opt/homebrew/opt/asdf/libexec"
  export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
  [[ -d "$ASDF_DATA_DIR/shims" ]] && path=("$ASDF_DATA_DIR/shims" $path)

  # Lazy load: source full asdf.sh only when `asdf` command is used
  asdf() {
    unfunction asdf 2>/dev/null
    source "$ASDF_DIR/asdf.sh"
    asdf "$@"
  }
fi
