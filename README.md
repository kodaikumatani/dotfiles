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
    ├── wezterm/      # ターミナルエミュレータ（多重化内蔵）
    ├── zsh/          # zsh 関数（git → ghq ラッパ）
    ├── starship.toml # プロンプト
    └── nvim/         # Neovim 設定（下記参照）
```

ターミナルは **WezTerm**（端末＋多重化を兼ねる）。ペイン分割・タブ・ペイン移動を WezTerm 側で行う。

### WezTerm

```
wezterm/
├── wezterm.lua     # エントリ（各モジュールを require して組み立て）
├── appearance.lua  # フォント / 配色
├── keybinds.lua    # キーバインド
└── sessions.lua    # ghq + workspace のプロジェクト切り替え
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
        ├── kanagawa.lua      # カラースキーム（dragon）
        ├── lspconfig.lua     # LSP（mason 自動インストール＋自動有効化）
        ├── treesitter.lua    # シンタックス
        ├── telescope.lua     # 曖昧検索
        ├── conform.lua       # フォーマッタ（gofmt / prettier）
        ├── gitsigns.lua      # git 差分表示
        ├── neo-tree.lua      # ファイルツリー
        └── lualine.lua       # ステータスライン
```

LSP は mason が自動インストールし `mason-lspconfig` が自動有効化する（使う言語は `lspconfig.lua` のサーバー名リストに足すだけ）。補完は Neovim 0.11 ネイティブ（`vim.lsp.completion`、autotrigger）で nvim-cmp は使わない。シンタックスは treesitter、検索は telescope。

## Shortcuts

### WezTerm

既定キーバインドは無効化し、以下のみ明示定義している。

| Action | Key |
|--------|-----|
| コピー / ペースト | `Cmd+C` / `Cmd+V` |
| 検索 | `Cmd+F` |
| スクロールバッククリア | `Cmd+K` |
| コピーモード（vi 操作） | `Ctrl+Shift+X` |
| 新規ウィンドウ / 終了 | `Cmd+N` / `Cmd+Q` |
| フォント 拡大 / 縮小 / リセット | `Cmd+=` / `Cmd+-` / `Cmd+0` |
| 分割（右 / 下） | `Cmd+D` / `Cmd+Shift+D` |
| zoom トグル / 閉じる | `Cmd+\` / `Cmd+W` |
| タブ 新規 / 次 / 前 | `Cmd+T` / `Cmd+Shift+]` / `Cmd+Shift+[` |
| ペイン移動 | `Ctrl+H/J/K/L` |
| プロジェクト切替（ghq → workspace） | `Cmd+P` |

### Neovim

| Action | Key |
|--------|-----|
| ファイルツリー | `<leader>e` |
| ファイル検索 | `<leader>ff` |
| テキスト検索 | `<leader>fg` |
| バッファ / ヘルプ / 履歴 | `<leader>fb` / `fh` / `fr` |

leader は `Space`。

#### LSP（アタッチ時）

| キー | 動作 | 由来 |
|------|------|------|
| `gd` | 定義へジャンプ | 設定（`<C-]>` も可） |
| `K` | ホバー（型 / ドキュメント） | 0.11 既定 |
| `grn` | リネーム | 0.11 既定 |
| `gra` | コードアクション | 0.11 既定 |
| `grr` | 参照一覧 | 0.11 既定 |
| `gri` | 実装へジャンプ | 0.11 既定 |
| `grt` | 型定義へジャンプ | 0.11 既定 |
| `gO` | ドキュメントシンボル一覧 | 0.11 既定 |
| `<C-W>d` | 診断をフロート表示 | 0.11 既定 |
| `<C-S>`（挿入） | シグネチャヘルプ | 0.11 既定 |
| `[d` / `]d` | 前 / 次の診断へ | 0.11 既定 |
| `[D` / `]D` | 最初 / 最後の診断へ | 0.11 既定 |

定義から戻るのは `Ctrl+O`。
