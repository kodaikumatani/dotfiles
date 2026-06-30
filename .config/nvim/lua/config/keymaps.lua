-- グローバルキーマップ（プラグイン依存のものを含む）

local map = vim.keymap.set

-- ファイルツリー
map("n", "<leader>e", ":Neotree toggle reveal<CR>", { desc = "ファイルツリー切替" })

-- split 間の移動（tmux 連携: zoom 中は nvim split を移動する）
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

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
map("n", "<leader>ff", telescope("find_files"), { desc = "ファイル検索" })
map("n", "<leader>fg", telescope("live_grep"), { desc = "テキスト検索" })
map("n", "<leader>fb", telescope("buffers"), { desc = "バッファ検索" })
map("n", "<leader>fh", telescope("help_tags"), { desc = "ヘルプ検索" })
map("n", "<leader>fr", telescope("oldfiles"), { desc = "最近開いたファイル" })
