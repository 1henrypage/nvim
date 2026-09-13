local M = {}

local excluded_filetypes = {
  aerial = true,
  blame = true,
  lazy = true,
  mason = true,
  ["neo-tree"] = true,
  qf = true,
  trouble = true,
}

local function escape_statusline(text)
  return text:gsub("%%", "%%%%")
end

function M.get()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= "" or excluded_filetypes[vim.bo[bufnr].filetype] then
    return ""
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return ""
  end

  local path = vim.fn.fnamemodify(name, ":~:.")
  path = escape_statusline(path):gsub("/", "%%#NavicSeparator# › %%*%%#WinBarFile#")
  local result = "%#WinBarFile# " .. path .. " %*"

  local ok, navic = pcall(require, "nvim-navic")
  if ok and navic.is_available(bufnr) then
    local location = navic.get_location()
    if location ~= "" then
      result = result .. "%#NavicSeparator# › %*" .. location .. " "
    end
  end

  return result
end

return M
