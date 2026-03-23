local Profile = require("1henrypage.profile")
local Utils = require("1henrypage.utils")
_G.Utils = Utils

local M = {}
setmetatable(M, {
  __index = function(_, k)
    local mod = require("1henrypage.extras." .. k)
    return mod
  end,
})

---@param mod "autocmds" | "options" | "keymaps" | "commands"
M.load = function(mod)
  Utils.try(function()
    require("1henrypage.extras." .. mod)
  end, { msg = "Error loading '" .. mod .. "'" })
  local pattern = "1henrypage" .. mod:sub(1, 1):upper() .. mod:sub(2)

  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

function M.setup()
  local group = vim.api.nvim_create_augroup(Profile.name, { clear = true })
  local no_file = vim.fn.argc(-1) == 0
  -- Lazy load `autocmds` when opening a file
  if not no_file then
    M.load("autocmds")
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    group = group,
    callback = function()
      if no_file then
        M.load("autocmds")
      end
      M.load("keymaps")
    end,
  })
end

M.did_init = false
function M.init()
  -- stylua: ignore
  if M.did_init then return end
  M.did_init = true

  M.load("options")
end

return M
