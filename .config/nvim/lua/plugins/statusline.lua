return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "tokyonight",
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          {
            "filename",
            path = 1, -- 相対パスを表示
            symbols = {
              modified = "",
              readonly = " ",
              unnamed = "[No Name]",
            },
          },
          {
            function()
              if vim.bo.modified then
                return "●"
              elseif vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
                return "✓"
              end
              return ""
            end,
            color = function()
              if vim.bo.modified then
                return { fg = "#e06c75" }
              else
                return { fg = "#98c379" }
              end
            end,
          },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
