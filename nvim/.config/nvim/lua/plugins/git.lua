return {
    -- learn and practice
    -- branch strategy, atomic commits
    -- merging hunking and compating

    -- {'neogitorg/neogit'}, + diffview.nvim
    --[[ git related ]]
    { 'tpope/vim-fugitive' },
    {
        'lewis6991/gitsigns.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
        },
        keys = {
            -- The proper lazy.nvim way to define keys:
            { '<leader>gh', '<cmd>diffget //2<CR>',                            desc = '[G]it [H]ead (Left)' },
            { '<leader>gl', '<cmd>diffget //3<CR>',                            desc = '[G]it [L]ink (Right)' },
            { '<leader>gp', function() require('gitsigns').preview_hunk() end, desc = '[G]it [P]review Hunk' },
            { ']g',         function() require('gitsigns').next_hunk() end,    desc = '] [G]it next Hunk' },
            { '[g',         function() require('gitsigns').prev_hunk() end,    desc = '[ [G]it prev Hunk' },
        },
    },
}
