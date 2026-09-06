return {
  {
    "aserowy/tmux.nvim",
    opts = {
      copy_sync = { enable = true },
      navigation = { cycle_navigation = true, enable_default_keybindings = true },
      resize = { enable_default_keybindings = true, resize_step_x = 5, resize_step_y = 5 },
    },
    config = function(_, opts)
      -- tmux.nvim's snacks wrapper calls Snacks.picker.get() to detect a focused
      -- picker, but we run snacks with picker disabled, so it is nil and
      -- is_nvim_border() crashes. We use fzf-lua, so disable the integration.
      -- pcall: tmux.wrapper.snacks does not exist at the currently pinned version,
      -- this arms the fix for whenever tmux.nvim is next updated.
      local ok, snacks = pcall(require, "tmux.wrapper.snacks")
      if ok then
        snacks.using_snacks = function()
          return false
        end
      end
      require("tmux").setup(opts)
    end,
  },
}
