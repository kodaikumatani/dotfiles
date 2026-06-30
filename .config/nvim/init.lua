-- nvim バージョンチェック (>= 0.11.6)
if vim.fn.has("nvim-0.11.6") == 0 then
  vim.api.nvim_echo({
    { "WARNING: Neovim >= 0.11.6 required (current: " .. tostring(vim.version()) .. ")\n", "WarningMsg" },
  }, true, {})
end

-- mise の PATH を設定（gopls など mise 管理ツールを使えるようにする）
vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH

-- Leader は lazy 読み込み前に設定する
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")

-- カラースキームは設定しない（既定スキーム + cterm 色で端末の配色に追従する）
