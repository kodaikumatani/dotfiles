#!/usr/bin/env bash
selected=$(ghq list | fzf --prompt='project> ')
[ -z "$selected" ] && exit 0

dir="$(ghq root)/$selected"
name=$(basename "$selected" | tr '.' '-')
sock="/tmp/nvim-${name}.sock"

if tmux has-session -t="$name" 2>/dev/null; then
  tmux switch-client -t "$name"
else
  rm -f "$sock"

  tmux new-session -d -s "$name" -c "$dir"

  # nvim をヘッドレスサーバーとしてバックグラウンド起動
  tmux send-keys -t "$name" "nvim --headless --listen $sock & disown && clear" Enter

  # ソケットが作成されるまで待つ
  for i in $(seq 1 30); do
    [ -S "$sock" ] && break
    sleep 0.1
  done

  if [ ! -S "$sock" ]; then
    echo "[sessionizer] ERROR: nvim socket $sock not created after 3s" >&2
  fi

  # pane 0: ターミナル(左)、pane 1: remote-ui で接続(右)
  right_pane=$(tmux split-window -h -t "$name" -c "$dir" -P -F "#{pane_id}")
  tmux send-keys -t "$right_pane" "nvim --server $sock --remote-ui" Enter
  tmux select-pane -t "$right_pane"
  tmux set-hook -t "$name" session-closed "run-shell 'kill \$(lsof -t $sock) 2>/dev/null; rm -f $sock'"
  tmux switch-client -t "$name"
fi
