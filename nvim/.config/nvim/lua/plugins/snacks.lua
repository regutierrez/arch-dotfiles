return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
     ███╗   ██╗██╗   ██╗██╗███╗   ███╗
     ████╗  ██║██║   ██║██║████╗ ████║
     ██╔██╗ ██║██║   ██║██║██╔████╔██║
     ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
     ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
     ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
          ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua require('fff').find_files()" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua require('fff').live_grep()" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      indent = { enabled = true },
      input = { enabled = true },
      image = { enabled = true, doc = { enabled = false } },
      notifier = { enabled = true, timeout = 3000 },
      picker = { enabled = true, ui_select = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = false },
      words = { enabled = true },
      explorer = { enabled = false },
      zen = { enabled = false },
      profiler = { enabled = false },
    },
    keys = {
      { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<leader>gB", function() Snacks.gitbrowse() end, mode = { "n", "x" }, desc = "Git Browse (open)" },
      { "<leader>gY", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, mode = { "n", "x" }, desc = "Git Browse (copy)" },
      { "<leader>gg", function() Snacks.lazygit({ cwd = require("config.util").git_root() }) end, desc = "Lazygit (Root Dir)" },
      { "<leader>gG", function() Snacks.lazygit() end, desc = "Lazygit (cwd)" },
    },
  },
}
