return {
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        lazy = false,
        -- Do not use pcall here in the table keys; it executes immediately!
        keys = {
            {
                '<leader>a',
                function() require('harpoon'):list():add() end,
                desc = 'Harpoon [A]dd file',
            },
            {
                '<leader>-',
                function()
                    local harpoon = require 'harpoon'
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end,
                desc = 'Harpoon [E]xplore',
            },
            -- stylua: ignore start
            { '<leader>j', function() pcall(function() require('harpoon'):list():select(1) end) end, desc = 'Harpoon finger 1', },
            { '<leader>k', function() pcall(function() require('harpoon'):list():select(2) end) end, desc = 'Harpoon finger 2', },
            { '<leader>l', function() pcall(function() require('harpoon'):list():select(3) end) end, desc = 'Harpoon finger 3', },
            { '<leader>;', function() pcall(function() require('harpoon'):list():select(4) end) end, desc = 'Harpoon finger 4', },
            -- stylua: ignore end
        },
        config = function()
            local initial_cwd = vim.fn.getcwd()
            require('harpoon'):setup {
                settings = {
                    key = function() return initial_cwd end,
                },
            }
        end,
    },
    {
        'stevearc/quicker.nvim',
        lazy = false,
        config = function(_, opts)
            vim.cmd 'packadd cfilter'
            require('quicker').setup(opts)
        end,
        ft = 'qf',
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {
            use_default_opts = true,
        },
        keys = {
            {
                '>',
                function()
                    require('quicker').expand { before = 2, after = 2, add_to_existing = true }
                end,
                desc = 'Expand quickfix context',
                ft = 'qf',
            },
            {
                '<',
                function() require('quicker').collapse() end,
                desc = 'Collapse quickfix context',
                ft = 'qf',
            },
        },
    },
    {
        'S1M0N38/ctx.nvim',
        version = '*',
        opts = {},
        keys = {
            -- Add visual selection to Quickfix List
            {
                '<C-q>',
                function()
                    local item = require('ctx.items').selection()
                    require('ctx.utils').highlight(item)
                    vim.fn.setqflist({ item }, 'a')
                end,
                desc = 'Add to Quickfix List',
                mode = { 'v' },
            },
            -- Add visual selection to Location List
            {
                '<leader>l',
                function()
                    local win = vim.api.nvim_get_current_win()
                    local item = require('ctx.items').selection()
                    require('ctx.utils').highlight(item)
                    vim.fn.setloclist(win, { item }, 'a')
                end,
                desc = 'Add to Location List',
                mode = { 'v' },
            },
            -- There are other ways to send items to Quickfix / Location list.
            -- For example, many pickers (telescope, fzf-lua, snacks.picker) can
            -- send items to Quickfix / Location list.
            {
                'yq',
                function()
                    local md = require('ctx').qflist_to_md()
                    vim.fn.setreg('+', md)
                    vim.notify 'Yanked qflist'
                end,
                desc = 'Yank Quickfix List',
            },
            {
                'yl',
                function()
                    local nr = vim.api.nvim_get_current_win()
                    local md = require('ctx').loclist_to_md(nr)
                    vim.fn.setreg('+', md)
                    vim.notify 'Yanked loclist'
                end,
                desc = 'Yank Quickfix List',
            },
        },
    },
}
