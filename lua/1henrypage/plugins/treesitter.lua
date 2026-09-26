local Utils = require("1henrypage.utils")

-- Languages whose tree-sitter indent queries do worse than the built-in indentexpr.
local indent_disabled = { yaml = true, python = true, html = true }

local function attach(bufnr, lang)
  if not vim.api.nvim_buf_is_valid(bufnr) or not pcall(vim.treesitter.start, bufnr, lang) then
    return
  end
  if not indent_disabled[lang] and vim.treesitter.query.get(lang, "indents") then
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- main is the rewrite for Nvim >= 0.12. The repo's only tag (v0.10.0) is the archived
    -- master API, so the default `version = "*"` must not apply here.
    branch = "main",
    version = false,
    lazy = false,
    build = ":TSUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "lua",
        "markdown",
        "markdown_inline",
        "query",
        "regex",
        "vim",
        "yaml",
      },
    },
    config = function(_, opts)
      local ts = require("nvim-treesitter")
      ts.install(vim.fn.uniq(vim.fn.sort(opts.ensure_installed)))

      -- main enables nothing by itself: start highlighting and indent per buffer, and install a
      -- missing parser on first use of its filetype.
      vim.api.nvim_create_autocmd("FileType", {
        group = Utils.augroup("treesitter"),
        callback = function(event)
          local lang = vim.treesitter.language.get_lang(event.match)
          if not lang then
            return
          end
          if vim.treesitter.language.add(lang) then
            attach(event.buf, lang)
          elseif vim.list_contains(ts.get_available(), lang) then
            ts.install(lang):await(vim.schedule_wrap(function(err)
              if not err then
                attach(event.buf, lang)
              end
            end))
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      max_lines = 3,
    },
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    init = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
          tsx = "rainbow-parens",
          javascript = "rainbow-delimiters-react",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
}
