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
    init = function()
      vim.lsp.enable({ "basedpyright", "ruff" })
      vim.lsp.config("basedpyright", {
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
      })
    end,
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
