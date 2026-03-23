# Neovim Config

Lua-based neovim config using lazy.nvim as the plugin manager. This repo is a git submodule of the dotfiles repo (1henrypage/dotfiles).

## Structure

```
lua/1henrypage/
  init.lua              -- Entry point: loads extras, bootstraps lazy
  lazy.lua              -- lazy.nvim bootstrap and plugin loading
  profile.lua           -- Author metadata (used for augroup names, buffer labels)
  dashboard.lua         -- System info header for snacks.nvim dashboard
  extras/
    init.lua            -- Module loader with __index auto-require
    options.lua         -- vim.opt settings
    keymaps.lua         -- Global keybindings
    autocmds.lua        -- Autocommands
    icons.lua           -- Shared icon definitions (nerd font glyphs)
    colors.lua          -- Central color palette (tokyonight storm extensions)
  utils/
    init.lua            -- Utility functions
  plugins/
    init.lua            -- Calls extras.init(), declares lazy self-spec
    colorscheme.lua     -- tokyonight (storm, transparent)
    buffer.lua          -- bufferline.nvim
    editor.lua          -- LuaSnip, nvim-cmp, ufo, which-key, statuscol
    lsp.lua             -- mason, lspconfig, conform
    telescope.lua       -- telescope + extensions
    neo-tree.lua        -- File explorer
    mini.lua            -- mini.nvim modules (ai, pairs, notify, surround, etc.)
    snacks.lua          -- snacks.nvim dashboard
    git.lua, ui.lua, tmux.lua, window.lua, dap.lua, dependencies.lua
    lang/               -- Language-specific plugin configs (haskell, java, python, web, misc)
snippets/               -- snipmate-format snippet files
```

## Key Patterns

- **Extras auto-loading:** `extras/init.lua` has an `__index` metamethod — `require("1henrypage.extras").colors` auto-requires `extras/colors.lua`. No explicit import needed.
- **Colors:** All hex color codes live in `extras/colors.lua`. Never hardcode hex values in plugin configs — reference `Colors.*` instead.
- **Lang configs:** All language-specific setup goes in `plugins/lang/`. Never use ftplugin/.
- **Plugin files:** One file per plugin or logical group. Don't consolidate into monolithic files.
- **Theme:** tokyonight storm with transparent background. Sidebar/bufferline colors are custom extensions of the palette defined in `extras/colors.lua`.
- **Snippets:** Both vscode-format (via `from_vscode`) and snipmate-format (via `from_snipmate`) loaders are active.
