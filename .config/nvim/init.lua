-- mise の PATH を設定（Go、goplsなどのツールを使用可能にする）
vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH

-- Leader key
vim.g.mapleader = " "

-- 基本設定
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- EditorConfig サポートを有効化（Neovim 0.9+ ビルトイン）
vim.g.editorconfig = true

require("config.lazy")


vim.cmd.colorscheme("tokyonight")

-- キーマップ
vim.keymap.set("n", "<leader>e", ":Neotree toggle reveal<CR>")

-- Neovim内蔵ターミナルを無効化（tmuxを使用）
vim.api.nvim_create_user_command("terminal", function() vim.notify("Use tmux instead", vim.log.levels.WARN) end, {})

-- Telescope (曖昧検索)
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'ファイル検索' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'テキスト検索' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'バッファ検索' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'ヘルプ検索' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = '最近開いたファイル' })
vim.keymap.set('n', '<leader>fp', function()
  require("telescope").extensions.projects.projects({
    attach_mappings = function(_, map)
      local actions = require("telescope.actions")
      map("i", "<CR>", function(prompt_bufnr)
        local action_state = require("telescope.actions.state")
        local selected = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selected then
          vim.cmd("%bdelete")
          vim.cmd("cd " .. selected.value)
        end
      end)
      return true
    end,
  })
end, { desc = 'プロジェクト切り替え' })

-- 最後のウィンドウで :q しても Neovide が終了しないようにする
-- 最後の1枚のときは空バッファを開く（終了したいときは :qa）
vim.cmd([[cnoreabbrev <expr> q (tabpagenr('$') == 1 && winnr('$') == 1) ? 'enew' : 'q']])

-- 外部でファイルが変更されたら自動的に読み直す (autoread)
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})
