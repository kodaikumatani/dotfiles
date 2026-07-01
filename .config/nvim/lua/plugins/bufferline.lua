return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "次のバッファ" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "前のバッファ" },
    { "<leader>bd", "<cmd>bdelete<cr>", desc = "バッファを閉じる" },
  },
  opts = {
    options = {
      diagnostics = "nvim_lsp", -- タブに LSP 診断を表示
      show_buffer_close_icons = false,
      always_show_bufferline = true,
    },
  },
}
