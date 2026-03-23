return {
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    event = "VeryLazy",
    version = "2.*",
    opts = {
      hint = "floating-big-letter",
      filter_rules = {
        include_current_win = true,
        bo = {
          filetype = { "neo-tree", "neo-tree-popup", "notify" },
          buftype = { "quickfix" },
        },
      },
    },
    keys = {
      {
        "<leader>ww",
        function()
          -- Pick the window
          local window_id = require("window-picker").pick_window()

          -- If a window is selected, move the cursor to it
          if window_id then
            vim.api.nvim_set_current_win(window_id)
          end
        end,
        noremap = true,
        silent = true,
      },
    },
  },
}
