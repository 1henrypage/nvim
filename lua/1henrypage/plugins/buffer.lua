local Profile = require("1henrypage.profile")
local Icons = require("1henrypage.extras").icons

return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        config = function(_, opts)
            require("bufferline").setup({
                options = {
                    -- Buffer Icons config
                    modified_icon = Icons.git.modified,
                    close_icon = "󰅖",
                    left_trunc_marker = Icons.borders.thin.left,
                    right_trunc_marker = Icons.borders.thin.right,

                    mode = "buffers",
                    themable = true,
                    diagnostics = "nvim_lsp",
                    diagnostics_update_on_event = true,
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
                            require('bufferline.groups').builtin.pinned:with({icon = Icons.bufferline.pinned .. " "})
                            -- {
                            --     name = "Tests",
                            --     highlight = { underline = true, sp = "blue" }, -- Optional
                            --     priority = 2,
                            --     icon = " ",
                            --     matcher = function(buf) -- Mandatory
                            --         return buf.filename and (buf.filename:match("%Test") or buf.filename:match("%Tests"))
                            --     end,
                            -- },
                            -- {
                            --     name = "Docs",
                            --     highlight = { undercurl = true, sp = "green" },
                            --     matcher = function(buf)
                            --         return buf.filename and (buf.filename:match("%.md") or buf.filename:match("%.txt"))
                            --     end,
                            -- },
                        },
                    },
                },
                highlights = {
                    fill                   = { bg = "#13141e" },

                    -- Inactive tabs: midpoint between active (#24283b) and neo-tree (#13141e)
                    background             = { bg = "#1b1e2c", fg = "#565f89" },
                    buffer_visible         = { bg = "#1b1e2c", fg = "#737aa2" },

                    -- Selected tab: matches editor bg
                    buffer_selected        = { bg = "#24283b", fg = "#c0caf5", bold = true },

                    -- Slopes: inactive uses inactive tab color, selected uses active tab color
                    separator              = { fg = "#13141e", bg = "#1b1e2c" },
                    separator_visible      = { fg = "#13141e", bg = "#1b1e2c" },
                    separator_selected     = { fg = "#13141e", bg = "#24283b" },

                    -- Close buttons: bg matches parent tab
                    close_button           = { fg = "#565f89", bg = "#1b1e2c" },
                    close_button_visible   = { fg = "#565f89", bg = "#1b1e2c" },
                    close_button_selected  = { fg = "#f7768e", bg = "#24283b" },

                    -- Modified indicator: bg matches parent tab
                    modified               = { fg = "#7aa2f7", bg = "#1b1e2c" },
                    modified_visible       = { fg = "#7aa2f7", bg = "#1b1e2c" },
                    modified_selected      = { fg = "#7aa2f7", bg = "#24283b" },
                },
            })

            vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", {})

            for i = 1, 9 do
                vim.keymap.set("n", "<leader>" .. i, function()
                    require("bufferline").go_to(i)
                end, {})
            end

            vim.keymap.set("n", "<leader>0", function ()
                require("bufferline").go_to(-1)
            end, {})
        end,
    },
}
