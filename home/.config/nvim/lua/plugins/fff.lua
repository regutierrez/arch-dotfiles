local function fff_rooted(call)
  return function()
    local fff = require("fff")
    pcall(fff.change_indexing_directory, require("config.util").root())
    call(fff)
  end
end

return {
  {
    "dmtrKovalenko/fff",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    lazy = false,
    opts = {
      lazy_sync = true,
      max_results = 100,
      prompt = "> ",
      title = "FFFiles",
      preview = {
        enabled = true,
        line_numbers = false,
        wrap_lines = false,
      },
      frecency = { enabled = true },
      history = { enabled = true },
      grep = {
        smart_case = true,
        modes = { "plain", "regex", "fuzzy" },
      },
      debug = { enabled = false, show_scores = false },
    },
    keys = {
      { "<leader><space>", fff_rooted(function(fff) fff.find_files() end), desc = "Find Files (Root Dir)" },
      { "<leader>ff", fff_rooted(function(fff) fff.find_files() end), desc = "Find Files (Root Dir)" },
      { "<leader>fF", function() require("fff").find_files() end, desc = "Find Files (cwd)" },
      { "<leader>fg", fff_rooted(function(fff) fff.find_files() end), desc = "Find Files (gitignored respected)" },
      { "<leader>/", fff_rooted(function(fff) fff.live_grep() end), desc = "Grep (Root Dir)" },
      { "<leader>sg", fff_rooted(function(fff) fff.live_grep() end), desc = "Grep (Root Dir)" },
      { "<leader>sG", function() require("fff").live_grep() end, desc = "Grep (cwd)" },
      { "<leader>sw", fff_rooted(function(fff) fff.live_grep({ query = vim.fn.expand("<cword>") }) end), mode = { "n", "x" }, desc = "Search Word (Root Dir)" },
      { "<leader>sW", function() require("fff").live_grep({ query = vim.fn.expand("<cword>") }) end, mode = { "n", "x" }, desc = "Search Word (cwd)" },
      { "<leader>fz", fff_rooted(function(fff) fff.live_grep({ grep = { modes = { "fuzzy", "plain" } } }) end), desc = "Fuzzy Grep" },
    },
  },
}
