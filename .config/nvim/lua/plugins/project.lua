return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      -- プロジェクトルートの検出パターン
      patterns = { ".git", "package.json", "go.mod", "Cargo.toml", "pyproject.toml", "Makefile" },
      -- lsp のルートも使う
      detection_methods = { "lsp", "pattern" },
    })
    require("telescope").load_extension("projects")
  end,
}
