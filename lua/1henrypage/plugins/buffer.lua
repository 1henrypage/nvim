local Profile = require("1henrypage.profile")
local Icons = require("1henrypage.extras").icons
local Colors = require("1henrypage.extras").colors

return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    config = function()
      local bufferline = require("bufferline")
      bufferline.setup({
        options = {
          style_preset = bufferline.style_preset.no_italic,
          -- Buffer Icons config
          modified_icon = Icons.git.modified,
          close_icon = "󰅖",
          left_trunc_marker = Icons.borders.thin.left,
          right_trunc_marker = Icons.borders.thin.right,

          mode = "buffers",
          themable = true,
          diagnostics = "nvim_lsp",
          diagnostics_update_on_event = true,
          diagnostics_indicator = function(_count, _level, diagnostics_dict, _context)
            local parts = {}
            if diagnostics_dict.error then
              table.insert(parts, Icons.diagnostics.error .. " " .. diagnostics_dict.error)
            end
            if diagnostics_dict.warning then
              table.insert(parts, Icons.diagnostics.warn .. " " .. diagnostics_dict.warning)
            end
            return table.concat(parts, " ")
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = Profile.name,
              text_align = "center",
              separator = false,
            },
          },
          color_icons = true,
          show_buffer_icons = true,
          separator_style = "slant",
          always_show_bufferline = true,
          sort_by = function(buffer_a, buffer_b)
            local modified_a = vim.fn.getftime(buffer_a.path)
            local modified_b = vim.fn.getftime(buffer_b.path)
            return modified_a > modified_b
          end,
          hover = {
            enabled = true,
            delay = 100,
            reveal = {},
          },
          groups = {
            options = {
              toggle_hidden_on_enter = true,
            },
            items = {
              require("bufferline.groups").builtin.pinned:with({ icon = Icons.bufferline.pinned .. " " }),
            },
          },
        },
        highlights = {
          fill = { bg = Colors.dark1 },

          background = { bg = Colors.dark2, fg = Colors.dimmed3 },
          buffer_visible = { bg = Colors.terminal, fg = Colors.dimmed2 },

          buffer_selected = { bg = Colors.background, fg = Colors.text, bold = true },

          separator = { fg = Colors.dark1, bg = Colors.dark2 },
          separator_visible = { fg = Colors.dark1, bg = Colors.terminal },
          separator_selected = { fg = Colors.dark1, bg = Colors.background },

          close_button = { fg = Colors.dimmed3, bg = Colors.dark2 },
          close_button_visible = { fg = Colors.dimmed3, bg = Colors.terminal },
          close_button_selected = { fg = Colors.red, bg = Colors.background },

          modified = { fg = Colors.orange, bg = Colors.dark2 },
          modified_visible = { fg = Colors.orange, bg = Colors.terminal },
          modified_selected = { fg = Colors.orange, bg = Colors.background },
        },
      })

      vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "pin" })
      vim.keymap.set("n", "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", { desc = "close others" })
      vim.keymap.set("n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "close left" })
      vim.keymap.set("n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "close right" })
      vim.keymap.set("n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "close unpinned" })
      vim.keymap.set("n", "<leader>bs", "<Cmd>BufferLinePick<CR>", { desc = "pick" })
      vim.keymap.set("n", "<leader>bS", "<Cmd>BufferLinePickClose<CR>", { desc = "pick close" })

      for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, function()
          require("bufferline").go_to(i)
        end, {})
      end

      vim.keymap.set("n", "<leader>0", function()
        require("bufferline").go_to(-1)
      end, {})
    end,
  },
}
