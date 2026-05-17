local M = {}

M.icons = {
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  },
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },
  kinds = {
    Text = " ",
    Method = "󰊕 ",
    Function = "󰊕 ",
    Constructor = " ",
    Field = " ",
    Variable = "󰀫 ",
    Class = " ",
    Interface = " ",
    Module = " ",
    Property = " ",
    Unit = " ",
    Value = " ",
    Enum = " ",
    Keyword = " ",
    Snippet = "󱄽 ",
    Color = " ",
    File = " ",
    Reference = " ",
    Folder = " ",
    EnumMember = " ",
    Constant = "󰏿 ",
    Struct = "󰆼 ",
    Event = " ",
    Operator = " ",
    TypeParameter = " ",
  },
}

---@param buf? integer
function M.lsp_root(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = buf })
  for _, client in ipairs(clients) do
    if client.name ~= "copilot" then
      local root = client.config.root_dir or (client.workspace_folders and client.workspace_folders[1] and vim.uri_to_fname(client.workspace_folders[1].uri))
      if root and root ~= "" then
        return vim.fs.normalize(root)
      end
    end
  end
end

---@param buf? integer
function M.root(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local lsp_root = M.lsp_root(buf)
  if lsp_root then
    return lsp_root
  end
  local name = vim.api.nvim_buf_get_name(buf)
  local source = name ~= "" and name or vim.uv.cwd()
  return vim.fs.root(source, { ".git", "lua" }) or vim.uv.cwd()
end

---@param buf? integer
function M.git_root(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local source = name ~= "" and name or vim.uv.cwd()
  return vim.fs.root(source, ".git") or M.root(buf)
end

function M.toggle_option(option, on, off)
  return function()
    local current = vim.opt[option]:get()
    if current == on then
      vim.opt[option] = off
    else
      vim.opt[option] = on
    end
  end
end

function M.statuscolumn()
  local ok, statuscolumn = pcall(require, "snacks.statuscolumn")
  return ok and statuscolumn.get() or ""
end

_G.UserStatuscolumn = M.statuscolumn

return M
