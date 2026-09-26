local function path_is_dir(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.type == "directory"
end

local function path_is_file(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.type == "file"
end

local function yarn_root(bufnr)
  local root = vim.fs.root(bufnr, { "yarn.lock" })
  local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" })

  if deno_root and (not root or #deno_root >= #root) then
    return nil
  end

  return root
end

local function is_pnp_project(root)
  return path_is_file(root .. "/.pnp.cjs") or path_is_file(root .. "/.pnp.js")
end

local missing_tsdk_notified = {}

local function workspace_tsdk(root)
  if is_pnp_project(root) then
    local sdk = root .. "/.yarn/sdks/typescript/lib"
    if path_is_dir(sdk) then
      return sdk
    end
    return nil, "Yarn PnP project has no TypeScript SDK"
  end

  local sdk = root .. "/node_modules/typescript/lib"
  if path_is_dir(sdk) then
    return sdk
  end

  return nil, "Project has no local TypeScript SDK"
end

local function vtsls_root_dir(bufnr, on_dir)
  local root = yarn_root(bufnr)
  if not root then
    return
  end

  local _, err = workspace_tsdk(root)
  if err then
    if not missing_tsdk_notified[root] then
      missing_tsdk_notified[root] = true
      vim.schedule(function()
        local pnp_instruction = is_pnp_project(root) and " and run `yarn dlx @yarnpkg/sdks base`" or ""
        vim.notify(err .. ": install TypeScript locally" .. pnp_instruction, vim.log.levels.WARN, { title = "vtsls" })
      end)
    end
    return
  end

  on_dir(root)
end

local function package_has_dependency(root, name)
  local package_json = root .. "/package.json"
  if not path_is_file(package_json) then
    return false
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_json), "\n"))
  if not ok then
    return false
  end

  for _, field in ipairs({ "dependencies", "devDependencies", "peerDependencies", "optionalDependencies" }) do
    if decoded[field] and decoded[field][name] then
      return true
    end
  end

  return false
end

local function yarn_prettier_available(_, ctx)
  local root = yarn_root(ctx.buf)
  return root ~= nil and vim.fn.executable("yarn") == 1 and package_has_dependency(root, "prettier")
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "css",
        "html",
        "javascript",
        "json",
        "scss",
        "tsx",
        "typescript",
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = { ensure_installed = { "vtsls", "eslint-lsp" } },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          root_dir = vtsls_root_dir,
          before_init = function(_, config)
            local tsdk = workspace_tsdk(config.root_dir)
            config.settings.vtsls.typescript = config.settings.vtsls.typescript or {}
            config.settings.vtsls.typescript.globalTsdk = tsdk
          end,
          settings = {
            vtsls = {
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = { enableServerSideFuzzyMatch = true },
              },
            },
            typescript = {
              suggest = { completeFunctionCalls = true },
              updateImportsOnFileMove = { enabled = "always" },
              inlayHints = {
                parameterNames = { enabled = "literals" },
                enumMemberValues = { enabled = true },
              },
            },
            javascript = {
              suggest = { completeFunctionCalls = true },
              updateImportsOnFileMove = { enabled = "always" },
              inlayHints = {
                parameterNames = { enabled = "literals" },
                enumMemberValues = { enabled = true },
              },
            },
          },
        },
        eslint = {
          settings = {
            format = false,
            workingDirectory = { mode = "auto" },
          },
          on_attach = function(client, bufnr)
            vim.api.nvim_buf_create_user_command(bufnr, "LspEslintFixAll", function()
              client:request_sync("workspace/executeCommand", {
                command = "eslint.applyAllFixes",
                arguments = {
                  {
                    uri = vim.uri_from_bufnr(bufnr),
                    version = vim.lsp.util.buf_versions[bufnr],
                  },
                },
              }, nil, bufnr)
            end, {})
            vim.keymap.set("n", "<leader>cf", "<cmd>LspEslintFixAll<cr>", {
              buffer = bufnr,
              silent = true,
              desc = "fix all",
            })
          end,
        },
      },
    },
  },

  {
    "yioneko/nvim-vtsls",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("vtsls").config({ refactor_auto_rename = true })

      vim.lsp.commands["editor.action.showReferences"] = function(command, ctx)
        local locations = command.arguments[3]
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if locations and #locations > 0 and client then
          local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
          vim.fn.setloclist(0, {}, " ", { title = "References", items = items, context = ctx })
          vim.cmd.lopen()
        end
      end
    end,
    keys = {
      { "<leader>co", "<cmd>VtsExec organize_imports<cr>", desc = "organize imports" },
      { "<leader>cM", "<cmd>VtsExec add_missing_imports<cr>", desc = "add missing imports" },
      { "<leader>cu", "<cmd>VtsExec remove_unused_imports<cr>", desc = "remove unused imports" },
      { "<leader>cR", "<cmd>VtsExec rename_file<cr>", desc = "rename file" },
      { "<leader>cV", "<cmd>VtsExec select_ts_version<cr>", desc = "select TypeScript version" },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        yarn_prettier = {
          command = "yarn",
          args = { "exec", "prettier", "--stdin-filepath", "$FILENAME" },
          stdin = true,
          cwd = function(_, ctx)
            return yarn_root(ctx.buf)
          end,
          require_cwd = true,
          condition = yarn_prettier_available,
        },
      },
      formatters_by_ft = {
        javascript = { "yarn_prettier" },
        typescript = { "yarn_prettier" },
        javascriptreact = { "yarn_prettier" },
        typescriptreact = { "yarn_prettier" },
        json = { "yarn_prettier" },
        css = { "yarn_prettier" },
        html = { "yarn_prettier" },
      },
    },
  },
}
