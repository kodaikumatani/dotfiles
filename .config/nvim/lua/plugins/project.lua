return {
  "ahmedkhalf/project.nvim",
  config = function()
    -- vim.lsp.buf_get_clients() is deprecated; patch project.nvim to use the new API
    local project = require("project_nvim.project")
    local orig = project.find_lsp_root
    project.find_lsp_root = function()
      -- Temporarily redirect deprecated call
      local orig_buf_get_clients = vim.lsp.buf_get_clients
      vim.lsp.buf_get_clients = function(bufnr)
        return vim.lsp.get_clients({ bufnr = bufnr or 0 })
      end
      local result = orig()
      vim.lsp.buf_get_clients = orig_buf_get_clients
      return result
    end

    require("project_nvim").setup({
      -- プロジェクトルートの検出パターン
      patterns = { ".git", "package.json", "go.mod", "Cargo.toml", "pyproject.toml", "Makefile" },
      -- lsp のルートも使う
      detection_methods = { "lsp", "pattern" },
    })
    require("telescope").load_extension("projects")
  end,
}
