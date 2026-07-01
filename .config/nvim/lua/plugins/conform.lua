return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      go = { "gofmt" }, -- Go ツールチェーン同梱（LSP 非依存）
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
    },
    format_on_save = {
      timeout_ms = 3000,
    },
  },
}
