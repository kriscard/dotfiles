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

# asdf - load immediately for automatic version switching
if [[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]]; then
  # Remove any existing alias to prevent conflict on reload
  unalias asdf 2>/dev/null
  source "/opt/homebrew/opt/asdf/libexec/asdf.sh"
fi
