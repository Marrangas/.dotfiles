return {
  -- learn and practice
  -- branch strategy, atomic commits
  -- merging hunking and compating

  -- {'neogitorg/neogit'}, + diffview.nvim
  -- {'tpope/vim-fugitive'},
  --[[ git related ]]
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
      { '<leader>gh', '<cmd>diffget //2<CR>', desc = '[G]it [H]ead (Left)' },
      { '<leader>gl', '<cmd>diffget //3<CR>', desc = '[G]it [L]ink (Right)' },
      { '<leader>gp', function() require('gitsigns').preview_hunk() end, desc = '[G]it [P]review Hunk' },
    },
  },
}
