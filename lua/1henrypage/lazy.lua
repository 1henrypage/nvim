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
        version = "*", -- latest stable version
        lazy = false,
    },
    install = {colorscheme = {"tokyonight"}},
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
                -- "matchit",
                --         "matchparen",
                --         "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
