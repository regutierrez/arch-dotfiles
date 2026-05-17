return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-mini/mini.icons",
    },
    keys = {
      {
        "<leader>fe",
        function() vim.cmd.Neotree({ "toggle", "dir=" .. require("config.util").root() }) end,
        desc = "Explorer NeoTree (root dir)",
      },
      {
        "<leader>fE",
        function() vim.cmd.Neotree({ "toggle", "dir=" .. vim.uv.cwd() }) end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      source_selector = {
        winbar = true,
        content_layout = "center",
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = false,
          ["h"] = "close_node",
          ["l"] = "open",
        },
      },
    },
  },
}
