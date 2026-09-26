local split_join_config = {
  mappings = {
    toggle = "<leader>J",
  },
}

local ai_config = {
  -- Table with textobject id as fields, textobject specification as values.
  -- Also use this to disable builtin textobjects. See |MiniAi.config|.
  custom_textobjects = nil,

  -- Module mappings. Use `''` (empty string) to disable one.
  mappings = {
    -- Main textobject prefixes
    around = "a",
    inside = "i",

    -- Next/last textobjects
    around_next = "an",
    inside_next = "in",
    around_last = "al",
    inside_last = "il",

    -- Move cursor to corresponding edge of `a` textobject
    goto_left = "g[",
    goto_right = "g]",
  },

  -- Number of lines within which textobject is searched
  n_lines = 50,

  -- How to search for object (first inside current line, then inside
  -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
  -- 'cover_or_nearest', 'next', 'prev', 'nearest'.
  search_method = "cover_or_next",

  -- Whether to disable showing non-error feedback
  -- This also affects (purely informational) helper messages shown after
  -- idle time if user input is required.
  silent = false,
}

local notify_config = {
  -- Content management
  content = {
    -- Function which orders notification array from most to least important
    -- By default orders first by level and then by update timestamp
    sort = function(notif_arr)
      table.sort(notif_arr, function(a, b)
        return a.ts_update > b.ts_update
      end)
      return notif_arr
    end,
  },

  -- Notifications about LSP progress
  lsp_progress = {
    enable = false,
  },

  -- Window options
  window = {
    -- Floating window config
    config = { border = "rounded" },

    -- Maximum window width as share (between 0 and 1) of available columns
    max_width_share = 0.382,

    -- Value of 'winblend' option
    winblend = 25,
  },
}

return {
  {
    "nvim-mini/mini.nvim",
    version = "*",
    config = function()
      require("mini.ai").setup(ai_config)
      require("mini.pairs").setup({})
      require("mini.notify").setup(notify_config)
      require("mini.bracketed").setup({})
      require("mini.splitjoin").setup(split_join_config)
      require("mini.surround").setup({})
      require("mini.bufremove").setup({})
      require("mini.cursorword").setup({})
      require("mini.animate").setup({
        cursor = { enable = true },
        scroll = { enable = false },
        resize = { enable = false },
        open = { enable = false },
        close = { enable = false },
      })
      require("mini.hipatterns").setup({
        highlighters = {
          fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFix" },
          hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
          todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
          note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
          hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
        },
      })

      -- keybinds
      vim.keymap.set("n", "<leader>bd", function()
        require("mini.bufremove").delete(0, false)
      end, { desc = "delete" })
      vim.keymap.set("n", "<leader>bD", function()
        require("mini.bufremove").delete(0, true)
      end, { desc = "force delete" })
    end,
  },
}
