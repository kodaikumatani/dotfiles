-- グローバルな autocmd / ユーザーコマンド
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- 外部でファイルが変更されたら自動で読み直す
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup,
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})
