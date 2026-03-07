# Neovim Configuration

個人用のNeovim設定ファイルです。Go言語開発を中心に、モダンなエディタ機能を提供します。

## 必要な環境

- Neovim >= 0.11
- Git
- Node.js (LSP用)
- [Nerd Font](https://www.nerdfonts.com/) (アイコン表示用)

## セットアップ

### 1. Nerd Fontのインストール

アイコンを正しく表示するために、Nerd Fontが必要です。

```bash
# JetBrains Mono Nerd Fontをインストール
brew install font-jetbrains-mono-nerd-font
```

#### ターミナルのフォント設定

インストール後、使用しているターミナルでフォントを設定してください。

**iTerm2:**
1. `iTerm2` → `Preferences` (⌘,)
2. `Profiles` → `Text` タブ
3. `Font` を `JetBrainsMono Nerd Font` に変更
4. サイズは 14pt 程度を推奨

**Terminal.app (デフォルト):**
1. `Terminal` → `Preferences`
2. `Profiles` → `Text` タブ
3. `Font` ボタンをクリックして `JetBrainsMono Nerd Font` を選択

**Alacritty:**
`~/.config/alacritty/alacritty.yml`:
```yaml
font:
  normal:
    family: JetBrainsMono Nerd Font
    style: Regular
  size: 14.0
```

**Kitty:**
`~/.config/kitty/kitty.conf`:
```
font_family JetBrainsMono Nerd Font
font_size 14.0
```

**WezTerm:**
`~/.config/wezterm/wezterm.lua`:
```lua
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 14.0
```

### 2. 設定のクローン

```bash
# 既存の設定があればバックアップ
mv ~/.config/nvim ~/.config/nvim.backup

# このリポジトリをクローン
git clone https://github.com/kodaikumatani/nvim-config ~/.config/nvim
```

### 3. Neovimを起動

```bash
nvim
```

初回起動時に自動的にプラグインがインストールされます。

### 4. LSPサーバーのインストール

```vim
:Lazy sync
:TSInstall go lua vim
```

## 主な機能

### ファイル操作
- `<Space>e` - ファイルツリーを表示/非表示
- `<Space>g` - Git変更ファイルを表示
- `<Space>ff` - ファイル名で検索
- `<Space>fg` - ファイル内のテキストを検索
- `<Space>fb` - 開いているバッファを検索
- `<Space>fr` - 最近開いたファイルを検索

### ウィンドウ操作
- `Ctrl-h/j/k/l` - ウィンドウ間を移動

### LSP機能
- `gd` - 定義にジャンプ
- `K` - ホバー情報を表示
- `<Space>rn` - 変数名を変更
- `<Space>ca` - コードアクション
- `gr` - 参照を表示
- `gl` - 診断を詳細表示
- `[d` / `]d` - 前/次の診断へ移動

### Neo-tree内のキーマップ
- `a` - ファイル/フォルダを追加
- `d` - 削除
- `r` - リネーム
- `P` - プレビュー表示
- `?` - ヘルプを表示

## インストール済みプラグイン

- **lazy.nvim** - プラグインマネージャー
- **tokyonight.nvim** - カラースキーム
- **telescope.nvim** - 曖昧検索
- **neo-tree.nvim** - ファイルエクスプローラー
- **nvim-treesitter** - シンタックスハイライト
- **nvim-lspconfig** - LSP設定
- **mason.nvim** - LSPサーバー管理
- **nvim-cmp** - 補完
- **gitsigns.nvim** - Git統合

## カスタマイズ

設定は以下のように整理されています：

```
~/.config/nvim/
├── init.lua              # メイン設定
├── lua/
│   ├── config/
│   │   └── lazy.lua      # プラグインマネージャー設定
│   └── plugins/          # プラグイン設定（ファイル分割）
│       ├── colorscheme.lua
│       ├── telescope.lua
│       ├── neo-tree.lua
│       ├── treesitter.lua
│       ├── lsp.lua
│       ├── completion.lua
│       └── git.lua
└── lazy-lock.json        # プラグインバージョン固定
```

新しいプラグインを追加する場合は、`lua/plugins/` 内に新しいファイルを作成してください。

## トラブルシューティング

### アイコンが正しく表示されない
- Nerd Fontがインストールされているか確認
- ターミナルのフォント設定を確認

### プラグインが読み込まれない
```vim
:Lazy sync
```

### LSPが動作しない
```vim
:Mason
```
でLSPサーバーがインストールされているか確認

## ライセンス

MIT
