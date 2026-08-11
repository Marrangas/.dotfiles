return {
    {
        'hrsh7th/nvim-cmp',
        event = { 'InsertEnter', 'CmdlineEnter' },
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'saadparwaiz1/cmp_luasnip',
            {
                'L3MON4D3/LuaSnip',
                version = 'v2.*',
                build = (function()
                    if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
                    return 'make install_jsregexp'
                end)(),
                config = function()
                    local luasnip = require 'luasnip'
                    luasnip.config.setup {
                        history = true,
                        delete_check_events = 'TextChanged',
                    }
                    require('luasnip.loaders.from_lua').lazy_load {
                        paths = { vim.fn.stdpath 'config' .. '/luasnippets' },
                    }

                    luasnip.filetype_extend('zsh', { 'sh' })
                end,
            },
            'doxnit/cmp-luasnip-choice',
        },
        config = function()
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'

            require('cmp_luasnip_choice').setup {
                auto_open = true,
            }

            -- Smart fallback logic for Wiki completions (Experimental -> Pro)
            local ok_xp, exp_wiki = pcall(require, 'xperiments.wiki_completions')
            local ok_pro, pro_wiki = pcall(require, 'util.wiki_completions')
            
            if ok_xp and exp_wiki then
                cmp.register_source('wiki_exp', exp_wiki.new())
            end
            
            if ok_pro and pro_wiki then
                cmp.register_source('wiki', pro_wiki.new())
            end

            cmp.setup {
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm { select = true },
                    ['<C-y>'] = cmp.mapping.confirm { select = true },
                    
                    -- Intelligent Tab jumping through snippet placeholders
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                },

                -- Order matters here: top items have higher priority
                sources = cmp.config.sources({
                    { name = 'luasnip_choice' }, -- This now comes from the doxnit community plugin
                    { name = 'luasnip' },
                    { name = 'nvim_lsp' },
                    { name = 'wiki_exp', priority = 100 }, -- Uses experimental if it exists
                    { name = 'wiki', priority = 100 },     -- Uses stable if experimental fails
                    { name = 'path' },
                }, {
                    { name = 'buffer' },
                }),
            }
        end,
    },
}
