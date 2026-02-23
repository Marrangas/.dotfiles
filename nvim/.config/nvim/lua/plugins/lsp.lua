-- LSP is an acronym you've probably heard, but might not understand what it is.
--
-- LSP stands for Language Server Protocol. It's a protocol that helps editors
-- and language tooling communicate in a standardized fashion.
--
-- In general, you have a "server" which is some tool built to understand a particular
-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc). These Language Servers
-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
-- processes that communicate with some "client" - in this case, Neovim!
--
-- LSP provides Neovim with features like:
--  - Go to definition
--  - Find references
--  - Autocompletion
--  - Symbol Search
--  - and more!
--
-- Thus, Language Servers are external tools that must be installed separately from
-- Neovim. This is where `mason` and related plugins come into play.
--
-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
-- and elegantly composed help section, `:help lsp-vs-treesitter`

return { -- LSP Configuration & Plugins
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',

            -- Useful status updates for LSP.
            { 'j-hui/fidget.nvim', opts = {} },
        },
        config = function()
            --  This function gets run when an LSP attaches to a particular buffer.
            --    That is to say, every time a new file is opened that is associated with
            --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --    function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    -- In this case, we create a function that lets us more easily define mappings specific
                    -- for LSP related items. It sets the mode, buffer and description for us each time.
                    local map = function(keys, func, desc)
                        vim.keymap.set(
                            'n',
                            keys,
                            func,
                            { buffer = event.buf, desc = 'LSP: ' .. desc }
                        )
                    end

                    -- Jump to the definition of the word under your cursor.
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-T>.
                    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

                    --  This is not Goto Definition, this is Goto Declaration.
                    --  For example, in C this would take you to the header
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    -- Find references for the word under your cursor.
                    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

                    -- Jump to the implementation of the word under your cursor.
                    --  Useful when your language has ways of declaring types without an actual implementation.
                    map(
                        'gI',
                        require('telescope.builtin').lsp_implementations,
                        '[G]oto [I]mplementation'
                    )

                    -- Jump to the type of the word under your cursor.
                    --  Useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map(
                        '<leader>D',
                        require('telescope.builtin').lsp_type_definitions,
                        'Type [D]efinition'
                    )

                    -- Fuzzy find all the symbols in your current document.
                    --  Symbols are things like variables, functions, types, etc.
                    map(
                        '<leader>ds',
                        require('telescope.builtin').lsp_document_symbols,
                        '[D]ocument [S]ymbols'
                    )

                    -- Fuzzy find all the symbols in your current workspace
                    --  Similar to document symbols, except searches over your whole project.
                    map(
                        '<leader>ws',
                        require('telescope.builtin').lsp_dynamic_workspace_symbols,
                        '[W]orkspace [S]ymbols'
                    )

                    -- Rename the variable under your cursor
                    --  Most Language Servers support renaming across files, etc.
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your LSP for this to activate.
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                    -- Opens a popup that displays documentation about the word under your cursor
                    --  See `:help K` for why this keymap
                    map('K', vim.lsp.buf.hover, 'Hover Documentation')

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.clear_references,
                        })
                    end
                end,
            })

            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP Specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.

            --stylua: ignore start
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
            --stylua: ignore end

            -- Enable the following language servers
            --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
            --
            --  Add any additional override configuration in the following tables. Available keys are:
            --  - cmd (table): Override the default command used to start the server
            --  - filetypes (table): Override the default list of associated filetypes for the server
            --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
            --  - settings (table): Override the default settings passed when initializing the server.
            --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
            local servers = {
                ansiblels = {
                    filetypes = { 'yml.ansible' },
                    settings = {
                        ansible = {
                            ansible = { path = 'ansible', useFullyQualifiedCollectionNames = true },
                            ansibleLint = { enabled = true, path = 'ansible-lint' },
                            executionEnvironment = { enabled = false },
                            -- python = {
                            --   interpreterPath = 'python',
                            -- },
                            completion = {
                                provideRedirectModules = true,
                                provideModuleOptionAliases = true,
                            },
                        },
                    },
                    flags = {
                        debounce_text_changes = 500, -- Don't send updates to the server too fast
                    },
                },

                terraformls = {
                    filetypes = {
                        'terraform',
                        'terraform-vars',
                    },
                    settings = {
                        prefillRequiredFields = true,
                        ignoreDirectoryNames = {
                            '.git',
                            '.idea',
                            '.vscode',
                            'terraform.tfstate.d',
                            '.terragrunt-cache',
                        },
                        enableEnhancedValidation = true,
                    },
                },

                yamlls = {
                    settings = {
                        yaml = {
                            schemas = {
                                kubernetes = '*.yaml',
                                ['https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json'] = '/*.k8s.yaml',
                                ['http://json.schemastore.org/github-workflow'] = '.github/workflows/*',
                                ['http://json.schemastore.org/github-action'] = '.github/action.{yml,yaml}',
                                ['http://json.schemastore.org/ansible-stable-2.9'] = 'roles/tasks/*.{yml,yaml}',
                                -- ['http://json.schemastore.org/prettierrc'] = '.prettierrc.{yml,yaml}',
                                ['http://json.schemastore.org/kustomization'] = 'kustomization.{yml,yaml}',
                                ['http://json.schemastore.org/ansible-playbook'] = '*play*.{yml,yaml}',
                                ['http://json.schemastore.org/chart'] = 'Chart.{yml,yaml}',
                                ['https://json.schemastore.org/dependabot-v2'] = '.github/dependabot.{yml,yaml}',
                                ['https://json.schemastore.org/gitlab-ci'] = '*gitlab-ci*.{yml,yaml}',
                                ['https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json'] = '*api*.{yml,yaml}',
                                ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = '*docker-compose*.{yml,yaml}',
                                ['https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json'] = '*flow*.{yml,yaml}',
                            },
                        },
                    },
                },

                bashls = {
                    cmd = { 'bash-language-server', 'start' },
                    filetypes = { 'sh', 'bash' },
                },

                lua_ls = {
                    -- cmd = {...},
                    -- filetypes { ...},
                    -- capabilities = {},
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            workspace = {
                                checkThirdParty = false,
                                -- Tells lua_ls where to find all the Lua files that you have loaded
                                -- for your neovim configuration.
                                library = {
                                    '${3rd}/luv/library',
                                    unpack(vim.api.nvim_get_runtime_file('', true)),
                                },
                                -- If lua_ls is really slow on your computer, you can try this instead:
                                -- library = { vim.env.VIMRUNTIME },
                            },
                            completion = {
                                callSnippet = 'Replace',
                            },
                            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                            -- diagnostics = { disable = { 'missing-fields' } },
                        },
                    },
                },

                gopls = {},
                -- pyright = {},
                -- rust_analyzer = {},
                -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
                --
                -- Some languages (like typescript) have entire language plugins that can be useful:
                --    https://github.com/pmizio/typescript-tools.nvim
                --
                -- But for many setups, the LSP (`tsserver`) will work just fine
                -- tsserver = {},
                --
                pylsp = {
                    settings = {
                        pylsp = {
                            plugins = {
                                pycodestyle = {
                                    enabled = true,
                                    ignore = { 'E501', 'E201' },
                                    maxLineLength = 120,
                                },
                            },
                        },
                    },
                },
                htmx = {
                    filetypes = { 'html', 'templ' },
                    -- :LspStart htx
                },
                markdown_oxide = {
                    -- Ensure that dynamicRegistration is enabled! This allows the LS to take into account actions like the
                    -- Create Unresolved File code action, resolving completions for unindexed code blocks, ...
                    capabilities = {
                        workspace = {
                            didChangeWatchedFiles = {
                                dynamicRegistration = true,
                            },
                        },
                    },
                    -- Force attachment to current directory if no obsidian/git root is found
                    root_dir = function()
                        return vim.fn.getcwd()
                    end,
                },
            }

            -- Ensure the servers and tools above are installed
            --  To check the current status of installed tools and/or manually install
            --  other tools, you can run
            --    :Mason
            --
            --  You can press `g?` for help in this menu
            require('mason').setup()

            -- You can add other tools here that you want Mason to install
            -- for you, so that they are available from within Neovim.
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                'stylua', -- Used to format lua code
                'shfmt',
                'shellharden',
                'shellcheck',
                'tflint',
                'tfsec',
                'html-lsp',
                'templ',
                'prettierd',
                'cssls',
            })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            for name, server in pairs(servers) do
                server.capabilities =
                    vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                vim.lsp.config(name, server)
                vim.lsp.enable(name)
            end

            vim.lsp.config('lua_ls', {
                on_init = function(client)
                    if client.workspace_folders then
                        local path = client.workspace_folders[1].name
                        if
                            path ~= vim.fn.stdpath 'config'
                            and (
                                vim.uv.fs_stat(path .. '/.luarc.json')
                                or vim.uv.fs_stat(path .. '/.luarc.jsonc')
                            )
                        then
                            return
                        end
                    end

                    client.config.settings.Lua =
                        vim.tbl_deep_extend('force', client.config.settings.Lua, {
                            runtime = {
                                version = 'LuaJIT',
                                path = { 'lua/?.lua', 'lua/?/init.lua' },
                            },
                            workspace = {
                                checkThirdParty = false,
                                -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                                --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                                library = vim.api.nvim_get_runtime_file('', true),
                            },
                        })
                end,
                settings = {
                    Lua = {},
                },
            })
            vim.lsp.enable 'lua_ls'
        end,
    },
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false },
    },
}
--   -- Highlight todo, notes, etc in comments
--   { -- Linting
--     'mfussenegger/nvim-lint',
--     event = { 'BufReadPre', 'BufNewFile' },
--     config = function()
--       local lint = require 'lint'
--       lint.linters_by_ft = {
--         markdown = { 'markdownlint' },
--       }
--
--       -- To allow other plugins to add linters to require('lint').linters_by_ft,
--       -- instead set linters_by_ft like this:
--       -- lint.linters_by_ft = lint.linters_by_ft or {}
--       -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
--       --
--       -- However, note that this will enable a set of default linters,
--       -- which will cause errors unless these tools are available:
--       -- {
--       --   clojure = { "clj-kondo" },
--       --   dockerfile = { "hadolint" },
--       --   inko = { "inko" },
--       --   janet = { "janet" },
--       --   json = { "jsonlint" },
--       --   markdown = { "vale" },
--       --   rst = { "vale" },
--       --   ruby = { "ruby" },
--       --   terraform = { "tflint" },
--       --   text = { "vale" }
--       -- }
--       --
--       -- You can disable the default linters by setting their filetypes to nil:
--       -- lint.linters_by_ft['clojure'] = nil
--       -- lint.linters_by_ft['dockerfile'] = nil
--       -- lint.linters_by_ft['inko'] = nil
--       -- lint.linters_by_ft['janet'] = nil
--       -- lint.linters_by_ft['json'] = nil
--       -- lint.linters_by_ft['markdown'] = nil
--       -- lint.linters_by_ft['rst'] = nil
--       -- lint.linters_by_ft['ruby'] = nil
--       -- lint.linters_by_ft['terraform'] = nil
--       -- lint.linters_by_ft['text'] = nil
--
--       -- Create autocommand which carries out the actual linting
--       -- on the specified events.
--       local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
--       vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
--         group = lint_augroup,
--         callback = function()
--           -- Only run the linter in buffers that you can modify in order to
--           -- avoid superfluous noise, notably within the handy LSP pop-ups that
--           -- describe the hovered symbol using Markdown.
--           if vim.bo.modifiable then lint.try_lint() end
--         end,
--       })
--     end,
--   },
-- }
