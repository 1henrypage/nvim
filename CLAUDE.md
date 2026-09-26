# Neovim Config

Lua-based neovim config using lazy.nvim as the plugin manager. This repo is a git submodule of the dotfiles repo (1henrypage/dotfiles).

Targets the Neovim version pinned in `nvim.version` (currently 0.12). The dotfiles' bob config points bob's `version_sync_file_location` at that file: `bob use <version>` rewrites it and `bob sync` installs it, and CI's smoke test reads it. Bump it together with `lazy-lock.json`, since plugins pinned there are tested against it.

## Structure

```
colors/
  ristretto.lua         -- Native, dependency-free colorscheme
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
    colors.lua          -- Canonical Monokai Pro Ristretto palette
  utils/
    init.lua            -- Utility functions
    picker.lua          -- Shared smart-files helper (git_files vs fd fallback)
    winbar.lua           -- File and LSP-symbol breadcrumbs
  plugins/
    init.lua            -- Calls extras.init(), declares lazy self-spec
    buffer.lua          -- bufferline.nvim
    editor.lua          -- blink.cmp, ufo, which-key, statuscol
    lsp.lua             -- mason, lspconfig (servers from lang files), conform
    treesitter.lua      -- nvim-treesitter (main), context, rainbow delimiters
    trouble.lua         -- trouble.nvim
    fzf-lua.lua         -- fzf-lua picker
    neo-tree.lua        -- File explorer
    mini.lua            -- mini.nvim modules (ai, pairs, notify, surround, etc.)
    snacks.lua          -- snacks.nvim dashboard
    neotest.lua         -- neotest core setup + <leader>T keymaps (adapters supplied by lang files)
    git.lua, ui.lua, tmux.lua, window.lua, dap.lua, dependencies.lua
                         -- ui.lua owns breadcrumbs, outline, diagnostics and indent guides
    lang/               -- Language-specific plugin configs (haskell, java, markdown, python, rust, web, misc)
snippets/               -- snipmate-format snippet files
nvim.version            -- pinned Neovim version (bob's version sync file)
```

## Key Patterns

- **Extras auto-loading:** `extras/init.lua` has an `__index` metamethod — `require("1henrypage.extras").colors` auto-requires `extras/colors.lua`. No explicit import needed.
- **Colors:** All hex color codes live in `extras/colors.lua`. Never hardcode hex values in plugin configs — reference `Colors.*` instead.
- **Lang configs:** All language-specific setup goes in `plugins/lang/`. Never use ftplugin/.
- **Plugin files:** One file per plugin or logical group. Don't consolidate into monolithic files.
- **Theme:** native Monokai Pro Ristretto with solid backgrounds. The canonical palette lives in `extras/colors.lua`; `colors/ristretto.lua` covers editor, syntax, LSP, and plugin highlights without a colorscheme dependency.
- **Snippets:** Both vscode-format (via `from_vscode`) and snipmate-format (via `from_snipmate`) loaders are active.
- **LSP servers:** lang files register servers under `opts.servers` of their `"neovim/nvim-lspconfig"` spec (`{ servers = { basedpyright = { settings = ... } } }`), and `lsp.lua`'s `config` hands each entry to `vim.lsp.config()` and `vim.lsp.enable()`. Never give a lang file's lspconfig spec an `init` or `config`: lazy.nvim deep-merges `opts` across specs of one plugin, but a later spec's `init`/`config` silently *replaces* every earlier one's - that is how `web.lua`'s `init` once disabled marksman, basedpyright and ruff. The same holds for every plugin shared across files (conform, mason-tool-installer, nvim-treesitter, neotest): one file owns `init`/`config`/`build`, the others contribute `opts`. Anything calling `require("blink.cmp")` must go in `config` with `"saghen/blink.cmp"` as a dependency. The main `nvim-lspconfig` spec in `lsp.lua` must have no `event` lazy-trigger (loads at startup) and list `blink.cmp` as a dependency, so capabilities, servers and the `LspAttach` autocmd are registered before any `FileType` event fires (e.g. when opening a file from the dashboard).
- **Inlay hints and code lenses are enabled once, globally** (`vim.lsp.inlay_hint.enable(true)` / `vim.lsp.codelens.enable(true)` in `lsp.lua`), not per buffer from `LspAttach`: enabling per buffer there sends a second `textDocument/codeLens` request at the same document version, and Nvim 0.12.5 then drops the first request's resolved lenses, leaving blank virtual lines (jdtls reference counts).
- **nvim-treesitter is on the `main` rewrite**, not the archived `master` API: there is no `nvim-treesitter.configs`, nothing is enabled by the plugin itself. `treesitter.lua` starts highlighting and indent per buffer from a `FileType` autocmd and installs a missing parser on first use; lang files add parsers to `opts.ensure_installed`. Parsers are compiled with the `tree-sitter` CLI (dotfiles Brewfile) into `stdpath("data")/site`.
- **Plugin versions:** lazy's `defaults.version = false` tracks each plugin's default branch, with `lazy-lock.json` pinning exact commits; many plugins here tag rarely, so `"*"` left them on years-old code. Plugins with a real release train keep an explicit `version` in their spec (blink.cmp `1.*` for its prebuilt fuzzy binary, rustaceanvim, haskell-tools, mini.nvim, bufferline, window-picker, lazy.nvim itself).
- **neotest adapters:** `neotest.lua` owns the core `require("neotest").setup()` call and the `<leader>T` keymaps; it never lists adapters itself. Lang files append adapter module names as strings to `opts.adapters` (merged via `opts_extend = { "adapters" }`), and `neotest.lua`'s `config` resolves each string with `require(name)` before handing them to `setup()`.
- **rustaceanvim owns rust-analyzer:** `rust_analyzer` must never be added to `opts.servers` (and so never reach `vim.lsp.enable()` or `vim.lsp.config()`) - `mrcjkb/rustaceanvim` starts and manages that client itself via `vim.lsp.start`, so it does not inherit the global `vim.lsp.config("*", { capabilities })` from `lsp.lua` and must be given capabilities explicitly (see `lang/rust.lua`, same pattern as `lang/java.lua`'s jdtls setup).
- **which-key labels live at the definition site, not the spec:** `desc` belongs on the `vim.keymap.set` call. The `spec` table in `plugins/editor.lua` exists only for maps whose definition site structurally cannot carry a desc (e.g. `extras/keymaps.lua`'s `map()` helper, `neo-tree.lua`'s literal `{}`, `mini.splitjoin`'s own config), for presentation-only entries like the hidden `<leader>0`-`9` bufferline jumps, and for global fallbacks covering buffer-local LSP maps (`<leader>th` and `<leader>tl` are created on `LspAttach`, so without fallbacks their labels vanish in non-LSP buffers). Don't "clean up" spec entries that look redundant with a definition-site desc without checking which of these reasons applies.
