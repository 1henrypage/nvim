return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "jdtls",
        "google-java-format",
        "java-debug-adapter",
        "java-test",
        "vscode-spring-boot-tools",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        java = { "google-java-format" },
      },
    },
  },

  {
    "mfussenegger/nvim-jdtls",
    event = { "BufReadPost *.java", "BufEnter *.java" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      local function setup_jdtls()
        -- ensure treesitter highlighting immediately (before jdtls finishes loading)
        local bufnr = vim.api.nvim_get_current_buf()
        if not vim.treesitter.highlighter.active[bufnr] then
          vim.treesitter.start(bufnr, "java")
        end

        -- jdtls paths
        local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
        if vim.fn.isdirectory(jdtls_path) == 0 then
          vim.notify("jdtls not installed — run :MasonInstall jdtls", vim.log.levels.WARN)
          return
        end

        local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local lombok = jdtls_path .. "/lombok.jar"

        if launcher == "" then
          vim.notify("jdtls launcher jar not found in " .. jdtls_path, vim.log.levels.ERROR)
          return
        end

        local os_config
        if vim.fn.has("mac") == 1 then
          os_config = "config_mac"
        elseif vim.fn.has("unix") == 1 then
          os_config = "config_linux"
        else
          os_config = "config_win"
        end

        -- per-project workspace directory
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = vim.fn.expand("~/.cache/jdtls-workspace/") .. project_name

        -- debug/test bundles
        local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
        local bundles = {}

        local debug_jar =
          vim.fn.glob(mason_packages .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar")
        if debug_jar ~= "" then
          table.insert(bundles, debug_jar)
        end

        local test_jars = vim.fn.glob(mason_packages .. "/java-test/extension/server/*.jar", true, true)
        vim.list_extend(bundles, test_jars)

        local capabilities = require("blink.cmp").get_lsp_capabilities()

        local config = {
          cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.level=ERROR",
            "-Xmx2G",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
            "-javaagent:" .. lombok,
            "-jar",
            launcher,
            "-configuration",
            jdtls_path .. "/" .. os_config,
            "-data",
            workspace_dir,
          },
          root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" }),
          settings = {
            java = {
              eclipse = { downloadSources = true },
              configuration = { updateBuildConfiguration = "interactive" },
              maven = { downloadSources = true },
              implementationsCodeLens = { enabled = true },
              referencesCodeLens = { enabled = true },
              references = { includeDecompiledSources = true },
              inlayHints = { parameterNames = { enabled = "all" } },
              signatureHelp = { enabled = true },
              import = {
                gradle = {
                  enabled = true,
                  wrapper = { enabled = true },
                },
              },
            },
          },
          init_options = {
            bundles = bundles,
          },
          capabilities = capabilities,
          on_attach = function(_, bufnr)
            require("jdtls").setup_dap({ hotcodereplace = "auto" })
            require("jdtls.dap").setup_dap_main_class_configs()

            -- Spring Boot LS: application.properties completions, bean navigation, Actuator live data
            local spring_ls = vim.fn.stdpath("data") .. "/mason/packages/vscode-spring-boot-tools/language-server.jar"
            if vim.fn.filereadable(spring_ls) == 1 then
              vim.lsp.start({
                name = "spring-boot-ls",
                cmd = { "java", "-jar", spring_ls },
                root_dir = vim.fs.root(0, { "pom.xml", "build.gradle", ".git" }),
              }, { bufnr = bufnr, reuse_client = true })
            end

            local opts = { buffer = bufnr, noremap = true, silent = true }
            vim.keymap.set("n", "<leader>co", require("jdtls").organize_imports, opts)
            vim.keymap.set("n", "<leader>cv", require("jdtls").extract_variable, opts)
            vim.keymap.set("v", "<leader>cv", function()
              require("jdtls").extract_variable(true)
            end, opts)
            vim.keymap.set("n", "<leader>cm", require("jdtls").extract_method, opts)
            vim.keymap.set("v", "<leader>cm", function()
              require("jdtls").extract_method(true)
            end, opts)
            vim.keymap.set("n", "<leader>cT", require("jdtls.dap").test_class, opts)
            vim.keymap.set("n", "<leader>ct", require("jdtls.dap").test_nearest_method, opts)
          end,
        }

        require("jdtls").start_or_attach(config)
      end

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
        pattern = "*.java",
        callback = setup_jdtls,
      })

      -- handle jdt:// URIs so go-to-definition works on dependency classes
      vim.api.nvim_create_autocmd("BufReadCmd", {
        pattern = "jdt://*",
        callback = function(args)
          require("jdtls").open_jdt_link(args.match)
        end,
      })
    end,
  },
}
