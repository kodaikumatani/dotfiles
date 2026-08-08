-- エディタの基本オプション

local opt = vim.opt

-- 行番号
opt.number = true
opt.relativenumber = true

-- インデント
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- 表示
opt.termguicolors = true
opt.signcolumn = "yes"

-- 補完（Neovim 0.11 ネイティブ LSP 補完 / lspconfig.lua で autotrigger 有効）
-- noselect を入れないと先頭候補が自動選択・挿入され、入力が勝手に書き換わる
opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }
opt.pumheight = 10

-- クリップボード共有
opt.clipboard = "unnamedplus"

-- 外部変更を自動で読み直す（autocmds.lua の checktime と併用）
opt.autoread = true

-- EditorConfig サポート（Neovim 0.9+ ビルトイン）
vim.g.editorconfig = true
