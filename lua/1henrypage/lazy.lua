local Icons = require("1henrypage.extras").icons

-- bootstrap lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- load
require("lazy").setup({
  spec = {
    { import = "1henrypage.plugins" },
    { import = "1henrypage.plugins.lang" },
  },
  defaults = {
    -- Track each plugin's default branch; lazy-lock.json pins the exact commits. `version = "*"`
    -- left plugins that rarely tag on years-old releases (nvim-jdtls 0.2.0 from 2022, plenary
    -- 0.1.4 from 2023) calling APIs Nvim has since deprecated. Plugins with a real release
    -- train keep an explicit `version` in their own spec.
    version = false,
    lazy = false,
  },
  install = { colorscheme = { "ristretto" } },
  rocks = { enabled = false },
  change_detection = {
    enabled = false,
    notify = false,
  },
  ui = {
    icons = {
      ft = Icons.lazy.ft,
      lazy = Icons.lazy.lazy,
      loaded = Icons.lazy.loaded,
      not_loaded = Icons.lazy.not_loaded,
    },
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
