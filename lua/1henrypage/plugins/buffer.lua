local Profile = require("1henrypage.profile")
local Icons = require("1henrypage.extras").icons
local Colors = require("1henrypage.extras").colors

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
                        },
                    },
                },
                highlights = {
                    fill                   = { bg = Colors.bg_deep },

                    -- Inactive tabs: midpoint between bg_active and bg_deep
                    background             = { bg = Colors.bg_inactive, fg = Colors.fg_muted },
                    buffer_visible         = { bg = Colors.bg_inactive, fg = Colors.fg_visible },

                    -- Selected tab: matches editor bg
                    buffer_selected        = { bg = Colors.bg_active, fg = Colors.fg, bold = true },

                    -- Slopes: inactive uses inactive tab color, selected uses active tab color
                    separator              = { fg = Colors.bg_deep, bg = Colors.bg_inactive },
                    separator_visible      = { fg = Colors.bg_deep, bg = Colors.bg_inactive },
                    separator_selected     = { fg = Colors.bg_deep, bg = Colors.bg_active },

                    -- Close buttons: bg matches parent tab
                    close_button           = { fg = Colors.fg_muted, bg = Colors.bg_inactive },
                    close_button_visible   = { fg = Colors.fg_muted, bg = Colors.bg_inactive },
                    close_button_selected  = { fg = Colors.red, bg = Colors.bg_active },

                    -- Modified indicator: bg matches parent tab
                    modified               = { fg = Colors.blue, bg = Colors.bg_inactive },
                    modified_visible       = { fg = Colors.blue, bg = Colors.bg_inactive },
                    modified_selected      = { fg = Colors.blue, bg = Colors.bg_active },
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
