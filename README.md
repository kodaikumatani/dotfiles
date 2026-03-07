# dotfiles

My configuration files managed with symlinks.

## Structure

- `.config/ghostty/` - Ghostty terminal config
- `.config/tmux/` - tmux config + sessionizer

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
