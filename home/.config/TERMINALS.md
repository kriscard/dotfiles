# Terminal Configurations

This dotfiles setup includes configurations for two modern terminals optimized for development workflows: Kitty and Ghostty.

## Kitty Terminal

### Features
- **Theme**: Catppuccin Macchiato with automatic theme switching
- **Font**: Hack Nerd Font Mono with ligatures and symbol mapping
- **Splits**: Vim-style window management with intuitive layouts
- **Performance**: Hardware-accelerated rendering with optimized settings
- **Remote Control**: Enabled for vim-kitty-navigator integration
- **Scrollback**: Custom pager using Neovim for enhanced viewing

### Key Bindings
- **New Window**: `Cmd+Enter`
- **Vertical Split**: `Cmd+\`
- **Toggle Layout**: `Cmd+'` (switch between splits and stack)
- **Close Window**: `Cmd+Backspace`
- **Resize**: `Cmd+=/-/0/9/8` (taller/shorter/wider/narrower/reset)
- **Navigation**: `Cmd+Left/Right` (beginning/end of line)

### Configuration
Located at: `.config/kitty/kitty.conf`

### Advanced Features
- Comprehensive Nerd Font symbol mapping for all icon ranges
- Custom scrollback pager integration with Neovim
- Remote control socket for external integrations
- macOS-specific font rendering optimizations

## Ghostty Terminal

### Features
- **Theme**: Catppuccin with automatic light/dark mode support
- **Font**: Hack Nerd Font Mono with advanced typography features
- **Native**: True native macOS integration with system behaviors
- **Fast**: GPU-accelerated with minimal resource usage
- **Modern**: Latest terminal features and standards compliance
- **Splits**: Tmux-style prefix system for intuitive management

### Key Bindings
- **Prefix**: `Cmd+S` (tmux-style prefix for split operations)
- **Vertical Split**: `Cmd+S \`
- **Horizontal Split**: `Cmd+S -`
- **Navigate**: `Cmd+S h/j/k/l` (vim-style navigation)
- **Zoom**: `Cmd+S z` (toggle split zoom)
- **Equalize**: `Cmd+S e` (equalize split sizes)
- **Resize**: `Cmd+S Shift+h/j/k/l` (resize splits)

### Configuration
Located at: `.config/ghostty/config`

### Advanced Features
- Shell integration with cursor tracking and title management
- Clipboard integration with macOS system clipboard
- Advanced font features (ligatures, contextual alternates)
- Native macOS fullscreen and window management
- Performance-optimized scrollback and rendering

## Choosing Your Terminal

### Use Kitty If:
- You need maximum compatibility with existing vim/tmux workflows
- You want extensive customization options and plugin ecosystem
- You use complex terminal applications that require specific features
- You prefer traditional split management without prefix keys
- You need the scrollback pager integration with Neovim

### Use Ghostty If:
- You prefer native macOS integration and system behaviors
- You want the fastest possible performance with minimal resource usage
- You like modern, minimal configuration with sensible defaults
- You're comfortable with tmux-style prefix key management
- You're on the latest macOS version and want cutting-edge features

## Font Requirements

Both terminals are configured to use **Hack Nerd Font Mono** which is automatically installed via the Brewfile. This ensures:
- Consistent appearance across terminals and applications
- Full icon/symbol support for modern CLI tools (eza, bat, etc.)
- Proper ligature rendering for enhanced code readability
- Complete Nerd Font icon range coverage

## Theme Consistency

Both terminals use Catppuccin themes and respect the `THEME_FLAVOUR` environment variable:
- **Macchiato**: Default dark theme (warm, cozy colors)
- **Mocha**: Darker alternative (deeper, richer colors)
- **Frappe**: Lighter dark theme (softer, muted colors)
- **Latte**: Light theme (clean, bright colors)

Change themes system-wide:
```bash
export THEME_FLAVOUR=macchiato  # or mocha, frappe, latte
```

## Performance Considerations

### Kitty
- Hardware-accelerated rendering for smooth scrolling
- Optimized font rendering with macOS-specific adjustments
- Remote control features for external tool integration
- Custom scrollback handling for large output

### Ghostty
- Native GPU acceleration with minimal overhead
- True native macOS integration for system-level optimizations
- Efficient memory usage and startup time
- Modern terminal standards for maximum compatibility

## Integration with Development Tools

Both terminals are optimized for the included development workflow:
- **Tmux**: Full compatibility with session management and plugins
- **Neovim**: Enhanced integration for editing and scrollback viewing
- **Modern CLI Tools**: Proper support for eza, bat, fd icons and colors
- **Git**: Enhanced diff and log viewing with syntax highlighting
- **Shell**: Fast startup and responsive interaction with zsh configuration

Choose based on your preference for native macOS integration (Ghostty) versus maximum customization and compatibility (Kitty).
