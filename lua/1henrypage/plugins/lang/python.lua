return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "python" } },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = { ensure_installed = { "basedpyright", "ruff" } },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                exclude = { "**/*.ipynb" },
              },
              inlayHints = {
                callArgumentNames = "all",
                functionReturnTypes = true,
                variableTypes = true,
              },
            },
          },
        },
        -- ruff logs at info to stderr, which Nvim records as [ERROR] lines in lsp.log.
        ruff = { init_options = { settings = { logLevel = "warn" } } },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
      },
    },
  },
}
