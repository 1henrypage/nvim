local Icons = require("1henrypage.extras").icons

return {
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics (Trouble)" },
            { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document Diagnostics (Trouble)" },
        },
        opts = {
            auto_jump = true,
            icons = {
                kinds = Icons.kinds,
            },
        },
    },
}
