
return {
	-- Telescope Settings
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
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
							results_width = 0.8,
						},
						vertical = {
							mirror = false,
						},
						width = 0.87,
						height = 0.80,
						preview_cutoff = 120,
					},
				},
			}
		end,
		config = function(_, opts)
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			-- Load dependencies
			--             require('telescope').load_extension('neoclip')
			--             vim.g.zoxide_use_select = true
			--            require("telescope").load_extension("advanced_git_search")
			--             require("telescope").load_extension("colors")

			-- Telescope associated keymap
			vim.keymap.set("n", "<leader>sn", builtin.find_files, {})
			vim.keymap.set(
				"n",
				"<leader>sf",
				'<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>'
			)
			vim.keymap.set("n", "<leader>sb", builtin.buffers, {}) -- browse buffers
			vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, {}) -- function headers, keywords, etc
			vim.keymap.set("n", "<leader>so", builtin.oldfiles, {}) -- browse old files
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, {})
			vim.keymap.set("n", "<leader>su", "<cmd>Telescope undo<cr>")
			telescope.setup(opts)
			telescope.load_extension("undo")
			telescope.load_extension("live_grep_args")
			telescope.load_extension("ui-select")
		end,
	},

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

	-- Color Theme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "storm",
			transparent = true,
			terminal_colors = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
			--- You can override specific color groups to use other groups or a hex color
			--- function will be called with a ColorScheme table
			---@param colors ColorScheme
			on_colors = function(colors) end,

			--- You can override specific highlights to use other groups or a hex color
			--- function will be called with a Highlights and ColorScheme table
			---@param hl Highlights
			---@param c ColorScheme
			on_highlights = function(hl, c)
				local prompt = "#2d3149"
				hl.TelescopeNormal = {
					bg = c.bg_dark,
					fg = c.fg_dark,
				}
				hl.TelescopeBorder = {
					bg = c.bg_dark,
					fg = c.bg_dark,
				}
				hl.TelescopePromptNormal = {
					bg = prompt,
				}
				hl.TelescopePromptBorder = {
					bg = prompt,
					fg = prompt,
				}
				hl.TelescopePromptTitle = {
					bg = prompt,
					fg = prompt,
				}
				hl.TelescopePreviewTitle = {
					bg = c.bg_dark,
					fg = c.bg_dark,
				}
				hl.TelescopeResultsTitle = {
					bg = c.bg_dark,
					fg = c.bg_dark,
				}
			end,
		},
		config = function(_, opts)
			local tokyonight = require("tokyonight")
			tokyonight.setup(opts)
			tokyonight.load()
		end,
	},

	-- Neotree Settings
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
        },

		config = function(_, opts)
			require("neo-tree").setup(opts)
			vim.keymap.set("n", "<leader>t", ":Neotree toggle<CR>", {})
		end,
	},

	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
		dependencies = {
			{
				"saadparwaiz1/cmp_luasnip",
			},
			{
				"rafamadriz/friendly-snippets",
			},
		},
	},

	-- Nvim CMP
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
		},
		config = function()
			local cmp = require("cmp")

			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- For luasnip users.
				}, {
					{ name = "buffer" },
				}),
			})
		end,
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
				{ "<leader>w", group = "window" },
				{ "<leader>c", group = "code" },
				{ "<leader>h", group = "git" },
				{ "<leader>d", group = "debug" },
			},
		},
	},
}
