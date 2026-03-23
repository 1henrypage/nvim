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
      vim.keymap.set("n", "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle Markdown Render" })
    end,
  },
}
