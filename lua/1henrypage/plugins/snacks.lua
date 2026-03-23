return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "<leader>.d",
      function()
        Snacks.dashboard.open()
      end,
      desc = "Dashboard",
      silent = true,
    },
  },
  opts = {
    -- disable everything except dashboard
    bigfile = { enabled = false },
    dim = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    lazygit = { enabled = false },
    notifier = { enabled = false },
    picker = { enabled = false },
    quickfile = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    terminal = { enabled = false },
    words = { enabled = false },

    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "n", desc = "New File", action = ":ene" },
          {
            icon = "󰥨 ",
            key = "f",
            desc = "Find File",
            action = function()
              require("telescope.builtin").find_files()
            end,
          },
          {
            icon = "󰈞 ",
            key = "g",
            desc = "Find Text",
            action = function()
              require("telescope").extensions.live_grep_args.live_grep_args()
            end,
          },
          {
            icon = " ",
            key = "r",
            desc = "Recent Files",
            action = function()
              require("telescope.builtin").oldfiles()
            end,
          },
          {
            icon = " ",
            key = "p",
            desc = "Plugins",
            action = ":Lazy",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "q", desc = "Quit", action = ":quit" },
        },
      },
      sections = {
        function()
          return {
            header = require("1henrypage.dashboard").header,
            padding = 1,
            pane = 1,
          }
        end,
        {
          pane = 1,
          section = "terminal",
          cmd = "curl -s 'https://wttr.in/?0FQ' | sed 's/^/               /' || echo -n",
          height = 6,
        },
        { pane = 1, section = "startup" },
        { pane = 2, section = "keys", padding = 1 },
        {
          pane = 2,
          icon = " ",
          title = "RECENT FILES",
          section = "recent_files",
          indent = 2,
          padding = 1,
        },
        {
          pane = 2,
          icon = "󰙅 ",
          title = "PROJECTS",
          section = "projects",
          indent = 2,
          padding = 1,
        },
        {
          pane = 2,
          icon = " ",
          title = "GIT STATUS [" .. vim.fn.trim(vim.fn.system("git branch --show-current")) .. "]",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git --no-pager diff --stat -B -M -C && git status --short --renames",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 2,
        },
        {
          pane = 2,
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() == nil
          end,
          cmd = "cmatrix -br",
          height = 6,
          indent = 2,
          padding = 1,
        },
      },
    },

    styles = {
      dashboard = {
        height = 0.8,
        width = 0.8,
        border = "rounded",
      },
    },
  },
}
