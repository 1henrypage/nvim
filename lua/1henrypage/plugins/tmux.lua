
return {
    {
        "aserowy/tmux.nvim",
        opts = {
            copy_sync = {enable = true},
            navigation = {cycle_navigation = true},
            resize = {resize_step_x = 5, resize_step_y = 5},
        },
        config = function (_, opts)
            return require("tmux").setup({})
        end,
    },
}

-- return {
--     {
--         "echasnovski/mini.nvim",
--         version = "*",
--         config = function(_, opts)
--             require("mini.ai").setup({ai_config})
--             require("mini.comment").setup(comment_config)
--             require("mini.pairs").setup({})
--             require("mini.notify").setup(notify_config)
--             require("mini.bracketed").setup({})
--             require("mini.starter").setup({}) 
--             require("mini.splitjoin").setup(split_join_config)
--             require("mini.surround").setup({})
--             -- require("mini.statusline").setup({}) # don't use this it's shit
--             require("mini.bufremove").setup({})
--             require("mini.cursorword").setup({})
--             require("mini.indentscope").setup(indent_scope_config)
--             require("mini.surround").setup({})
-- 
-- 
--             -- keybinds 
--             vim.keymap.set('n', '<leader>bd', function ()
--                 require('mini.bufremove').delete(0, false)
--             end, {})
--             -- 
--         end,
--     },
-- }
