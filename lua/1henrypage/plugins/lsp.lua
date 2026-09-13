local Icons = require("1henrypage.extras").icons
local Utils = require("1henrypage.utils")

local function supports_method(bufnr, method)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client:supports_method(method, bufnr) then
      return true
    end
  end
  return false
end

local function codelens_is_enabled(bufnr)
  if vim.lsp.codelens.is_enabled then
    return vim.lsp.codelens.is_enabled({ bufnr = bufnr })
  end
  return vim.b[bufnr].codelens_enabled ~= false
end

local function set_codelens(bufnr, enabled)
  vim.b[bufnr].codelens_enabled = enabled
  if vim.lsp.codelens.enable then
    vim.lsp.codelens.enable(enabled, { bufnr = bufnr })
  elseif enabled then
    vim.lsp.codelens.refresh({ bufnr = bufnr })
  else
    vim.lsp.codelens.clear(nil, bufnr)
  end
end

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

      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        group = Utils.augroup("LspCodeLens"),
        callback = function(event)
          if codelens_is_enabled(event.buf) and supports_method(event.buf, "textDocument/codeLens") then
            vim.lsp.codelens.refresh({ bufnr = event.buf })
          end
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = Utils.augroup("LspConfig"),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local function opts(desc)
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

          if
            client
            and client:supports_method("textDocument/inlayHint", ev.buf)
            and not vim.b[ev.buf].inlay_hints_initialized
          then
            vim.b[ev.buf].inlay_hints_initialized = true
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end

          if
            client
            and client:supports_method("textDocument/codeLens", ev.buf)
            and not vim.b[ev.buf].codelens_initialized
          then
            vim.b[ev.buf].codelens_initialized = true
            set_codelens(ev.buf, true)
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
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("code action"))
          vim.keymap.set("n", "gr", "<cmd>Trouble lsp_references<cr>", opts("references"))
          vim.keymap.set("n", "<leader>gf", function()
            require("conform").format({ async = true })
          end, opts("format"))
          vim.keymap.set("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
          end, opts("Toggle inlay hints"))
          vim.keymap.set("n", "<leader>tl", function()
            set_codelens(ev.buf, not codelens_is_enabled(ev.buf))
          end, opts("Toggle code lenses"))
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
