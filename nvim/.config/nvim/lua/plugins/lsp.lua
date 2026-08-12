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
            'b0o/SchemaStore.nvim',
            'someone-stole-my-name/yaml-companion.nvim',

            -- Useful status updates for LSP.
            { 'j-hui/fidget.nvim', opts = {} },
        },
        config = function()
            --  This function gets run when an LSP attaches to a particular buffer.
            --    That is to say, every time a new file is opened that is associated with
            --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
            --    function will be executed to configure the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
                callback = function(event)
                    -- In this case, we create a function that lets us more easily define mappings specific
                    -- for LSP related items. It sets the mode, buffer and description for us each time.
                    local map = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc }) end

                    -- Jump to the definition of the word under your cursor.
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-T>.
                    map('gd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')

                    --  This is not Goto Definition, this is Goto Declaration.
                    --  For example, in C this would take you to the header
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    -- Find references for the word under your cursor.
                    map('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')

                    -- Jump to the implementation of the word under your cursor.
                    --  Useful when your language has ways of declaring types without an actual implementation.
                    map('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')

                    -- Jump to the type of the word under your cursor.
                    --  Useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map('<leader>D', function() Snacks.picker.lsp_type_definitions() end, 'Type [D]efinition')

                    -- Fuzzy find all the symbols in your current document.
                    --  Symbols are things like variables, functions, types, etc.
                    map('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')

                    -- Fuzzy find all the symbols in your current workspace
                    --  Similar to document symbols, except searches over your whole project.
                    map('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')

                    -- Rename the variable under your cursor
                    --  Most Language Servers support renaming across files, etc.
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your LSP for this to activate.
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                    -- Select YAML Schema (using yaml-companion and Snacks.picker via vim.ui.select)
                    if vim.bo[event.buf].filetype == 'yaml' then
                        map('<leader>ys', function() require('yaml-companion').open_ui_select() end, 'Select [Y]AML [S]chema')
                    end

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
            capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = true }
            capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
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
                        debounce_text_changes = 500,
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
                            schemaStore = {
                                enable = false,
                                url = '',
                            },
                            -- Combine SchemaStore schemas with explicit Kubernetes mapping
                            schemas = vim.tbl_deep_extend('force', require('schemastore').yaml.schemas(), {
                                -- Force Kubernetes schema on these files
                                kubernetes = {
                                    'container_resources.yaml',
                                    'hpa.yaml',
                                    'service_account.yaml',
                                    'deployment.yaml',
                                },
                                -- Force Kustomize schema on kustomization files
                                ['https://json.schemastore.org/kustomization.json'] = {
                                    'kustomization.yaml',
                                    'kustomization.yml',
                                },
                            }),
                            kubernetesCRDStore = {
                                enable = true,
                            },
                        },
                    },
                },

                jsonls = {
                    settings = {
                        json = {
                            schemas = require('schemastore').json.schemas(),
                            validate = { enable = true },
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
                -- But for many setups, the LSP (`ts_ls`) will work just fine
                -- ts_ls = {},
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

                -- htmx = {
                --     filetypes = { 'html', 'templ', --[[ 'markdown'  ]]}, --
                --     on_attach = function(client, bufnr)
                --         if vim.bo[bufnr].filetype == 'markdown' then
                --             local path = vim.api.nvim_buf_get_name(bufnr)
                --             local home = vim.uv.os_homedir()
                --
                --             local is_allowed_path = path:match(home .. '/Documents/marrangas')
                --                 or path:match 'marranwwwas'
                --
                --             if not is_allowed_path then
                --                 client.stop()
                --                 return
                --             end
                --
                --             -- 2. Filtro por contenido (primeras 200 líneas)
                --             local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 200, false)
                --             local has_htmx_attr = false
                --             for _, line in ipairs(lines) do
                --                 if line:match 'hx%-' then
                --                     has_htmx_attr = true
                --                     break
                --                 end
                --             end
                --
                --             if not has_htmx_attr then client.stop() end
                --         end
                --     end,
                -- },

                markdown_oxide = {
                    filetypes = { 'markdown' },
                    capabilities = {
                        workspace = {
                            didChangeWatchedFiles = {
                                dynamicRegistration = false,
                            },
                        },
                    },
                    settings = {
                        new_file_folder_path = 'notes',
                    },
                    root_dir = function(fname)
                        local util = require 'lspconfig.util'
                        return util.root_pattern('.git', '.obsidian')(fname) or util.path.dirname(fname)
                    end,
                },
            }

            -- Dynamic LSP servers filtering from DOTFILE_LSP_SERVERS env variable loaded directly
            local lsp_env = vim.env.DOTFILE_LSP_SERVERS
            if lsp_env and lsp_env ~= '' then
                local lsp_list = {}
                for _, name in ipairs(vim.split(lsp_env, ',')) do
                    lsp_list[name] = servers[name] or {}
                end
                servers = lsp_list
            end

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
                'prettierd',
            })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            require('mason-lspconfig').setup {
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

                        -- Special handling for lua_ls
                        if server_name == 'lua_ls' then
                            server.on_init = function(client)
                                if client.workspace_folders then
                                    local path = client.workspace_folders[1].name
                                    if
                                        path ~= vim.fn.stdpath 'config'
                                        and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
                                    then
                                        return
                                    end
                                end
                                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                                    runtime = {
                                        version = 'LuaJIT',
                                        path = { 'lua/?.lua', 'lua/?/init.lua' },
                                    },
                                    workspace = {
                                        checkThirdParty = false,
                                        library = vim.api.nvim_get_runtime_file('', true),
                                    },
                                })
                            end
                        end

                        -- Special handling for yamlls with yaml-companion
                        if server_name == 'yamlls' then
                            local companion = require('yaml-companion').setup {
                                builtin_matchers = {
                                    kubernetes = { enabled = true },
                                },
                                lspconfig = {
                                    capabilities = server.capabilities,
                                    settings = server.settings or {},
                                },
                            }
                            require('lspconfig')[server_name].setup(companion)
                            return
                        end

                        require('lspconfig')[server_name].setup(server)
                    end,
                },
            }
        end,
    },
}
