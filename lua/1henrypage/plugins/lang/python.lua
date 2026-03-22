return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { ensure_installed = { "python" } },
    },

    {
        "williamboman/mason-lspconfig.nvim",
        opts = { ensure_installed = { "basedpyright", "ruff" } },
    },

    {
        "neovim/nvim-lspconfig",
        init = function()
            vim.lsp.enable({ "basedpyright", "ruff" })
        end,
    },

    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                python = { "ruff_format" },
            },
        },
    },
}
