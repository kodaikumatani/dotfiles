-- グローバルな autocmd / ユーザーコマンド

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- nvim で split を作ったら自動で tmux zoom に入る
vim.api.nvim_create_autocmd("WinNew", {
  group = augroup,
  callback = function()
    if vim.env.TMUX then
      vim.fn.system("tmux resize-pane -Z")
    end
  end,
})

-- 最後のウィンドウで :q / :bd しても Neovim を終了させない
-- （最後の1枚なら空バッファを開く。終了したいときは :qa）
vim.api.nvim_create_autocmd("QuitPre", {
  group = augroup,
  callback = function()
    local wins = vim.tbl_filter(function(w)
      return vim.api.nvim_win_get_config(w).relative == ""
    end, vim.api.nvim_list_wins())
    if #wins <= 1 then
      vim.cmd("enew")
    end
  end,
})

-- 外部でファイルが変更されたら自動で読み直す
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup,
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})

-- 内蔵ターミナルは使わない（tmux を使う）
vim.api.nvim_create_user_command("Terminal", function()
  vim.notify("Use tmux instead", vim.log.levels.WARN)
end, {})
