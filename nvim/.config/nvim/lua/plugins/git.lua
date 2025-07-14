return {
  'lewis6991/gitsigns.nvim',
  -- make git work also with telescope for better navegation
  opts = {
    vim.keymap.set('n', 'gd', ':Gitsigns preview_hunk<CR>', { desc = '[H]story (GIT) [D]iff hunk' }),
    vim.keymap.set('n', 'gB', ':Gitsigns toggle_current_line_blame<CR>', { desc = '[G]it toggle current line [B]blame ' }),
    vim.keymap.set('n', '[g', ':Gitsigns prev_hunk<CR>', { desc = 'Go to previous [G]it change' }),
    vim.keymap.set('n', ']g', ':Gitsigns next_hunk<CR>', { desc = 'Go to next [G]it change' }),
    vim.keymap.set('n', 'gh', '<cmd>diffget //2<CR>', { desc = '[G]it left leter' }),
    vim.keymap.set('n', 'gl', '<cmd>diffget //3<CR>', { desc = '[G]it right leter' }),
  },
}
