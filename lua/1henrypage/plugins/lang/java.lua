return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { ensure_installed = { "java" } },
    },

    {
        "williamboman/mason-lspconfig.nvim",
        opts = { ensure_installed = { "jdtls" } },
    },

    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            ensure_installed = {
                "google-java-format",
                "java-debug-adapter",
                "java-test",
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
        ft = "java",
        config = function()
            local function setup_jdtls()
                local mason_registry = require("mason-registry")

                -- jdtls paths
                local jdtls_pkg = mason_registry.get_package("jdtls")
                local jdtls_path = jdtls_pkg:get_install_path()
                local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
                local lombok = jdtls_path .. "/lombok.jar"

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
                local bundles = {}

                if mason_registry.is_installed("java-debug-adapter") then
                    local debug_pkg = mason_registry.get_package("java-debug-adapter")
                    local debug_jar = vim.fn.glob(
                        debug_pkg:get_install_path() .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"
                    )
                    if debug_jar ~= "" then
                        table.insert(bundles, debug_jar)
                    end
                end

                if mason_registry.is_installed("java-test") then
                    local test_pkg = mason_registry.get_package("java-test")
                    local test_jars = vim.fn.glob(
                        test_pkg:get_install_path() .. "/extension/server/*.jar",
                        true,
                        true
                    )
                    vim.list_extend(bundles, test_jars)
                end

                local capabilities = require("cmp_nvim_lsp").default_capabilities()

                local config = {
                    cmd = {
                        "java",
                        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                        "-Dosgi.bundles.defaultStartLevel=4",
                        "-Declipse.product=org.eclipse.jdt.ls.core.product",
                        "-Dlog.level=ALL",
                        "-Xmx2G",
                        "--add-modules=ALL-SYSTEM",
                        "--add-opens", "java.base/java.util=ALL-UNNAMED",
                        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                        "-javaagent:" .. lombok,
                        "-jar", launcher,
                        "-configuration", jdtls_path .. "/" .. os_config,
                        "-data", workspace_dir,
                    },
                    root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
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
                        },
                    },
                    init_options = {
                        bundles = bundles,
                    },
                    capabilities = capabilities,
                    on_attach = function(_, bufnr)
                        require("jdtls").setup_dap({ hotcodereplace = "auto" })
                        require("jdtls.dap").setup_dap_main_class_configs()

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

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = setup_jdtls,
            })

            -- trigger immediately if already in a java buffer
            if vim.bo.filetype == "java" then
                setup_jdtls()
            end
        end,
    },
}
