local Icons = require("1henrypage.extras").icons
local Utils = require("1henrypage.utils")

return {
  -- mason
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = Icons.git.added,
          package_pending = Icons.git.untracked,
          package_uninstalled = Icons.git.deleted,
        },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    branch = "master",
    dependencies = {
      "williamboman/mason.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("*", { capabilities = capabilities })
      vim.lsp.enable({ "lua_ls" })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = Utils.augroup("LspConfig"),
        callback = function(ev)
          local function opts(desc)
            return { buffer = ev.buf, noremap = true, silent = true, desc = desc }
          end
          vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts("declaration"))
          vim.keymap.set("n", "<leader>gd", "<cmd>Trouble lsp_definitions<cr>", opts("definition"))
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("hover"))
          vim.keymap.set("n", "<leader>gi", "<cmd>Trouble lsp_implementations<cr>", opts("implementations"))
          vim.keymap.set("n", "<leader>gP", vim.lsp.buf.signature_help, opts("signature help"))
          vim.keymap.set("n", "<leader>gwa", vim.lsp.buf.add_workspace_folder, opts("add folder"))
          vim.keymap.set("n", "<leader>gwr", vim.lsp.buf.remove_workspace_folder, opts("remove folder"))
          vim.keymap.set("n", "<leader>gwl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts("list folders"))
          vim.keymap.set("n", "<leader>gtd", "<cmd>Trouble lsp_type_definitions<cr>", opts("type definition"))
          vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts("rename"))
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("code action"))
          vim.keymap.set("n", "gr", "<cmd>Trouble lsp_references<cr>", opts("references"))
          vim.keymap.set("n", "<leader>gf", function()
            require("conform").format({ async = true })
          end, opts("format"))
          vim.keymap.set("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
          end, opts("inlay hints"))
        end,
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },
}
