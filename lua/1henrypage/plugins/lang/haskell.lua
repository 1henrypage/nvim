return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "haskell" } },
  },

  {
    "mrcjkb/haskell-tools.nvim",
    version = "3.1.6",
    ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
  },
}
