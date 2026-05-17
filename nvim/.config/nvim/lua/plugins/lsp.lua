local icons = require("config.util").icons

local lsp_servers = {
  "lua_ls",
  "bashls",
  "jsonls",
  "yamlls",
  "marksman",
  "vtsls",
  "oxlint",
  "ty",
  "ruff",
  "gopls",
  "dockerls",
  "docker_compose_language_service",
}

local mason_tools = {
  "stylua",
  "shfmt",
  "jq",
  "oxfmt",
  "gofumpt",
  "goimports",
}

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = mason_tools,
    },
    config = function(_, opts)
      require("mason").setup(opts)
      if #vim.api.nvim_list_uis() == 0 then
        return
      end
      local mr = require("mason-registry")
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed or {}) do
          local ok, pkg = pcall(mr.get_package, tool)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function() end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "b0o/SchemaStore.nvim",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", {
        capabilities = capabilities,
        root_markers = { ".git" },
      })

      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            codeLens = { enable = true },
            completion = { callSnippet = "Replace" },
            doc = { privateName = { "^_" } },
            hint = {
              enable = true,
              setType = false,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
            validate = true,
          },
        },
      })

      vim.lsp.config("vtsls", {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = { enableServerSideFuzzyMatch = true },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
          javascript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      })

      vim.lsp.config("oxlint", {
        settings = { fixKind = "all" },
      })

      vim.lsp.config("ruff", {
        init_options = { settings = { logLevel = "error" } },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
          local buf = event.buf
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or "n", keys, func, { buffer = buf, desc = desc })
          end
          map("<leader>cl", "<cmd>LspInfo<cr>", "Lsp Info")
          map("gd", vim.lsp.buf.definition, "Goto Definition")
          map("gr", vim.lsp.buf.references, "References")
          map("gI", vim.lsp.buf.implementation, "Goto Implementation")
          map("gy", vim.lsp.buf.type_definition, "Goto T[y]pe Definition")
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("K", vim.lsp.buf.hover, "Hover")
          map("gK", vim.lsp.buf.signature_help, "Signature Help")
          map("<c-k>", vim.lsp.buf.signature_help, "Signature Help", "i")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>cR", function() Snacks.rename.rename_file() end, "Rename File")
          map("]]", function() Snacks.words.jump(vim.v.count1) end, "Next Reference")
          map("[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev Reference")
          if client:supports_method("textDocument/inlayHint", buf) then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
          end
        end,
      })

      -- mason-lspconfig will enable installed servers automatically in interactive sessions.
      local interactive = #vim.api.nvim_list_uis() > 0
      require("mason-lspconfig").setup({
        ensure_installed = interactive and lsp_servers or {},
        automatic_enable = interactive,
      })
    end,
  },
}
