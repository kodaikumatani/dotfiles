local servers = require("config.lsp-servers")

return {
  -- LSP管理
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = false,
      })
      -- refresh 完了を待たずに即座にインストールを試みる
      local registry = require("mason-registry")
      local mlsp_mappings = require("mason-lspconfig.mappings").get_mason_map()
      for _, server in ipairs(servers) do
        local pkg_name = mlsp_mappings.lspconfig_to_package[server]
        if pkg_name then
          local ok, pkg = pcall(registry.get_package, pkg_name)
          if ok and not pkg:is_installed() and not pkg:is_installing() then
            pkg:install()
          end
        end
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- 診断メッセージをインラインで表示
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })

      -- 診断記号の設定
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- LSPキーマップ
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf, noremap = true, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

          -- Inlay hints を有効化
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })

      -- capabilities設定
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- サーバー固有の設定
      local server_settings = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
                ST1000 = false,
              },
              staticcheck = true,
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        terraformls = {
          filetypes = { "terraform", "hcl" },
        },
      }

      -- 全サーバーを設定・有効化（vim.lsp.enable は対応filetypeのバッファが開かれた時に自動起動する）
      for _, server in ipairs(servers) do
        local config = vim.tbl_deep_extend("force", { capabilities = capabilities }, server_settings[server] or {})
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end

      -- Go: 保存時にimportを整理（フォーマットはconform.nvimに委譲）
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          local clients = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })
          if #clients == 0 then return end
          local client = clients[1]
          local ok, params = pcall(vim.lsp.util.make_range_params, 0, client.offset_encoding)
          if not ok then return end
          params.context = { only = { "source.organizeImports" } }
          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
          for _, res in pairs(result or {}) do
            for _, action in pairs(res.result or {}) do
              if action.edit then
                vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
              end
            end
          end
        end,
      })
    end,
  },
}
