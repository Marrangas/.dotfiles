
return {
    -- { '', },
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
        config = function() require('harpoon'):setup {} end,
    },
}
