
return {
    {
        "aserowy/tmux.nvim",
        opts = {
            copy_sync = {enable = true},
            navigation = {cycle_navigation = true},
            resize = {resize_step_x = 5, resize_step_y = 5},
        },
        config = function(_, opts)
            return require("tmux").setup(opts)
        end,
    },
}
