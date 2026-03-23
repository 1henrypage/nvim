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
        -- Telescope: visible borders, colored title badges
        hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg_dark }
        hl.TelescopeBorder = { bg = c.bg_dark, fg = c.blue }
        hl.TelescopePromptNormal = { bg = Colors.prompt_bg }
        hl.TelescopePromptBorder = { bg = Colors.prompt_bg, fg = c.blue }
        hl.TelescopePromptTitle = { bg = c.blue, fg = c.bg_dark, bold = true }
        hl.TelescopePreviewTitle = { bg = c.green, fg = c.bg_dark, bold = true }
        hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.bg_dark }
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
