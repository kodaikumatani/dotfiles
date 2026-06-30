-- LSP: mason が自動インストールし、mason-lspconfig が自動で有効化する。
-- 言語を増やすときは下の servers にサーバー名を足すだけ（言語ごとの設定は不要）。
local servers = {
  "lua_ls",
  "gopls",
  "rust_analyzer",
  "ts_ls",
  "jsonls",
  "yamlls",
  "taplo",
  "html",
  "cssls",
  "dockerls",
  "bashls",
  "terraformls",
}

return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig", -- 各サーバーの既定設定（cmd / root）を提供
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = true, -- インストール済みサーバーを自動で vim.lsp.enable
      })

      -- 診断をインライン表示
      vim.diagnostic.config({ virtual_text = true })

      -- LSP がアタッチしたバッファだけに適用（言語非依存）
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
          -- K(hover) / grn(rename) / gra(code action) / grr(references) は Neovim 0.11 既定

          -- 0.11 ネイティブ補完を自動トリガで有効化（nvim-cmp 不要）
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
          end
        end,
      })
    end,
  },
}
