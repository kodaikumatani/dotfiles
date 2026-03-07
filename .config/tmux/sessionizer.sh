#!/usr/bin/env bash
selected=$(ghq list | fzf --prompt='project> ')
[ -z "$selected" ] && exit 0

dir="$(ghq root)/$selected"
name=$(basename "$selected" | tr '.' '-')

if tmux has-session -t="$name" 2>/dev/null; then
  tmux switch-client -t "$name"
else
  tmux new-session -d -s "$name" -c "$dir"
  tmux switch-client -t "$name"
fi
