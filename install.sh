#!/usr/bin/env bash
# dotfiles セットアップ。何度実行しても安全（冪等）。
#
#   ./install.sh            # シンボリックリンク + Brewfile
#   ./install.sh --macos    # 上記 + macOS defaults も適用
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }

# link <src> <dest>
# 既存の dest がリンク・実ファイル・実ディレクトリのどれでも安全に張り替える。
link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    # 既に正しいリンクなら何もしない
    if [ "$(readlink "$dest")" = "$src" ]; then
      log "ok    $dest"
      return
    fi
    rm "$dest"
  elif [ -e "$dest" ]; then
    # 実体がある場合はバックアップしてから退避
    log "backup $dest -> $dest.bak"
    rm -rf "$dest.bak"
    mv "$dest" "$dest.bak"
  fi

  ln -s "$src" "$dest"
  log "link  $dest -> $src"
}

log "Linking config files..."
link "$DOTFILES/.config/wezterm"      "$HOME/.config/wezterm"
link "$DOTFILES/.config/nvim"         "$HOME/.config/nvim"
link "$DOTFILES/.config/zsh"          "$HOME/.config/zsh"
link "$DOTFILES/.config/starship.toml" "$HOME/.config/starship.toml"
link "$DOTFILES/.config/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
link "$DOTFILES/.config/claude/settings.json"         "$HOME/.claude/settings.json"

# zsh から dotfiles の関数を読み込む行を 1 度だけ追記
ZSHRC="$HOME/.zshrc"
SOURCE_LINE='source ~/.config/zsh/git-ghq.zsh'
if ! { [ -f "$ZSHRC" ] && grep -qF "$SOURCE_LINE" "$ZSHRC"; }; then
  log "Adding source line to $ZSHRC"
  printf '\n%s\n' "$SOURCE_LINE" >> "$ZSHRC"
fi

# Homebrew パッケージ
if command -v brew >/dev/null 2>&1; then
  log "Installing Brewfile packages..."
  brew bundle --file="$DOTFILES/Brewfile"
else
  log "WARNING: Homebrew が見つかりません。https://brew.sh からインストールしてください。"
fi

# macOS defaults（任意）
if [ "${1:-}" = "--macos" ]; then
  log "Applying macOS defaults..."
  bash "$DOTFILES/macos.sh"
fi

log "Done. 新しいシェルを開くか 'source ~/.zshrc' を実行してください。"
