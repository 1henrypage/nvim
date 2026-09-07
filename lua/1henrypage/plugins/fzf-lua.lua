local Util = require("1henrypage.utils")

return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    event = "VeryLazy",
    keys = {
      {
        "<leader>sn",
        function()
          Util.picker.smart_files()
        end,
        desc = "find files",
      },
      {
        "<leader>sf",
        function()
          require("fzf-lua").live_grep_glob()
        end,
        desc = "live grep",
      },
      {
        "<leader>sb",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "buffers",
      },
      {
        "<leader>ss",
        function()
          require("fzf-lua").lsp_document_symbols()
        end,
        desc = "document symbols",
      },
      {
        "<leader>so",
        function()
          require("fzf-lua").oldfiles()
        end,
        desc = "recent files",
      },
      {
        "<leader>sw",
        function()
          require("fzf-lua").grep_cword()
        end,
        desc = "grep word",
      },
    },
    config = function()
      local fzf = require("fzf-lua")
      local fzf_actions = require("fzf-lua.actions")
      -- Over ssh (or any laggy tty) <esc> followed quickly by another key
      -- arrives batched in one read and every layer decodes it as a single
      -- alt-chord instead of two keys. Each alt-* entry below emulates
      -- "esc, then key" so the modal bindings survive that: nvim-side the
      -- terminal buffer gets <A-hjkl> passthrough maps (on_create) so the
      -- global window-nav maps don't hijack them, and fzf-side alt-i/hjkl
      -- run the same state check as their two-key counterparts.
      -- Transforms use POSIX [ ] on purpose: fzf runs them via $SHELL -c,
      -- which remotely may be dash/fish where [[ ]] silently fails.
      local function when_hidden(then_act, else_act)
        return ([=[transform:[ "$FZF_INPUT_STATE" = hidden ] && echo "%s" || echo "%s"]=]):format(then_act, else_act)
      end
      local to_normal = "rebind(h,j,k,l)+hide-input"
      fzf.setup({
        winopts = {
          height = 0.80,
          width = 0.87,
          border = "rounded",
          preview = { layout = "flex", flip_columns = 120, horizontal = "right:55%" },
          on_create = function(e)
            for _, key in ipairs({ "<A-h>", "<A-j>", "<A-k>", "<A-l>" }) do
              vim.keymap.set("t", key, key, { buffer = e.bufnr, nowait = true })
            end
            -- batched esc-esc decodes as <A-Esc>; the intent is "close", and
            -- fzf has no alt-esc bind key, so send it ctrl-c (abort) instead
            vim.keymap.set("t", "<A-Esc>", "<C-c>", { buffer = e.bufnr, nowait = true })
          end,
        },
        keymap = {
          -- <M-Esc> is fzf-lua's "hide picker": batched esc-esc decodes as
          -- exactly that, turning our close gesture into a hide. Disable it;
          -- the raw esc-esc bytes then fall through to fzf as two escapes.
          builtin = { true, ["<M-Esc>"] = false },
          fzf = {
            -- vim-style modal nav: <esc> hides the input line and switches
            -- hjkl to move the cursor; `i` shows it again, `q` or a second
            -- <esc> closes the picker. h/j/k/l are unbound right after start
            -- so typing them into the query works normally until <esc> is
            -- pressed; $FZF_INPUT_STATE (not --prompt) tracks which mode
            -- we're in so this doesn't depend on any picker's prompt text.
            true, -- inherit fzf-lua's default binds (a bare table replaces them)
            ["start"] = "unbind(h,j,k,l)",
            ["h"] = "half-page-up",
            ["j"] = "down",
            ["k"] = "up",
            ["l"] = "half-page-down",
            ["i"] = when_hidden("unbind(h,j,k,l)+show-input", "put"),
            ["q"] = when_hidden("abort", "put"),
            ["esc"] = when_hidden("abort", to_normal),
            -- batched esc+key fallbacks; esc in normal mode means close
            ["alt-i"] = when_hidden("abort", "ignore"),
            ["alt-h"] = when_hidden("abort", to_normal .. "+half-page-up"),
            ["alt-j"] = when_hidden("abort", to_normal .. "+down"),
            ["alt-k"] = when_hidden("abort", to_normal .. "+up"),
            ["alt-l"] = when_hidden("abort", to_normal .. "+half-page-down"),
          },
        },
        actions = {
          files = {
            true, -- inherit defaults (a bare table replaces them)
            -- alt-i/alt-h collide with the batched-escape fallbacks above;
            -- keep ignore-toggling reachable on ctrl-g, drop the hidden
            -- toggle (files.hidden=true already shows hidden files)
            ["alt-i"] = false,
            ["alt-h"] = false,
            ["ctrl-g"] = { fn = fzf_actions.toggle_ignore, reuse = true, header = false },
          },
        },
        files = { hidden = true },
        git = { files = { cmd = "git ls-files --exclude-standard --cached --others" } },
        -- builtin previewer's treesitter highlighting crashes on some buffers
        previewers = { builtin = { treesitter = { enabled = false } } },
        grep = {
          rg_glob = true,
          -- --color=always and trailing -e are required: fzf-lua parses rg's
          -- output format, and without them Enter fails to open the match
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden -e",
        },
      })
      fzf.register_ui_select()
    end,
  },
}
