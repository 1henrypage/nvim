return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_line_blame = true,
      signs = {
        add = { text = "▋" },
        change = { text = "▋" },
        delete = { text = "▋" },
        topdelete = { text = "▋" },
        changedelete = { text = "▋" },
        untracked = { text = "▋" },
      },
    },
    config = function(_, opts)
      local Colors = require("1henrypage.extras").colors
      local gs = require("gitsigns")
      gs.setup(opts)

      vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = Colors.git_add, bold = true })
      vim.api.nvim_set_hl(0, "GitSignsChange", { fg = Colors.blue, bold = true })
      vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = Colors.git_delete, bold = true })

      vim.keymap.set("n", "<leader>hj", gs.next_hunk, { desc = "Next git hunk" })
      vim.keymap.set("n", "<leader>hk", gs.prev_hunk, { desc = "Prev git hunk" })
      vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
      vim.keymap.set("n", "<leader>hB", gs.toggle_current_line_blame, { desc = "Toggle inline blame" })

      vim.keymap.set("n", "<leader>hd", gs.diffthis, { desc = "Diff file (vs index)" })
      vim.keymap.set("n", "<leader>hD", function()
        gs.diffthis("~")
      end, { desc = "Diff file (vs last commit)" })
      vim.keymap.set("n", "<leader>hw", gs.preview_hunk, { desc = "Preview hunk" })

      vim.keymap.set({ "o", "x" }, "ih", ":<C-u>Gitsigns select_hunk<CR>", { desc = "Inside hunk" })
    end,
  },
}
