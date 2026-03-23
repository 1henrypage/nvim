
return {
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
