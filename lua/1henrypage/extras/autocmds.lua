--[[
-- Stolen from loctvl842/nvim
--
-- Generic information. Autocmds that are specific to things like lsp's are defined in their specific modules
--]]

local Utils = require("1henrypage.utils")
local Colors = require("1henrypage.extras").colors

-- Turn off paste mode when leaving insert so that formatting issues are not prevelant.
vim.api.nvim_create_autocmd("InsertLeave", {
  command = "set nopaste",
  pattern = "*",
})

-- highlight yanks
vim.api.nvim_create_autocmd("TextYankPost", {
  group = Utils.augroup("highlight_yanks"),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- resize splits to equal sizes if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = Utils.augroup("resize_splits"),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Set wrap and spell in markdown and gitcommit
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = Utils.augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
})

-- Make sure when carriage return is pressed on a comment line, it doesn't bring the comment down unless it's a leader`j
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = Utils.augroup("comment_newline"),
  pattern = { "*" },
  callback = function()
    vim.cmd([[set formatoptions-=cro]])
  end,
})

-- custom titlestring
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "" },
  callback = function()
    local get_project_dir = function()
      local cwd = vim.fn.getcwd()
      local project_dir = vim.split(cwd, "/")
      local project_name = project_dir[#project_dir]
      return project_name
    end

    vim.opt.titlestring = get_project_dir()
  end,
})

-- Move help to the right
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "help" },
  callback = function()
    vim.cmd([[wincmd L]])
  end,
})

-- Hide stuff in terminal and auto-enter insert mode
vim.api.nvim_create_autocmd("TermOpen", {
  group = Utils.augroup("terminal"),
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.foldcolumn = "0"
    vim.defer_fn(function()
      if vim.bo[0].buftype == "terminal" then
        vim.cmd("startinsert")
      end
    end, 100)
  end,
})

-- clear cmd output
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  group = Utils.augroup("clear_term"),
  callback = function()
    vim.cmd([[echon '']])
  end,
})

-- Auto-create parent directories when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = Utils.augroup("auto_create_dir"),
  callback = function(event)
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- funny cursor business thing
local insert_cursorline_group = Utils.augroup("insert_cursorline")
vim.api.nvim_create_autocmd("InsertEnter", {
  group = insert_cursorline_group,
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", { bg = Colors.insert_cursorline, ctermbg = 23 })
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = insert_cursorline_group,
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", {})
  end,
})
