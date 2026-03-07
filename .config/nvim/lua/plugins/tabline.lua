return {
  "nanozuki/tabby.nvim",
  config = function()
    require("tabby").setup({
      preset = "active_tab_with_wins",
    })
  end,
}
