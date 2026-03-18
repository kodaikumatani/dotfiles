return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      -- Mason で formatter を自動インストール
      local ensure_installed = { "yamlfmt" }
      local registry = require("mason-registry")
      for _, name in ipairs(ensure_installed) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and not pkg:is_installed() and not pkg:is_installing() then
          pkg:install()
        end
      end

      require("conform").setup({
        formatters_by_ft = {
          go = { lsp_format = "prefer" },
          yaml = { "yamlfmt" },
        },
        format_on_save = {
          timeout_ms = 3000,
          lsp_format = "fallback",
        },
      })
    end,
  },
}
