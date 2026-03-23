return {
  -- Status Column
  {
    "luukvbaal/statuscol.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = false,
        ft_ignore = { "no-tree" },
        segments = {
          {
            -- line number
            text = { " ", builtin.lnumfunc },
            condition = { true, builtin.not_empty },
            click = "v:lua.ScLa",
          },
          { text = { "%s" }, click = "v:lua.ScSa" }, -- Sign
          { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" }, -- Fold
        },
      })
      vim.api.nvim_create_autocmd({ "BufEnter" }, {
        callback = function()
          if vim.bo.filetype == "neo-tree" then
            vim.opt_local.statuscolumn = ""
          end
        end,
      })
    end,
  },

  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "enter" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        ghost_text = { enabled = true },
        menu = { border = "rounded" },
      },
      signature = { enabled = true },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
      cmdline = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
  {

    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    opts = {
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    },
    config = function(_, opts)
      require("ufo").setup(opts)
      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>s", group = "search" },
        { "<leader>g", group = "goto/lsp" },
        { "<leader>gw", group = "workspace" },
        { "<leader>t", group = "toggle" },
        { "<leader>tt", desc = "neotree" },
        { "<leader>t<Tab>", desc = "terminal" },
        { "<leader>tw", desc = "wrap" },
        { "<leader>tr", desc = "relative numbers" },
        { "<leader>ts", desc = "spell" },
        { "<leader>tc", desc = "conceal" },
        { "<leader>th", desc = "inlay hints" },
        { "<leader>w", group = "window" },
        { "<leader>c", group = "code" },
        { "<leader>h", group = "git" },
        { "<leader>d", group = "debug" },
        { "<leader>x", group = "diagnostics" },
        { "<leader>b", group = "buffer" },
        { "<leader>.", group = "utilities" },
        { "<leader>r", desc = "rename" },
        { "<leader>J", desc = "split/join" },
      },
    },
  },
}
