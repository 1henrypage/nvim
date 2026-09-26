local Icons = require("1henrypage.extras").icons
local Utils = require("1henrypage.utils")

return {
  -- mason
  {
    "mason-org/mason.nvim",
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
    dependencies = { "mason-org/mason.nvim" },
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
      "mason-org/mason.nvim",
      "saghen/blink.cmp",
    },
    -- Lang files add servers here: each entry is handed to vim.lsp.config() and enabled.
    -- `opts` is what lazy.nvim deep-merges across specs of one plugin; a per-lang `init` or
    -- `config` would instead replace every other lang's, silently disabling their servers.
    opts = {
      servers = {
        lua_ls = {},
      },
    },
    config = function(_, opts)
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("*", { capabilities = capabilities })
      for name, server in pairs(opts.servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end

      -- Enabled once, globally, so Nvim attaches each supporting client exactly once. Enabling
      -- per buffer from LspAttach sends a second codeLens request at the same document version,
      -- and Nvim 0.12.5 then discards the first request's resolved lenses, leaving blank virtual
      -- lines (e.g. jdtls reference counts). <leader>th / <leader>tl still toggle per buffer.
      vim.lsp.inlay_hint.enable(true)
      vim.lsp.codelens.enable(true)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = Utils.augroup("LspConfig"),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local function map_opts(desc)
            return { buffer = ev.buf, noremap = true, silent = true, desc = desc }
          end

          if client and client:supports_method("textDocument/documentHighlight", ev.buf) then
            local reference_group = vim.api.nvim_create_augroup("1henrypage-LspReferences-" .. ev.buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = reference_group,
              buffer = ev.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = reference_group,
              buffer = ev.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end

          vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, map_opts("declaration"))
          vim.keymap.set("n", "<leader>gd", "<cmd>Trouble lsp_definitions<cr>", map_opts("definition"))
          vim.keymap.set("n", "K", vim.lsp.buf.hover, map_opts("hover"))
          vim.keymap.set("n", "<leader>gi", "<cmd>Trouble lsp_implementations<cr>", map_opts("implementations"))
          vim.keymap.set("n", "<leader>gP", vim.lsp.buf.signature_help, map_opts("signature help"))
          vim.keymap.set("n", "<leader>gwa", vim.lsp.buf.add_workspace_folder, map_opts("add folder"))
          vim.keymap.set("n", "<leader>gwr", vim.lsp.buf.remove_workspace_folder, map_opts("remove folder"))
          vim.keymap.set("n", "<leader>gwl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, map_opts("list folders"))
          vim.keymap.set("n", "<leader>gtd", "<cmd>Trouble lsp_type_definitions<cr>", map_opts("type definition"))
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, map_opts("code action"))
          vim.keymap.set("n", "gr", "<cmd>Trouble lsp_references<cr>", map_opts("references"))
          vim.keymap.set("n", "<leader>gf", function()
            require("conform").format({ async = true })
          end, map_opts("format"))
          vim.keymap.set("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
          end, map_opts("Toggle inlay hints"))
          vim.keymap.set("n", "<leader>tl", function()
            local enabled = vim.lsp.codelens.is_enabled({ bufnr = ev.buf })
            vim.lsp.codelens.enable(not enabled, { bufnr = ev.buf })
          end, map_opts("Toggle code lenses"))
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
