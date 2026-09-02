---@diagnostic disable: undefined-global vim
return {
    {

        'L3MON4D3/LuaSnip',
        dependencies = {
            'saadparwaiz1/cmp_luasnip',
            'doxnit/cmp-luasnip-choice',
        },
        version = 'v2.*',
        config = function()
            local luasnip = require 'luasnip'
            local types = require 'luasnip.util.types'
            luasnip.config.setup {
                history = true,
                keep_roots = true,
                link_roots = true,
                link_children = true,
                update_events = 'TextChanged,TextChangedI',
                delete_check_events = 'TextChanged',
                ext_opts = {
                    [types.choiceNode] = {
                        active = {
                            virt_text = { { '●', 'Comment' } },
                        },
                    },
                },
                -- treesitter-hl has 100, use something higher (default is 200).
                ext_base_prio = 300,
                -- minimal increase in priority.
                ext_prio_increase = 1,
                enable_autosnippets = false,
            }
            require('cmp_luasnip_choice').setup {
                auto_open = true,
            }

            vim.keymap.set({ 'i', 's' }, '<C-L>', function()
                if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
            end, {
                desc = 'Expand or jump forward in lua-snippet',
                silent = true,
            })

            vim.keymap.set({ 'i', 's' }, '<C-J>', function()
                if luasnip.jumpable(1) then luasnip.jump(1) end
            end, { desc = 'Jump backward in lua-snippet', silent = true })

            vim.keymap.set({ 'i', 's' }, '<C-K>', function()
                if luasnip.jumpable(-1) then luasnip.jump(-1) end
            end, { desc = 'Jump backward in lua-snippet', silent = true })

            vim.keymap.set({ 'i', 's' }, '<C-E>', function()
                if luasnip.choice_active() then luasnip.change_choice(1) end
            end, {
                desc = 'Switch between choices in lua-snippet',
                silent = true,
            })
            require('cmp_luasnip_choice').setup {
                auto_open = true,
            }

            require('luasnip.loaders.from_lua').load() -- load from ~/.config/nvim/luasnippets
        end,
    },
    {
        'hrsh7th/nvim-cmp',
        event = { 'InsertEnter', 'CmdlineEnter' },
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
        },
        config = function()
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'

            -- Smart fallback logic for Wiki completions (Experimental -> Pro)
            local ok_xp, exp_wiki = pcall(require, 'xperiments.wiki_completions')
            local ok_pro, pro_wiki = pcall(require, 'util.wiki_completions')

            if ok_xp and exp_wiki then cmp.register_source('wiki_exp', exp_wiki.new()) end

            if ok_pro and pro_wiki then cmp.register_source('wiki', pro_wiki.new()) end

            cmp.setup {
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-u>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-y>'] = cmp.mapping.confirm { select = true },
                    ['<CR>'] = function(fallback)
                        if cmp.visible() then
                            cmp.confirm { select = true }
                            require('libraries._cmp').toggle_autocomplete()
                        else
                            fallback()
                        end
                    end,
                },

                sources = cmp.config.sources({
                    { name = 'luasnip_choice' },
                    { name = 'luasnip' },
                    { name = 'nvim_lsp' },
                    { name = 'otter' },
                    { name = 'wiki_exp', priority = 100 }, -- Uses experimental if it exists
                    { name = 'wiki', priority = 100 }, -- Uses stable if experimental fails
                    { name = 'path' },
                }, {
                    { name = 'buffer' },
                }),
            }
        end,
    },
}
