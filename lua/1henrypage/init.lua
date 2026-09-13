local M = {}

function M.assemble()
  local Extras = require("1henrypage.extras")
  Extras.setup()
  Extras.init()
  vim.cmd.colorscheme("ristretto")
  require("1henrypage.lazy")
end

return M
