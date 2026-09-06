local Util = require("1henrypage.utils")

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    event = "VeryLazy",
    keys = {
      {
        "<leader>sn",
        function()
          Util.picker.smart_files()
        end,
        desc = "find files",
      },
      {
        "<leader>sf",
        function()
          require("fzf-lua").live_grep_glob()
        end,
        desc = "live grep",
      },
      {
        "<leader>sb",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "buffers",
      },
      {
        "<leader>ss",
        function()
          require("fzf-lua").lsp_document_symbols()
        end,
        desc = "document symbols",
      },
      {
        "<leader>so",
        function()
          require("fzf-lua").oldfiles()
        end,
        desc = "recent files",
      },
      {
        "<leader>sw",
        function()
          require("fzf-lua").grep_cword()
        end,
        desc = "grep word",
      },
    },
    config = function()
      local fzf = require("fzf-lua")
      fzf.setup({
        winopts = {
          height = 0.80,
          width = 0.87,
          border = "rounded",
          preview = { layout = "flex", flip_columns = 120, horizontal = "right:55%" },
        },
        files = { hidden = true },
        git = { files = { cmd = "git ls-files --exclude-standard --cached --others" } },
        -- builtin previewer's treesitter highlighting crashes on some buffers
        previewers = { builtin = { treesitter = { enabled = false } } },
        grep = {
          rg_glob = true,
          -- --color=always and trailing -e are required: fzf-lua parses rg's
          -- output format, and without them Enter fails to open the match
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden -e",
        },
      })
      fzf.register_ui_select()
    end,
  },
}
