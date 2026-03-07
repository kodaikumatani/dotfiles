#!/usr/bin/env bash
selected=$(ghq list | fzf --prompt='project> ')
[ -z "$selected" ] && exit 0

dir="$(ghq root)/$selected"
name=$(basename "$selected" | tr '.' '-')
sock="/tmp/nvim-${name}.sock"

if tmux has-session -t="$name" 2>/dev/null; then
  tmux switch-client -t "$name"
else
  tmux new-session -d -s "$name" -c "$dir"
  tmux split-window -h -t "$name" -c "$dir" "nvim --listen $sock"
  tmux select-pane -t "$name":1.0
  tmux switch-client -t "$name"
fi
