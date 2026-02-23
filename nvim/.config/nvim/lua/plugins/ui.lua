return {
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        priority = 1000,
        config = function()
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
            vim.keymap.set('n', '<leader>st', ':TodoTelescope<CR>', { desc = '[S]earch [T]odo' }),
            keywords = {
                TASK = {
                    icon = '❑ ',
                    color = 'info',
                    alt = { '[- [ ]' },
                },
                PENDING = {
                    icon = ' ', -- A clock icon
                    color = 'warning',
                    alt = { '[- [~]' }, -- Matches the pending task syntax
                },
                DONE = {
                    icon = '✔ ',
                    color = 'hint',
                    alt = { '[- [x]' },
                },
            },
        },
    },
}
