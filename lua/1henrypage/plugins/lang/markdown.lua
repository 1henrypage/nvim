return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      latex = { enabled = false },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      vim.keymap.set("n", "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", { desc = "markdown render" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = { ensure_installed = { "marksman" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          -- marksman logs at info to stderr, which Nvim records as [ERROR] lines in lsp.log.
          cmd = { "marksman", "server", "--verbose", "1" },
          -- lspconfig also lists "markdown.mdx", a filetype Nvim never detects (health warns).
          filetypes = { "markdown" },
        },
      },
    },
  },
}
