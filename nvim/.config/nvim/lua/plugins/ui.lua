return {
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        priority = 1000,
        config = function()
            require('catppuccin').setup {
                flavour = 'mocha',
                integrations = {
                    treesitter = true,
                    markdown = true,
                    native_lsp = {
                        enabled = true,
                        semantic_tokens = true,
                    },
                    obsidian = true,
                },
            }

            vim.cmd.colorscheme 'catppuccin-mocha'
            vim.cmd.hi 'Comment gui=none'
        end,
    },
    {
        'nvim-lualine/lualine.nvim',
        opts = {
            globalstatus = true,
            sections = {
                lualine_c = { { 'filename', path = 4 } },
                lualine_x = { 'lsp_status', 'filetype', 'filesize' },
            },
        },
    },
    {
        'folke/todo-comments.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            keywords = {
                TASK = { icon = '󰄱 ', color = 'info', alt = { '[- [ ]' }, },
                PENDING = { icon = ' ', color = 'warning', alt = { '[- [~]' } },
                DONE = { icon = '✔ ', color = 'hint', alt = { '[- [x]' } },
            },
        },
    },
    -- {
    --     'MeanderingProgrammer/render-markdown.nvim',
    --     dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    --     -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    --     -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    --     ---@module 'render-markdown'
    --     ---@type render.md.UserConfig
    --     opts = {
    --         bullet = { enabled = false },
    --         yaml = {
    --             enabled = true,
    --             render_modes = true,
    --         },
    --     },
    -- },
}
