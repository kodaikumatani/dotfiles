-- nvim バージョンチェック (>= 0.11.6)
if vim.fn.has("nvim-0.11.6") == 0 then
  vim.api.nvim_echo({
    { "WARNING: Neovim >= 0.11.6 required (current: " .. tostring(vim.version()) .. ")\n", "WarningMsg" },
  }, true, {})
end

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

-- split間の移動（tmux連携: zoom中はnvim split移動）
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- nvimでsplit時に自動でtmux zoomに入る
vim.api.nvim_create_autocmd("WinNew", {
  callback = function()
    if vim.env.TMUX then
      vim.fn.system("tmux resize-pane -Z")
    end
  end,
})

-- 矢印キーでの移動を無効化（hjkl を使う）
local arrow_keys = { "<Up>", "<Down>", "<Left>", "<Right>" }
local modes = { "n", "i", "v" }
for _, key in ipairs(arrow_keys) do
  for _, mode in ipairs(modes) do
    vim.keymap.set(mode, key, "<Nop>")
  end
end

-- Neovim内蔵ターミナルを無効化（tmuxを使用）
vim.api.nvim_create_user_command("Terminal", function() vim.notify("Use tmux instead", vim.log.levels.WARN) end, {})

-- Telescope (曖昧検索)
local builtin = require('telescope.builtin')
local project_root_markers = {
  "package.json",
  "go.mod",
  "Cargo.toml",
  "pyproject.toml",
  "Makefile",
}

local function telescope_search_root()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local start_path = buf_name ~= "" and buf_name or vim.fn.getcwd()

  local git_root = vim.fs.root(start_path, ".git")
  if git_root then
    return git_root
  end

  local marker_root = vim.fs.root(start_path, project_root_markers)
  if marker_root then
    return marker_root
  end

  if buf_name ~= "" then
    return vim.fs.dirname(buf_name)
  end

  return vim.fn.getcwd()
end

vim.keymap.set('n', '<leader>ff', function()
  builtin.find_files({ cwd = telescope_search_root() })
end, { desc = 'ファイル検索' })
vim.keymap.set('n', '<leader>fg', function()
  builtin.live_grep({ cwd = telescope_search_root() })
end, { desc = 'テキスト検索' })
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

-- 最後のウィンドウで :q / :bd しても Neovim が終了しないようにする
-- 最後の1枚のときは空バッファを開く（終了したいときは :qa）
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    -- 通常ウィンドウ（floating除外）をカウント
    local wins = vim.tbl_filter(function(w)
      return vim.api.nvim_win_get_config(w).relative == ""
    end, vim.api.nvim_list_wins())
    if #wins <= 1 then
      vim.cmd("enew")
    end
  end,
})

-- 外部でファイルが変更されたら自動的に読み直す (autoread)
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})
