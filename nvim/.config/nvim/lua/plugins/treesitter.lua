return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    build = function()
      local ok, ts = pcall(require, "nvim-treesitter")
      if ok and ts.update then
        ts.update(nil, { summary = true })
      end
    end,
    event = { "BufReadPost", "BufNewFile", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts = {
      install_dir = vim.fn.stdpath("data") .. "/site",
      ensure_installed = {
        "bash",
        "c",
        "css",
        "diff",
        "dockerfile",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      highlight = { enable = true },
      indent = { enable = true },
      folds = { enable = true },
    },
    config = function(_, opts)
      local ts = require("nvim-treesitter")
      ts.setup(opts)

      local installed = {}
      if ts.get_installed then
        for _, lang in ipairs(ts.get_installed()) do
          installed[lang] = true
        end
        local missing = vim.tbl_filter(function(lang)
          return not installed[lang]
        end, opts.ensure_installed or {})
        if #missing > 0 and #vim.api.nvim_list_uis() > 0 then
          ts.install(missing, { summary = true })
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(event)
          local ft = event.match
          local lang = vim.treesitter.language.get_lang(ft)
          if not lang then
            return
          end
          local ok = pcall(vim.treesitter.start, event.buf, lang)
          if ok then
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            if vim.treesitter.foldexpr then
              vim.wo.foldmethod = "expr"
              vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            end
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      move = {
        enable = true,
        set_jumps = true,
        keys = {
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      local ts = require("nvim-treesitter-textobjects")
      ts.setup(opts)
      local function attach(buf)
        local moves = opts.move.keys or {}
        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            vim.keymap.set({ "n", "x", "o" }, key, function()
              require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
            end, { buffer = buf, silent = true, desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. query })
          end
        end
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter_textobjects", { clear = true }),
        callback = function(event) attach(event.buf) end,
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "BufReadPost",
    opts = {},
  },
}
