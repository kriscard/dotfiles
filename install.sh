#!/usr/bin/env bash

DOTFILES="$(pwd)"
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

title() {
    echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
    echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

error() {
    echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
    exit 1
}

warning() {
    echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
    echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
    echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}


backup() {
    BACKUP_DIR="$HOME/dotfiles-backup"

    echo "Creating backup directory at $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    for filename in "$HOME/.config/nvim" "$HOME/.config/tmux" "$HOME/.config/kitty" "$HOME/.config/alacritty" "$HOME/.config/skhd" "$HOME/.config/yabai"; do
        if [ -e "$filename" ]; then
            echo "backing up $filename"
            cp -rf "$filename" "$BACKUP_DIR"
        else
            warning "$filename does not exist at this location or is a symlink"
        fi
    done
}

setup_git() {
    title "Setting up Git"

    defaultName=$(git config user.name)
    defaultEmail=$(git config user.email)
    defaultGithub=$(git config github.user)

    read -rp "Name [$defaultName] " name
    read -rp "Email [$defaultEmail] " email
    read -rp "Github username [$defaultGithub] " github

    git config -f ~/.gitconfig-local user.name "${name:-$defaultName}"
    git config -f ~/.gitconfig-local user.email "${email:-$defaultEmail}"
    git config -f ~/.gitconfig-local github.user "${github:-$defaultGithub}"

    if [[ "$(uname)" == "kriscard" ]]; then
        git config --global credential.helper "osxkeychain"
    else
        read -rn 1 -p "Save user and password to an unencrypted file to avoid writing? [y/N] " save
        if [[ $save =~ ^([Yy])$ ]]; then
            git config --global credential.helper "store"
        else
            git config --global credential.helper "cache --timeout 3600"
        fi
    fi
}

setup_homebrew() {
    title "Setting up Homebrew"

    if test ! "$(command -v brew)"; then
        info "Homebrew not installed. Installing."
        # Run as a login shell (non-interactive) so that the script doesn't pause for user input
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash --login
    fi

    if [ "$(uname)" == "Linux" ]; then
        test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
        test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
    fi

    # install brew dependencies from Brewfile
    brew bundle --file="$DOTFILES/Brewfile"

    # install fzf
    echo -e
    info "Installing fzf"
    "$(brew --prefix)"/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
}

fetch_catppuccin_theme() {
    for palette in frappe latte macchiato mocha; do
        curl -o "$DOTFILES/.config/kitty/themes/catppuccin-$palette.conf" "https://raw.githubusercontent.com/catppuccin/kitty/main/$palette.conf"
    done
}

setup_shell() {
    title "Configuring shell"

    [[ -n "$(command -v brew)" ]] && zsh_path="$(brew --prefix)/bin/zsh" || zsh_path="$(which zsh)"
    if ! grep "$zsh_path" /etc/shells; then
        info "adding $zsh_path to /etc/shells"
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    if [[ "$SHELL" != "$zsh_path" ]]; then
        chsh -s "$zsh_path"
        info "default shell changed to $zsh_path"
    fi
}

function setup_terminfo() {
    title "Configuring terminfo"

    info "adding tmux.terminfo"
    tic -x "$DOTFILES/scripts/tmux.terminfo"

    info "adding xterm-256color-italic.terminfo"
    tic -x "$DOTFILES/scripts/xterm-256color-italic.terminfo"
}

setup_tmux() {
    title "Setting up tmux"

    # Install TPM if it doesn't exist
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        info "Installing TPM (Tmux Plugin Manager)"
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi

    # Install plugins (if tmux is running, this will work)
    if pgrep -x "tmux" > /dev/null; then
        info "Installing tmux plugins"
        ~/.tmux/plugins/tpm/bin/install_plugins
    else
        info "Tmux is not running. Start tmux and press prefix + I to install plugins"
    fi

    success "Tmux setup complete!"
}

setup_symlinks() {
    title "Setting up symlinks with GNU Stow"

    # Ensure we're in the dotfiles directory
    cd "$DOTFILES" || error "Cannot access dotfiles directory"

    # Check if stow is installed
    if ! command -v stow &> /dev/null; then
        error "GNU Stow is not installed. Please install it first with: brew install stow"
    fi

    # Create necessary directories
    mkdir -p "$HOME/.config"

    # Stow configurations using the .config directory structure
    info "Stowing configuration files..."

    # Handle conflicting files/directories
    conflicting_paths=(
        "$HOME/.config/nvim"
        "$HOME/.config/tmux"
        "$HOME/.config/kitty"
        "$HOME/.config/ghostty"
        "$HOME/.config/yabai"
        "$HOME/.config/skhd"
        "$HOME/.zshrc"
    )

    for path in "${conflicting_paths[@]}"; do
        if [ -e "$path" ] && [ ! -L "$path" ]; then
            warning "Backing up existing configuration: $path"
            mv "$path" "${path}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
    done

    # Stow each package
    packages=(".config" "zsh")

    for package in "${packages[@]}"; do
        if [ -d "$package" ]; then
            info "Stowing $package..."
            stow -t "$HOME" "$package" 2>/dev/null || {
                warning "Some symlinks for $package already exist. Restowing..."
                stow -R -t "$HOME" "$package"
            }
        fi
    done

    success "Symlinks created successfully!"
    info "Use 'stow -D .config' to remove symlinks if needed"
}

setup_macos() {
    title "Configuring macOS"
    if [[ "$(uname)" == "Darwin" ]]; then

        echo "Finder: show all filename extensions"
        defaults write NSGlobalDomain AppleShowAllExtensions -bool true

        echo "show hidden files by default"
        defaults write com.apple.Finder AppleShowAllFiles -bool false

        echo "only use UTF-8 in Terminal.app"
        defaults write com.apple.terminal StringEncodings -array 4

        echo "expand save dialog by default"
        defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

        echo "show the ~/Library folder in Finder"
        chflags nohidden ~/Library

        echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
        defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

        echo "Enable subpixel font rendering on non-Apple LCDs"
        defaults write NSGlobalDomain AppleFontSmoothing -int 2

        echo "Use current directory as default search scope in Finder"
        defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

        echo "Show Path bar in Finder"
        defaults write com.apple.finder ShowPathbar -bool true

        echo "Show Status bar in Finder"
        defaults write com.apple.finder ShowStatusBar -bool true

        echo "Disable press-and-hold for keys in favor of key repeat"
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

        echo "Set a blazingly fast keyboard repeat rate"
        defaults write NSGlobalDomain KeyRepeat -int 1

        echo "Set a shorter Delay until key repeat"
        defaults write NSGlobalDomain InitialKeyRepeat -int 15

        echo "Enable tap to click (Trackpad)"
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

        echo "Enable Safari’s debug menu"
        defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

        echo "Move dock to right side of screen"
        defaults write com.apple.dock orientation -string "right"

        echo "Set short Delay to Display Dock"
        defaults write com.apple.dock autohide-delay -float 0

        echo "Set Dock Modifier"
        defaults write com.apple.dock autohide-time-modifier -float 0.4

        echo "Kill affected applications"

        for app in Safari Finder Dock Mail SystemUIServer; do killall "$app" >/dev/null 2>&1; done
    else
        warning "macOS not detected. Skipping."
    fi
}

case "$1" in
    backup)
        backup
        ;;
    link)
        setup_symlinks
        ;;
    git)
        setup_git
        ;;
    homebrew)
        setup_homebrew
        ;;
    shell)
        setup_shell
        ;;
    terminfo)
        setup_terminfo
        ;;
    tmux)
        setup_tmux
        ;;
    macos)
        setup_macos
        ;;
    catppuccin)
        fetch_catppuccin_theme
        ;;
    all)
        setup_symlinks
        setup_terminfo
        setup_homebrew
        setup_shell
        setup_tmux
        setup_git
        setup_macos
        ;;
    *)
        echo -e $"\nUsage: $(basename "$0") {backup|link|git|homebrew|shell|terminfo|tmux|macos|catppuccin|all}\n"
        exit 1
        ;;
esac

echo -e
success "Done."
