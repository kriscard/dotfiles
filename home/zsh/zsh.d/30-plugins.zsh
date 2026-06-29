# ZSH Plugins
# Direct sourcing without plugin manager for maximum speed

# Autosuggestions
[[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax highlighting (must load before history-substring-search)
[[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# History substring search (must load after syntax highlighting)
[[ -f "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] && \
  source "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

# Autosuggestion configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6e738d"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# History substring search: override unreadable default (bg=magenta,fg=white,bold).
# Catppuccin Macchiato red on dark crust text — danger color, text stays legible.
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=#ed8796,bold,underline'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=#ed8796,fg=#181926,bold'

# Danger patterns: visible warning that disappears once the dangerous bit is edited out.
# The `pattern` highlighter re-evaluates on every keystroke against the full buffer.
# Style: dark crust text on Catppuccin red — high contrast, readable, alarms appropriately.
ZSH_HIGHLIGHT_HIGHLIGHTERS+=(pattern)
typeset -gA ZSH_HIGHLIGHT_PATTERNS
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf*' 'fg=#181926,bg=#ed8796,bold')
# TODO: add more dangerous patterns here. See `60-aliases.zsh:89` for your `rmf` alias.
