local Colors = require("1henrypage.extras").colors
local Icons = require("1henrypage.extras").icons
local Utils = require("1henrypage.utils")

local lualine_theme = {
  normal = {
    a = { bg = Colors.orange, fg = Colors.dark2, gui = "bold" },
    b = { bg = Colors.terminal, fg = Colors.orange },
    c = { bg = Colors.dark1, fg = Colors.text },
  },
  insert = {
    a = { bg = Colors.green, fg = Colors.dark2, gui = "bold" },
    b = { bg = Colors.terminal, fg = Colors.green },
  },
  command = {
    a = { bg = Colors.yellow, fg = Colors.dark2, gui = "bold" },
    b = { bg = Colors.terminal, fg = Colors.yellow },
  },
  visual = {
    a = { bg = Colors.purple, fg = Colors.dark2, gui = "bold" },
    b = { bg = Colors.terminal, fg = Colors.purple },
  },
  replace = {
    a = { bg = Colors.red, fg = Colors.dark2, gui = "bold" },
    b = { bg = Colors.terminal, fg = Colors.red },
  },
  inactive = {
    a = { bg = Colors.dark1, fg = Colors.dimmed3 },
    b = { bg = Colors.dark1, fg = Colors.dimmed3 },
    c = { bg = Colors.dark1, fg = Colors.dimmed3 },
  },
}

local special_filetypes = {
  aerial = true,
  blame = true,
  checkhealth = true,
  dapui_breakpoints = true,
  dapui_console = true,
  dapui_scopes = true,
  dapui_stacks = true,
  dapui_watches = true,
  fzf = true,
  help = true,
  lazy = true,
  mason = true,
  ["neo-tree"] = true,
  notify = true,
  qf = true,
  trouble = true,
}

local function is_special_buffer(bufnr)
  return vim.bo[bufnr].buftype ~= "" or special_filetypes[vim.bo[bufnr].filetype] == true
end

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = lualine_theme,
        component_separators = { left = "│", right = "│" },
      },
      -- Sidebars and tool windows get their own statusline instead of "[No Name] [-]".
      extensions = { "aerial", "fzf", "lazy", "man", "mason", "neo-tree", "nvim-dap-ui", "quickfix", "trouble" },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        highlight = "IblIndent",
      },
      scope = {
        enabled = true,
        char = "│",
        highlight = "IblScope",
        show_start = false,
        show_end = false,
      },
      exclude = {
        buftypes = { "help", "nofile", "nowrite", "prompt", "quickfix", "terminal" },
        filetypes = vim.tbl_keys(special_filetypes),
      },
    },
  },

  {
    "SmiteshP/nvim-navic",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      icons = vim.tbl_map(function(icon)
        return icon .. " "
      end, Icons.kinds),
      highlight = true,
      separator = " › ",
      depth_limit = 5,
      depth_limit_indicator = "…",
      safe_output = true,
      lsp = {
        auto_attach = true,
        preference = {
          "jdtls",
          "rust-analyzer",
          "haskell-language-server",
          "basedpyright",
          "lua_ls",
          "marksman",
          "ruff",
          "spring-boot",
        },
      },
    },
    config = function(_, opts)
      require("nvim-navic").setup(opts)
      vim.o.winbar = "%{%v:lua.require'1henrypage.utils.winbar'.get()%}"
    end,
  },

  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      attach_mode = "global",
      close_automatic_events = { "unsupported" },
      layout = {
        max_width = { 40, 0.2 },
        min_width = 20,
        default_direction = "right",
        placement = "edge",
        resize_to_content = false,
      },
      icons = Icons.kinds,
      show_guides = true,
      filter_kind = false,
      ignore = {
        unlisted_buffers = true,
        diff_windows = true,
        filetypes = vim.tbl_keys(special_filetypes),
        buftypes = "special",
        wintypes = "special",
      },
      open_automatic = false,
    },
    config = function(_, opts)
      local aerial = require("aerial")
      local aerial_backends = require("aerial.backends")
      local enabled = true
      local reconcile_pending = false

      local function is_available(bufnr)
        if aerial.is_available then
          return aerial.is_available(bufnr)
        end
        return aerial_backends.get(bufnr) ~= nil
      end

      local function reconcile()
        reconcile_pending = false
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].filetype == "aerial" then
          return
        end

        local should_open = enabled and vim.o.columns >= 140 and not is_special_buffer(bufnr)
        if not should_open then
          aerial.close_all()
          return
        end

        if is_available(bufnr) and not aerial.is_open() then
          aerial.open({ direction = "right", focus = false })
        end
      end

      local function schedule_reconcile()
        if reconcile_pending then
          return
        end
        reconcile_pending = true
        vim.schedule(reconcile)
      end

      opts.on_first_symbols = function(bufnr)
        if bufnr == vim.api.nvim_get_current_buf() then
          schedule_reconcile()
        end
      end
      aerial.setup(opts)
      aerial.sync_load()

      vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach", "VimResized", "WinResized" }, {
        group = Utils.augroup("aerial-layout"),
        callback = schedule_reconcile,
      })

      vim.keymap.set("n", "<leader>go", function()
        enabled = not enabled
        if enabled then
          schedule_reconcile()
        else
          aerial.close_all()
        end
      end, { desc = "Toggle symbol outline" })

      schedule_reconcile()
    end,
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    priority = 900,
    opts = {
      preset = "simple",
      transparent_bg = false,
      hi = {
        error = "DiagnosticError",
        warn = "DiagnosticWarn",
        info = "DiagnosticInfo",
        hint = "DiagnosticHint",
        arrow = "NonText",
        background = "NormalFloat",
        mixing_color = "Normal",
      },
      options = {
        show_source = { enabled = true, if_many = true },
        show_code = true,
        show_related = { enabled = false },
        multilines = {
          enabled = true,
          always_show = true,
          trim_whitespaces = true,
        },
        overflow = { mode = "oneline" },
        override_open_float = true,
        format = function(diagnostic)
          local message = diagnostic.message:gsub("%s+", " ")
          local max_width = math.max(24, math.floor(vim.api.nvim_win_get_width(0) * 0.45))
          if vim.fn.strdisplaywidth(message) > max_width then
            return vim.fn.strcharpart(message, 0, max_width - 1) .. "…"
          end
          return message
        end,
      },
    },
    config = function(_, opts)
      vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = false,
        severity_sort = true,
        underline = true,
        signs = true,
        float = { border = "rounded", source = "if_many" },
      })
      local inline_diagnostics = require("tiny-inline-diagnostic")
      inline_diagnostics.setup(opts)

      -- Messages are placed at virtcol("$"), which counts inline virtual text such as inlay
      -- hints. Nvim 0.12 only draws hints on the redraw after their response, and they usually
      -- land after the first diagnostics, while the plugin re-renders only on cursor/diagnostic
      -- events - so the message would cover the end of the code until the cursor moves. Once a
      -- response is handled (LspRequest "complete" fires just before its handler), draw the
      -- hints and re-render.
      vim.api.nvim_create_autocmd("LspRequest", {
        group = Utils.augroup("inline_diagnostics_inlay_hints"),
        callback = function(event)
          local request = event.data.request
          if request.type == "complete" and request.method == "textDocument/inlayHint" then
            vim.schedule(function()
              vim.cmd.redraw()
              require("tiny-inline-diagnostic.renderer").safe_render(inline_diagnostics.config, request.bufnr)
            end)
          end
        end,
      })
      vim.keymap.set("n", "<leader>td", inline_diagnostics.toggle, { desc = "Toggle inline diagnostics" })
    end,
  },

  {
    "kosayoda/nvim-lightbulb",
    opts = {
      sign = {
        enabled = true,
        text = "",
        hl = "LightBulbSign",
      },
      virtual_text = { enabled = false },
      float = { enabled = false },
      status_text = { enabled = false },
      number = { enabled = false },
      line = { enabled = false },
      autocmd = {
        enabled = true,
        updatetime = -1,
        events = { "CursorHold", "CursorHoldI" },
      },
      ignore = {
        ft = vim.tbl_keys(special_filetypes),
      },
    },
  },
}
