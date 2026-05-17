local group = vim.api.nvim_create_augroup("user_config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight yanked text",
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = group,
  desc = "Check if buffers changed outside Neovim",
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  desc = "Restore last cursor position",
  callback = function(event)
    local exclude = { gitcommit = true }
    if exclude[vim.bo[event.buf].filetype] or vim.b[event.buf].last_loc_restored then
      return
    end
    vim.b[event.buf].last_loc_restored = true
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(event.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  desc = "Create parent directories on save",
  callback = function(event)
    if event.match:match([[^%w%w+://]]) then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "help", "man", "qf", "query", "checkhealth" },
  desc = "Close utility windows with q",
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, nowait = true })
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = group,
  pattern = { "*.jsonl", "*.ndjson" },
  desc = "Detect JSON Lines files",
  callback = function(event)
    vim.bo[event.buf].filetype = "jsonl"
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  desc = "Resize splits when terminal size changes",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})
