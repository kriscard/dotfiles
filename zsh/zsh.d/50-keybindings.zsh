# Key Bindings
# fzf, history search, and custom bindings

# Use emacs key bindings
bindkey -e

# fzf integration
if [[ -f "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]]; then
  source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  # Override fzf's Alt+C (conflicts with Raycast)
  # Rebind directory changer to Ctrl+F
  bindkey -r '\ec'              # Unbind Alt+C
  bindkey '^F' fzf-cd-widget    # Bind Ctrl+F to directory changer
fi

if [[ -f "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh" ]]; then
  source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
fi

# fzf configuration with Catppuccin Macchiato theme
export FZF_DEFAULT_OPTS=" \
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 \
--height=40% --layout=reverse --border --info=inline"

# Use fd for file finding (respects .gitignore)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Previews
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --level=2 {} | head -200'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:wrap"

# History substring search bindings
if (( $+widgets[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up      # Up arrow
  bindkey '^[[B' history-substring-search-down    # Down arrow
  bindkey '^P' history-substring-search-up        # Ctrl+P
  bindkey '^N' history-substring-search-down      # Ctrl+N
fi

# Autosuggestion accept with Tab
bindkey '^I' autosuggest-accept

# Word navigation
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left

# Delete word
bindkey '^H' backward-kill-word  # Ctrl+Backspace
bindkey '^[[3;5~' kill-word      # Ctrl+Delete

# Home/End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Sesh session switcher
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}
zle -N sesh-sessions
bindkey '^g' sesh-sessions
