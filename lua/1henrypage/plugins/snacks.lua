local Utils = require("1henrypage.utils")

-- Nvim 0.12 draws "[Process exited N]" as an extmark instead of a buffer line, so snacks'
-- Job:hide_process_exited() (which deletes that line) no longer hides it under the dashboard's
-- terminal sections. Drop the clean-exit mark ourselves; non-zero exits stay visible, as before.
local function hide_clean_exit(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "snacks_dashboard" then
    return
  end
  local ns = vim.api.nvim_create_namespace("nvim.terminal.exitmsg")
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })) do
    local virt_text = mark[4].virt_text
    if virt_text and virt_text[1] and virt_text[1][1] == "[Process exited 0]" then
      vim.api.nvim_buf_del_extmark(buf, ns, mark[1])
    end
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  config = function(_, opts)
    require("snacks").setup(opts)

    -- snacks tags a section's terminal buffer as a dashboard buffer either before or after its
    -- process exits, so catch both orders.
    local group = Utils.augroup("dashboard_exitmsg")
    vim.api.nvim_create_autocmd("TermClose", {
      group = group,
      callback = function(event)
        hide_clean_exit(event.buf)
      end,
    })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "snacks_dashboard",
      callback = function(event)
        hide_clean_exit(event.buf)
      end,
    })
  end,
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
              require("1henrypage.utils").picker.smart_files()
            end,
          },
          {
            icon = "󰈞 ",
            key = "g",
            desc = "Find Text",
            action = function()
              require("fzf-lua").live_grep()
            end,
          },
          {
            icon = " ",
            key = "r",
            desc = "Recent Files",
            action = function()
              require("fzf-lua").oldfiles()
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
