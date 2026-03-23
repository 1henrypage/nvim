return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{
				"nvim-telescope/telescope-live-grep-args.nvim",
				version = "^1.0.0",
			},
			{
				"debugloop/telescope-undo.nvim",
			},
			{
				"nvim-telescope/telescope-ui-select.nvim",
			},
		},
		opts = function()
			return {
				defaults = {
					dynamic_preview_title = true,
					hl_result_eol = true,
					sorting_strategy = "ascending",
					borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
					file_ignore_patterns = {
						".git/",
						"target/",
						"docs/",
						"vendor/*",
						"%.lock",
						"__pycache__/*",
						"%.sqlite3",
						"node_modules/*",
						-- "%.jpg",
						-- "%.jpeg",
						-- "%.png",
						"%.svg",
						"%.otf",
						"%.ttf",
						"%.webp",
						".dart_tool/",
						".github/",
						".gradle/",
						".idea/",
						".settings/",
						".vscode/",
						"__pycache__/",
						"build/",
						"gradle/",
						"node_modules/",
						"%.pdb",
						"%.dll",
						"%.class",
						"%.exe",
						"%.cache",
						"%.ico",
						"%.pdf",
						"%.dylib",
						"%.jar",
						"%.docx",
						"%.met",
						"smalljre_*/*",
						".vale/",
						"%.burp",
						"%.mp4",
						"%.mkv",
						"%.rar",
						"%.7z",
						"%.tar",
						"%.bz2",
						"%.epub",
						"%.flac",
						"%.tar.gz",
					},
					results_title = "",
					layout_strategy = "flex",
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
						},
						vertical = {
							mirror = true,
							prompt_position = "top",
						},
						flex = {
							flip_columns = 120,
						},
						width = 0.87,
						height = 0.80,
					},
				},
			}
		end,
		config = function(_, opts)
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>sn", builtin.find_files, {})
			vim.keymap.set(
				"n",
				"<leader>sf",
				'<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>'
			)
			vim.keymap.set("n", "<leader>sb", builtin.buffers, {})
			vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, {})
			vim.keymap.set("n", "<leader>so", builtin.oldfiles, {})
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, {})
			vim.keymap.set("n", "<leader>su", "<cmd>Telescope undo<cr>")
			telescope.setup(opts)
			telescope.load_extension("undo")
			telescope.load_extension("live_grep_args")
			telescope.load_extension("ui-select")
		end,
	},
}
