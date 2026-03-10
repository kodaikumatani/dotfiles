# dotfiles

My configuration files managed with symlinks.

## Setup

```bash
# Install dependencies (macOS)
brew install tmux ghq fzf ripgrep starship

# Create symlinks
ln -sf ~/ghq/github.com/kodaikumatani/dotfiles/.config/ghostty ~/.config/ghostty
ln -sf ~/ghq/github.com/kodaikumatani/dotfiles/.config/tmux ~/.config/tmux
ln -sf ~/ghq/github.com/kodaikumatani/dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/ghq/github.com/kodaikumatani/dotfiles/.config/zsh ~/.config/zsh

# Install neovim via mise (version managed in .config/mise/config.toml)
mise use -g neovim@0.11.6

# Load zsh config
echo 'source ~/.config/zsh/git-ghq.zsh' >> ~/.zshrc
```

## Structure

- `.config/ghostty/` - Ghostty terminal config
- `.config/nvim/` - Neovim config
- `.config/tmux/` - tmux config + sessionizer
- `.config/zsh/` - zsh functions
- `.config/starship.toml` - Starship prompt config

## Shortcuts

All tmux operations are mapped to Cmd keys via Ghostty keybindings.

### Window

| Action | Key |
|--------|-----|
| New window | `Cmd+T` |
| Close window | `Cmd+W` |
| Next window | `Cmd+}` |
| Previous window | `Cmd+{` |

### Pane

| Action | Key |
|--------|-----|
| Split right | `Cmd+D` |
| Split down | `Cmd+Shift+D` |
| Zoom toggle | `Cmd+\` |
| Move left | `Ctrl+H` |
| Move down | `Ctrl+J` |
| Move up | `Ctrl+K` |
| Move right | `Ctrl+L` |

### Session

| Action | Key |
|--------|-----|
| Project switcher (ghq+fzf) | `Cmd+R` |
| Session list | `Cmd+S` |
