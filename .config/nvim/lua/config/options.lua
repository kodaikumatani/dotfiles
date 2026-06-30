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
-- termguicolors を切り、端末（WezTerm）の 16色 ANSI パレットに追従させる
opt.termguicolors = false
opt.signcolumn = "yes"

-- クリップボード共有
opt.clipboard = "unnamedplus"

-- 外部変更を自動で読み直す（autocmds.lua の checktime と併用）
opt.autoread = true

-- EditorConfig サポート（Neovim 0.9+ ビルトイン）
vim.g.editorconfig = true
