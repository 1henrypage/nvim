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

        -- debug/test bundles: the jars each VS Code extension declares for jdtls
        -- (contributes.javaExtensions), minus any jdtls already ships. Globbing the server dirs
        -- also picks up the test runner and jacoco agent, which are not bundles, and a bundle
        -- installed twice (java-test >= 0.46 carries jdtls' own asm jars) fails jdtls'
        -- whole "Load bundle list" step.
        local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
        local shipped = {}
        for _, jar in ipairs(vim.fn.glob(jdtls_path .. "/plugins/*.jar", true, true)) do
          shipped[vim.fs.basename(jar)] = true
        end
        local bundles = {}
        for _, name in ipairs({ "java-debug-adapter", "java-test" }) do
          local extension = mason_packages .. "/" .. name .. "/extension"
          local manifest = extension .. "/package.json"
          if vim.fn.filereadable(manifest) == 1 then
            local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(manifest), "\n"))
            local declared = ok and decoded.contributes and decoded.contributes.javaExtensions or {}
            for _, relative in ipairs(declared) do
              local jar = extension .. "/" .. (relative:gsub("^%./", ""))
              if not shipped[vim.fs.basename(jar)] and vim.fn.filereadable(jar) == 1 then
                table.insert(bundles, jar)
              end
            end
          end
        end

        -- Spring Boot's Java-side features (annotation/bean completion, code actions) run inside
        -- jdtls as extensions; spring-boot.nvim below runs the language server itself.
        local ok_spring, spring_boot = pcall(require, "spring_boot")
        if ok_spring then
          vim.list_extend(bundles, spring_boot.java_extensions())
        end

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

            local function opts(desc)
              return { buffer = bufnr, noremap = true, silent = true, desc = desc }
            end
            vim.keymap.set("n", "<leader>co", require("jdtls").organize_imports, opts("organize imports"))
            vim.keymap.set("n", "<leader>cv", require("jdtls").extract_variable, opts("extract variable"))
            vim.keymap.set("v", "<leader>cv", function()
              require("jdtls").extract_variable(true)
            end, opts("extract variable"))
            vim.keymap.set("n", "<leader>cm", require("jdtls").extract_method, opts("extract method"))
            vim.keymap.set("v", "<leader>cm", function()
              require("jdtls").extract_method(true)
            end, opts("extract method"))
            vim.keymap.set("n", "<leader>cT", require("jdtls.dap").test_class, opts("test class"))
            vim.keymap.set("n", "<leader>ct", require("jdtls.dap").test_nearest_method, opts("test nearest method"))
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

  -- Spring Boot LS: application.properties/yml completion and navigation, bean and endpoint
  -- symbols. Registers itself through vim.lsp.config()/enable() and finds mason's jar.
  {
    "JavaHello/spring-boot.nvim",
    ft = { "java", "yaml", "jproperties" },
    dependencies = { "mfussenegger/nvim-jdtls" },
    opts = {
      -- only in projects that actually depend on Spring Boot, not every Java/YAML buffer
      project_filter = function(root_dir)
        return require("spring_boot.util").has_spring_boot_dependency(root_dir)
      end,
      -- The server is itself a Spring Boot app whose embedded web server hosts an experimental MCP
      -- endpoint. VS Code keeps it off by default with exactly this flag; so do we (no localhost
      -- port, no notification on every start).
      jvm_args = { "-Dspring.main.web-application-type=NONE" },
    },
  },
}
