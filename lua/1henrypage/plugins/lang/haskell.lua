return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "haskell" } },
  },

  {
    "mrcjkb/haskell-tools.nvim",
    version = "^11",
    -- lazy-loads itself per filetype (:h lua-plugin-lazy); upstream asks not to lazy-load it.
    lazy = false,
  },
}
