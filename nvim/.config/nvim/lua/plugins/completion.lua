return {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
        {
            'L3MON4D3/LuaSnip',
            version = 'v2.*',
            build = (function()
                if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
                return 'make install_jsregexp'
            end)(),
            config = function()
                local luasnip = require('luasnip')
                luasnip.config.setup({
                    history = true,
                    delete_check_events = 'TextChanged',
                })
                -- Load lua-style snippets natively
                require('luasnip.loaders.from_lua').lazy_load({
                    paths = { vim.fn.stdpath('config') .. '/luasnippets' },
                })

                -- Extend zsh filetype to include sh snippets under LuaSnip
                luasnip.filetype_extend('zsh', { 'sh' })

                -- Autocommand to trigger native LuaSnip choice selector automatically upon entering choice nodes
                local luasnip_choice_group =
                    vim.api.nvim_create_augroup('LuaSnipChoiceSelect', { clear = true })
                vim.api.nvim_create_autocmd('User', {
                    pattern = 'LuasnipChoiceNodeEnter',
                    group = luasnip_choice_group,
                    callback = function()
                        vim.schedule(function()
                            if luasnip.choice_active() then
                                require('luasnip.extras.select_choice')()
                            end
                        end)
                    end,
                })
            end,
        },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
        -- See :h blink-cmp-config-keymap for defining your own keymap
        completion = {
            documentation = { auto_show = false },
            menu = { scrolloff = 2 },
            trigger = {
                show_on_keyword = true,
                show_on_trigger_character = true,
            },
        },
        sources = {
            default = { 'lsp', 'path', 'snippets', 'wiki_metadata' },
            providers = {
                snippets = {
                    min_keyword_length = 4,
                },
                wiki_metadata = {
                    name = 'Wiki Frontmatter',
                    module = 'util.wiki_completions',
                    score_offset = 100, -- Give frontmatter values higher sorting priority!
                },
            },
        },
        snippets = { preset = 'luasnip' },

        -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
        -- which automatically downloads a prebuilt binary when enabled.
        -- See :h blink-cmp-config-fuzzy for more information
        fuzzy = { implementation = 'prefer_rust' },
        signature = { enabled = true },
    },
}
