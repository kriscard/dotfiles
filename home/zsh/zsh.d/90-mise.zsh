# Activate mise after the rest of the interactive shell has configured PATH.
(( $+commands[mise] )) && eval "$(mise activate zsh)"
