return {
        'saghen/blink.cmp',
        event = 'VimEnter',
        version = '1.*',
        dependencies = {
            {
                'L3MON4D3/LuaSnip',
                version = '2.*',
                build = (function()
                    -- This step is not supported in many windows environments.
                    if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
                    return 'make install_jsregexp'
                end)(),
                opts = {},
            },
        },
        --- @module 'blink.cmp'
        --- @type blink.cmp.Config
        opts = {
            -- See :h blink-cmp-config-keymap for defining your own keymap
            -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
            --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps

            completion = {
                documentation = { auto_show = false },
                menu = { scrolloff = 2 },
                trigger = {
                    show_on_keyword = false,
                    show_on_trigger_character = true,
                },
            },
            sources = {
                default = { 'lsp', 'path', 'snippets' },
            },
            snippets = { preset = 'luasnip' },

            -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
            -- which automatically downloads a prebuilt binary when enabled.
            -- See :h blink-cmp-config-fuzzy for more information
            fuzzy = { implementation = 'prefer_rust' },
            signature = { enabled = true },
        },
}
