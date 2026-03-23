return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			close_if_last_window = false,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			default_component_configs = {
				indent = {
					indent_size = 2,
					padding = 1,
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					highlight = "NeoTreeIndentMarker",
					with_expanders = true,
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
			},
			sources = { "filesystem", "buffers", "git_status" },
			window = {
				width = 36,
			},
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)
			vim.keymap.set("n", "<leader>t", ":Neotree toggle<CR>", {})
		end,
	},
}
