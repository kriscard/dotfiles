# ZSH Options and History Configuration

# Performance
export KEYTIMEOUT=1              # 10ms delay for key sequences
export REPORTTIME=10             # Report time for commands > 10 seconds

# History configuration
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
export HISTSIZE=100000
export SAVEHIST=100000

# Create history directory if needed
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

# History options
setopt EXTENDED_HISTORY          # Write ":start:elapsed;command" format
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt SHARE_HISTORY             # Share history between sessions
setopt HIST_IGNORE_ALL_DUPS      # Delete old entry if new is duplicate
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
setopt HIST_VERIFY               # Show command before executing from history
setopt INC_APPEND_HISTORY        # Add commands immediately to history

# Directory options
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Push directories onto stack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt PUSHD_SILENT              # Don't print directory stack

# Completion options
setopt COMPLETE_IN_WORD          # Complete from both ends of word
setopt ALWAYS_TO_END             # Move cursor to end after completion

# Globbing
setopt EXTENDED_GLOB             # Extended globbing syntax
setopt NO_CASE_GLOB              # Case insensitive globbing

# Misc
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive shell
setopt NO_BEEP                   # Disable beep
