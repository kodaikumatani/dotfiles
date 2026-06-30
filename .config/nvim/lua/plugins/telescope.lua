return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  -- キーマップは config/keymaps.lua で定義（最初の <leader>f* で遅延読み込みされる）
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/" },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true, -- 隠しファイルを表示
          no_ignore = false, -- .gitignore を尊重
        },
      },
    })
    telescope.load_extension("fzf")
  end,
}
