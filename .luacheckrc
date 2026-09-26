std = "luajit"
ignore = {
  "631", -- max_line_length
}
-- `vim` is Nvim's API namespace; config code assigns into it (vim.g, vim.opt, vim.bo[buf], ...).
globals = {
  "vim",
}
read_globals = {
  "Snacks", -- set by snacks.nvim's setup()
}
