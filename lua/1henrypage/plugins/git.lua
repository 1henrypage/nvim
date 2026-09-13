local Colors = require("1henrypage.extras").colors

local function blame_format(line, _, index)
  local hash = line.hash:sub(1, 7)
  if hash == "0000000" then
    return {
      idx = index,
      values = { { textValue = "Not committed", hl = "BlameUncommitted" } },
      format = "%s",
    }
  end

  local summary = line.summary or ""
  if vim.fn.strchars(summary) > 30 then
    summary = vim.fn.strcharpart(summary, 0, 27) .. "..."
  end

  return {
    idx = index,
    values = {
      { textValue = os.date("%d-%m-%y", line.committer_time), hl = "BlameDate" },
      { textValue = summary, hl = hash },
    },
    format = "%s  %s",
  }
end

local function toggle_blame()
  local blame = require("blame")
  if blame.is_open() then
    vim.cmd("BlameToggle window")
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if vim.bo[bufnr].buftype ~= "" or filename == "" then
    vim.notify("Blame is unavailable for this buffer", vim.log.levels.INFO)
    return
  end

  local root = vim.fs.root(filename, ".git")
  if not root then
    vim.notify("Blame is unavailable outside a Git repository", vim.log.levels.INFO)
    return
  end

  local relative = vim.fs.relpath(root, filename)
  local tracked = relative and vim.system({ "git", "-C", root, "ls-files", "--error-unmatch", "--", relative }):wait()
  if not tracked or tracked.code ~= 0 then
    vim.notify("Blame is unavailable for untracked files", vim.log.levels.INFO)
    return
  end

  vim.cmd("BlameToggle window")
end

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_line_blame = false,
      signs = {
        add = { text = "▋" },
        change = { text = "▋" },
        delete = { text = "▋" },
        topdelete = { text = "▋" },
        changedelete = { text = "▋" },
        untracked = { text = "▋" },
      },
    },
    config = function(_, opts)
      local gs = require("gitsigns")
      gs.setup(opts)

      vim.keymap.set("n", "<leader>hj", gs.next_hunk, { desc = "Next git hunk" })
      vim.keymap.set("n", "<leader>hk", gs.prev_hunk, { desc = "Prev git hunk" })
      vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
      vim.keymap.set("n", "<leader>hd", gs.diffthis, { desc = "Diff file (vs index)" })
      vim.keymap.set("n", "<leader>hD", function()
        gs.diffthis("~")
      end, { desc = "Diff file (vs last commit)" })
      vim.keymap.set("n", "<leader>hw", gs.preview_hunk, { desc = "Preview hunk" })

      vim.keymap.set({ "o", "x" }, "ih", ":<C-u>Gitsigns select_hunk<CR>", { desc = "Inside hunk" })
    end,
  },

  {
    "FabijanZulj/blame.nvim",
    opts = {
      date_format = "%d-%m-%y",
      relative_date_if_recent = false,
      focus_blame = false,
      merge_consecutive = false,
      max_summary_width = 30,
      colors = { Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.cyan, Colors.purple },
      commit_detail_view = "vsplit",
      format_fn = blame_format,
    },
    config = function(_, opts)
      require("blame").setup(opts)
      vim.keymap.set("n", "<leader>tb", toggle_blame, { desc = "Toggle file blame" })
    end,
  },
}
