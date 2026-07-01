-- グローバルキーマップ（プラグイン依存のものを含む）

local map = vim.keymap.set

-- ファイルツリー
map("n", "<leader>e", ":Neotree toggle reveal<CR>", { desc = "ファイルツリー切替" })

-- 矢印キーを無効化（hjkl を使う）
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  for _, mode in ipairs({ "n", "i", "v" }) do
    map(mode, key, "<Nop>")
  end
end

-- Telescope（曖昧検索）。builtin は遅延 require する
local function telescope(fn)
  return function()
    require("telescope.builtin")[fn]()
  end
end

-- 検索ルート解決: git ルート → プロジェクトマーカー → バッファのディレクトリ → cwd
local project_root_markers = { "package.json", "go.mod", "Cargo.toml", "pyproject.toml", "Makefile" }
local function search_root()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local start_path = buf_name ~= "" and buf_name or vim.fn.getcwd()
  return vim.fs.root(start_path, ".git")
    or vim.fs.root(start_path, project_root_markers)
    or (buf_name ~= "" and vim.fs.dirname(buf_name))
    or vim.fn.getcwd()
end

map("n", "<leader>ff", function()
  require("telescope.builtin").find_files({ cwd = search_root() })
end, { desc = "ファイル検索" })
map("n", "<leader>fg", function()
  require("telescope.builtin").live_grep({ cwd = search_root() })
end, { desc = "テキスト検索" })
map("n", "<leader>fb", telescope("buffers"), { desc = "バッファ検索" })
map("n", "<leader>fh", telescope("help_tags"), { desc = "ヘルプ検索" })
map("n", "<leader>fr", telescope("oldfiles"), { desc = "最近開いたファイル" })
