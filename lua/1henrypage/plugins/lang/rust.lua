return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "rust", "toml" } },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = { ensure_installed = { "codelldb" } },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
      },
    },
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    dependencies = { "saghen/blink.cmp" },
    config = function()
      vim.g.rustaceanvim = {
        tools = {
          float_win_config = { border = "rounded" },
        },
        server = {
          capabilities = require("blink.cmp").get_lsp_capabilities(),
          on_attach = function(_, bufnr)
            local function opts(desc)
              return { buffer = bufnr, noremap = true, silent = true, desc = desc }
            end
            vim.keymap.set("n", "<leader>cr", "<cmd>RustLsp runnables<cr>", opts("runnables"))
            vim.keymap.set("n", "<leader>cd", "<cmd>RustLsp debuggables<cr>", opts("debuggables"))
            vim.keymap.set("n", "<leader>ce", "<cmd>RustLsp explainError<cr>", opts("explain error"))
            vim.keymap.set("n", "<leader>cx", "<cmd>RustLsp expandMacro<cr>", opts("expand macro"))
            vim.keymap.set("n", "<leader>cC", "<cmd>RustLsp openCargo<cr>", opts("open Cargo.toml"))
            vim.keymap.set("n", "<leader>cp", "<cmd>RustLsp parentModule<cr>", opts("parent module"))
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                targetDir = true,
                buildScripts = { enable = true },
              },
              -- allTargets defaults to true in rust-analyzer itself; setting it explicitly here
              -- documents the choice without duplicating the flag via extraArgs (which errors:
              -- "the argument '--all-targets' cannot be used multiple times").
              check = { command = "clippy", allTargets = true },
              procMacro = { enable = true },
              inlayHints = {
                chainingHints = { enable = true },
                parameterHints = { enable = true },
                typeHints = { enable = true },
                closingBraceHints = { enable = true, minLines = 25 },
                lifetimeElisionHints = { enable = "never" },
                reborrowHints = { enable = "never" },
                closureReturnTypeHints = { enable = "never" },
              },
            },
          },
        },
        dap = {},
      }
    end,
  },

  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    -- crates.nvim's own in-process LSP is its recommended completion path: it attaches like
    -- any other language server, so it rides the existing "lsp" blink.cmp source for free -
    -- there is no separate "crates" blink source to register.
    opts = {
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },

  {
    "nvim-neotest/neotest",
    opts = { adapters = { "rustaceanvim.neotest" } },
  },
}
