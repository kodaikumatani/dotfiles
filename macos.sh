#!/usr/bin/env bash
# macOS のシステム設定。`./install.sh --macos` または直接実行で適用。
# 適用後はログアウト/再起動で完全に反映される。
set -euo pipefail

log() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }

log "Keyboard: キーリピートを高速化し、長押しリピートを有効化（Vim 向け）"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

log "Finder: 隠しファイル・全拡張子・パスバー・ステータスバーを表示"
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

log "Finder: ネットワーク/USB に .DS_Store を作らない"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

log "保存・印刷パネルをデフォルトで展開"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

log "Dock: 自動的に隠す + 表示遅延をなくす"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0

# 変更を反映
killall Finder Dock 2>/dev/null || true

log "Done. 一部の設定はログアウト/再起動で完全に反映されます。"
