local M = {}

--- git_files inside a repo (scoped to cwd, so opening nvim in a subdirectory
--- searches that subtree), plain fd-based files otherwise.
function M.smart_files()
  local fzf = require("fzf-lua")
  if vim.fs.root(0, ".git") then
    fzf.git_files({ cwd = vim.fn.getcwd() })
  else
    fzf.files()
  end
end

return M
