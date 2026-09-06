local Colors = require("1henrypage.extras").colors

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "storm",
      transparent = true,
      terminal_colors = true,
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
      ---@param hl Highlights
      ---@param c ColorScheme
      on_highlights = function(hl, c)
        -- fzf-lua: visible borders, colored title badges
        hl.FzfLuaNormal = { bg = c.bg_dark, fg = c.fg_dark }
        hl.FzfLuaBorder = { bg = c.bg_dark, fg = c.blue }
        hl.FzfLuaTitle = { bg = c.blue, fg = c.bg_dark, bold = true }
        hl.FzfLuaPreviewNormal = { bg = c.bg_dark, fg = c.fg_dark }
        hl.FzfLuaPreviewBorder = { bg = c.bg_dark, fg = c.blue }
        hl.FzfLuaPreviewTitle = { bg = c.green, fg = c.bg_dark, bold = true }
        hl.FzfLuaCursorLine = { bg = Colors.picker_cursorline }
        -- Neo-tree: deep dark sidebar, darker than editor
        hl.NeoTreeNormal = { bg = Colors.bg_deep, fg = c.fg_dark }
        hl.NeoTreeNormalNC = { bg = Colors.bg_deep, fg = c.fg_dark }
        hl.NeoTreeWinSeparator = { fg = Colors.bg_deep, bg = Colors.bg_deep }
        hl.NeoTreeEndOfBuffer = { bg = Colors.bg_deep, fg = Colors.bg_deep }
        hl.NeoTreeStatusLine = { bg = Colors.bg_deep, fg = Colors.bg_deep }
        hl.NeoTreeStatusLineNC = { bg = Colors.bg_deep, fg = Colors.bg_deep }
        -- Mellow yellow indent guides
        hl.NeoTreeIndentMarker = { fg = Colors.indent_marker }
        hl.NeoTreeExpander = { fg = Colors.expander }
        -- Mini.notify: dark bg, blue border
        hl.MiniNotifyNormal = { bg = Colors.bg_deep, fg = c.fg }
        hl.MiniNotifyBorder = { fg = Colors.blue }
        hl.MiniNotifyTitle = { fg = Colors.blue, bold = true }
        -- Mini.cursorword: blue underline
        hl.MiniCursorword = { underline = true, sp = Colors.blue }
        hl.MiniCursorwordCurrent = { underline = true, sp = Colors.blue }
        -- Mini.indentscope: blue scope line
        hl.MiniIndentscopeSymbol = { fg = Colors.blue }
      end,
    },
    config = function(_, opts)
      local tokyonight = require("tokyonight")
      tokyonight.setup(opts)
      tokyonight.load()
    end,
  },
}
