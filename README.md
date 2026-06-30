# dotfiles

macOS の設定ファイル一式。シンボリックリンクで管理し、`install.sh` で再現する。

## Setup

```bash
# 1. Homebrew（未インストールなら）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. このリポジトリを取得
ghq get kodaikumatani/dotfiles   # もしくは git clone
cd ~/ghq/github.com/kodaikumatani/dotfiles

# 3. セットアップ（リンク作成 + Brewfile インストール）
./install.sh            # 設定リンク + Homebrew パッケージ
./install.sh --macos    # 上記 + macOS のシステム設定も適用
```

`install.sh` は冪等。既存ファイルがある場合は `*.bak` に退避してからリンクを張る。

`.zshrc` には以下が必要（`install.sh` が source 行を追記する。starship / mise は手動で追加）:

```sh
eval "$(starship init zsh)"
eval "$(mise activate zsh)"
source ~/.config/zsh/git-ghq.zsh
```

## Structure

```
dotfiles/
├── Brewfile          # 依存パッケージの宣言
├── install.sh        # シンボリックリンク + brew bundle（冪等）
├── macos.sh          # macOS の defaults 設定
└── .config/
    ├── ghostty/      # ターミナルエミュレータ
    ├── tmux/         # tmux 設定 + sessionizer
    ├── zsh/          # zsh 関数（git → ghq ラッパ）
    ├── starship.toml # プロンプト
    └── nvim/         # Neovim 設定（下記参照）
```

### Neovim

```
nvim/
├── init.lua                  # ブートストラップのみ
└── lua/
    ├── config/
    │   ├── options.lua       # vim.opt 系
    │   ├── keymaps.lua       # グローバルキーマップ
    │   ├── autocmds.lua      # autocmd / ユーザーコマンド
    │   └── lazy.lua          # プラグインマネージャ
    └── plugins/              # 1 ファイル = 1 プラグイン（ファイル名 = プラグイン名）
        ├── tokyonight.lua    # カラースキーム
        ├── treesitter.lua    # シンタックス
        ├── telescope.lua     # 曖昧検索
        ├── conform.lua       # フォーマッタ（gofmt / prettier）
        ├── gitsigns.lua      # git 差分表示
        ├── neo-tree.lua      # ファイルツリー
        └── lualine.lua       # ステータスライン
```

LSP・補完プラグインは使わない方針（定義ジャンプ・診断・自動補完なし）。補完は Neovim 組込み（`<C-n>` / `<C-x><C-f>` など）、シンタックスは treesitter、検索は telescope に寄せている。

## Shortcuts

tmux 操作は Ghostty のキーバインドで Cmd キーにマップしている。

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
| Move left/down/up/right | `Ctrl+H/J/K/L` |

### Session

| Action | Key |
|--------|-----|
| Project switcher (ghq+fzf) | `Cmd+R` |
| Session list | `Cmd+S` |

### Neovim

| Action | Key |
|--------|-----|
| ファイルツリー | `<leader>e` |
| ファイル検索 | `<leader>ff` |
| テキスト検索 | `<leader>fg` |
| バッファ / ヘルプ / 履歴 | `<leader>fb` / `fh` / `fr` |

leader は `Space`。
