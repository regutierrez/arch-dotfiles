return {
  {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    event = { "BufWritePre" },
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      format_on_save = function(bufnr)
        if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
          return
        end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        javascript = { "oxfmt" },
        javascriptreact = { "oxfmt" },
        typescript = { "oxfmt" },
        typescriptreact = { "oxfmt" },
        json = { "oxfmt" },
        jsonc = { "oxfmt" },
        jsonl = { "jq_jsonl" },
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
        go = { "goimports", "gofumpt" },
      },
      formatters = {
        jq_jsonl = {
          command = "jq",
          args = { "-c", "." },
          stdin = true,
        },
      },
    },
  },
}
