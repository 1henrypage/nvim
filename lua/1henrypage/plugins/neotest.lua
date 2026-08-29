return {
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-neotest/nvim-nio", "nvim-treesitter/nvim-treesitter" },
    opts_extend = { "adapters" },
    opts = { adapters = {} },
    config = function(_, opts)
      local adapters = {}
      for _, name in ipairs(opts.adapters) do
        table.insert(adapters, require(name))
      end
      require("neotest").setup(vim.tbl_extend("force", opts, { adapters = adapters }))
    end,
    keys = {
      {
        "<leader>Tt",
        function()
          require("neotest").run.run()
        end,
        desc = "run nearest test",
      },
      {
        "<leader>Tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "run current file",
      },
      {
        "<leader>Ta",
        function()
          require("neotest").run.run(vim.fn.getcwd())
        end,
        desc = "run all",
      },
      {
        "<leader>Td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "debug nearest",
      },
      {
        "<leader>Ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "toggle summary",
      },
      {
        "<leader>To",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "show output",
      },
      {
        "<leader>TO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "toggle output panel",
      },
      {
        "<leader>TS",
        function()
          require("neotest").run.stop()
        end,
        desc = "stop",
      },
    },
  },
}
