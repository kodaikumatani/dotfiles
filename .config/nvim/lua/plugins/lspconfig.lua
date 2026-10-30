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

-- source.organizeImports のコードアクションを同期実行する（未解決なら resolve してから適用）
local function organize_imports(client, bufnr)
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = { only = { "source.organizeImports" }, diagnostics = {} }

  local res = client:request_sync("textDocument/codeAction", params, 3000, bufnr)
  for _, action in ipairs(res and res.result or {}) do
    if not action.edit and action.data then
      local resolved = client:request_sync("codeAction/resolve", action, 3000, bufnr)
      action = resolved and resolved.result or action
    end
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    elseif action.command then
      client:exec_cmd(action.command, { bufnr = bufnr })
    end
  end
end

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

      -- 診断表示：virtual_text は行末に収まらず途切れるので、
      -- カーソル行だけ virtual_lines（行の下に折り返して全文表示）にする
      vim.diagnostic.config({
        -- 既定（false）だと Insert 中は診断が更新されず、直したエラーが InsertLeave まで残る
        update_in_insert = true,
        virtual_text = false,
        virtual_lines = { current_line = true },
        severity_sort = true,
        underline = true,
        -- サインは gitsigns（sign_priority = 6）より低くする。優先度の高い方が
        -- signcolumn の左側を取るので、git の変更バーが常に左端で固定される
        signs = { priority = 2 },
      })

      -- LSP がアタッチしたバッファだけに適用（言語非依存）
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          -- 定義ジャンプの既定は無いので gd だけ追加（<C-]> でも可）
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
          -- K / grn / gra / grr / gri / grt / gO / <C-W>d / [d ]d / <C-S> は Neovim 0.11 既定

          -- 0.11 ネイティブ補完を自動トリガで有効化（nvim-cmp 不要）
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end
          if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
          end

          -- 保存時に import を自動整理（gopls / ts_ls など対応サーバーのみ・言語非依存）
          local kinds = vim.tbl_get(client, "server_capabilities", "codeActionProvider", "codeActionKinds") or {}
          if vim.tbl_contains(kinds, "source.organizeImports") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                organize_imports(client, args.buf)
              end,
            })
          end
        end,
      })
    end,
  },
}
