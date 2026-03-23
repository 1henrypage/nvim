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
			---@param colors ColorScheme
			on_colors = function(colors) end,

			---@param hl Highlights
			---@param c ColorScheme
			on_highlights = function(hl, c)
				local prompt = "#2d3149"
				-- Telescope: visible borders, colored title badges
				hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg_dark }
				hl.TelescopeBorder = { bg = c.bg_dark, fg = c.blue }
				hl.TelescopePromptNormal = { bg = prompt }
				hl.TelescopePromptBorder = { bg = prompt, fg = c.blue }
				hl.TelescopePromptTitle = { bg = c.blue, fg = c.bg_dark, bold = true }
				hl.TelescopePreviewTitle = { bg = c.green, fg = c.bg_dark, bold = true }
				hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.bg_dark }
				-- Neo-tree: deep dark sidebar, darker than editor
				local neo_bg = "#13141e"
				hl.NeoTreeNormal = { bg = neo_bg, fg = c.fg_dark }
				hl.NeoTreeNormalNC = { bg = neo_bg, fg = c.fg_dark }
				hl.NeoTreeWinSeparator = { fg = neo_bg, bg = neo_bg }
				hl.NeoTreeEndOfBuffer = { bg = neo_bg, fg = neo_bg }
				hl.NeoTreeStatusLine = { bg = neo_bg, fg = neo_bg }
				hl.NeoTreeStatusLineNC = { bg = neo_bg, fg = neo_bg }
				-- Mellow yellow indent guides
				hl.NeoTreeIndentMarker = { fg = "#5a4e2e" }
				hl.NeoTreeExpander = { fg = "#7a6830" }
				end,
		},
		config = function(_, opts)
			local tokyonight = require("tokyonight")
			tokyonight.setup(opts)
			tokyonight.load()
		end,
	},
}
