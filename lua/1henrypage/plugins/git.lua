return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            current_line_blame = true,
        },
        config = function(_, opts)
            local gs = require("gitsigns")
            gs.setup(opts)

            vim.keymap.set("n", "ghn", gs.next_hunk, { desc = "Next git hunk" })
            vim.keymap.set("n", "ghp", gs.prev_hunk, { desc = "Prev git hunk" })
            vim.keymap.set("n", "<leader>hb", gs.blame_line, { desc = "Blame line" })
        end,
    },
}
