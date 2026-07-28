-- stylua: ignore start
-- [[ Essential ]]
-- : <leader> Must happen before plugins are loaded
-- (otherwise wrong leader will be used)intintintintinitinit
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set('n', '<C-_>', ':Explore<CR>')

vim.keymap.set('i', '<M-e>', '<C-k>\'', { noremap = true, desc = 'digraphs remap (conflicts with blink)' })
vim.keymap.set('i', '<M-n>', '<C-k>~', { noremap = true, desc = 'digraphs remap (conflicts with blink)' })
vim.keymap.set('i', '<M-u>', '<C-k>Z', { noremap = true, desc = 'digraphs remap (conflicts with blink)' })
-- Clear highlights
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear selection' })
vim.keymap.set('n', '<leader>/', '<Esc>/\\%V', { desc = 'Search previous selection' })
vim.keymap.set('v', '<leader>ra', [[:<C-u>lua WrapLines()<CR>]], { silent = true })
function WrapLines()
    local char = vim.fn.input("wrapper string: ")
    if char == "" then return end
    vim.cmd(string.format([['<,'>s/^\(\s*\)\(.*\)/\1%s\2%s/]], char, char))
    vim.cmd('noh')
end

vim.keymap.set('n', '<C-z>', '<Nop>', { desc = 'Disable suspend' })

-- the most repeated, with one less keypress
-- who knows if I will still be doing it
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Classic :w improved' })

-- write/save when the buffer has been modified.
vim.keymap.set({ 'i', 'n' }, '<C-s>', '<ESC>ma<ESC>:update <CR>`a', { noremap = true, silent = true })

-- Terminal remaps
-- This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<c-\\><c-n>', { noremap = true, silent = true, desc = 'Exit terminal mode' })

-- delete a word backward in insert mode with Ctrl+Backspace
vim.keymap.set({ 'c', 'i' }, '<C-H>', '<C-w>', { desc = 'Delete word backwards in command mode' })

-- help cmdline-editing
vim.keymap.set('c', '<C-a>', '<Home>', { desc = 'Emacs first column' })
vim.keymap.set('c', '<C-e>', '<End>', { desc = 'Emacs first last column' })
vim.keymap.set('c', '<C-b>', '<Left>', { desc = 'Emacs backward one char' })
vim.keymap.set('c', '<C-f>', '<Right>', { desc = 'Emacs forward one char' })
vim.keymap.set('c', '<M-b>', '<S-Left>', { desc = 'Emacs backward one word' })
vim.keymap.set('c', '<M-f>', '<S-Right>', { desc = 'Emacs forward onw word' })
vim.keymap.set('c', '<C-U>', '<C-E><C-U>', { desc = 'Emacs clean line' })

-- search within visual selection
vim.keymap.set('x', '/', '<Esc>/\\%V', { noremap = true })

-- Page navegation
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Classic [J]oin improved' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Classeic Ctr-d improved' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Classic Ctr-u improved' })
vim.keymap.set('n', '<C-f>', '<C-f>zz', { desc = 'Classic Ctr-f improved' })
vim.keymap.set('n', '<C-b>', '<C-b>zz', { desc = 'Classic Ctr-b improved' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Classic [n]ext find improved' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Classic previouse find improved' })

-- smart deletion, dd
-- It solves the issue, where you want to delete empty line, but dd will override your last yank.
-- Code below will check if u are deleting empty line, if so - use black hole register.
-- [src: https://www.reddit.com/r/neovim/comments/w0jzzv/comment/igfjx5y/?utm_source=share&utm_medium=web2x&context=3]
vim.keymap.set('n', 'dd', function()
    if vim.api.nvim_get_current_line():match '^%s*$' then
        return '"_dd'
    else
        return 'dd'
    end
end, { expr = true, desc = 'Smart dd (ignore empty lines in register)' })

-- paste without loosing clipboard
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = '[p]aste without replacing register' })

-- copy to clypboard: asbjornHaland
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = '[y]ank to clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = '[Y]ank line to clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["+d]], { desc = '[d]elete to clipboard' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", {
    expr = true,
    silent = true,
    desc = 'Classic k improved for word wrap',
})

vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", {
    silent = true,
    expr = true,
    desc = 'Classic j improved for word wrap',
})

-- easier moving of code blocks
-- Try to go into visual mode (v), thenselect several lines of code
-- here and then press ``>`` several times.
vim.keymap.set('v', '<', '<gv', { noremap = true, silent = true })
vim.keymap.set('v', '>', '>gv', { noremap = true, silent = true })

-- Line move
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'pattertn j [move line down]' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'pattertn k [move line up]' })

-- Quickfix
vim.keymap.set('n', '<C-j>', '<cmd>cnext<CR>zz', { desc = 'pattern j (down) quickfix' })
vim.keymap.set('n', '<C-k>', '<cmd>cprev<CR>zz', { desc = 'pattern k (up) quickfix' })
vim.keymap.set('n', '<C-h>', '<cmd>colder<CR>', { desc = 'pattern h (down) quickfix' })
vim.keymap.set('n', '<C-l>', '<cmd>cnewer<CR>', { desc = 'pattern l (up) quickfix' })
vim.keymap.set('n', '<C-n>', '<cmd>lnext<CR>zz', { desc = 'pattern n (down) location-list' })
vim.keymap.set('n', '<C-p>', '<cmd>lprev<CR>zz', { desc = 'pattern p (down) location-list' })
vim.keymap.set('n', '<C-m>', function()
  local qf_item = {
    bufnr = vim.api.nvim_get_current_buf(),
    lnum = vim.fn.line('.'),
    col = vim.fn.col('.'),
    text = vim.api.nvim_get_current_line(),
  }

  -- 'a' appends to the quickfix list without wiping existing items
  vim.fn.setqflist({ qf_item }, 'a')
  vim.notify("Line added to quickfix list", vim.log.levels.INFO)
end, { desc = "Add current line to quickfix list" })

-- Location list jumps
-- vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz')
-- vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

-- File commands
vim.keymap.set('n', '<leader>.f', vim.lsp.buf.format, { desc = '[.]file [F]ormat ' })
vim.keymap.set('n', '<leader>.x', ':!chmod +x %', { desc = '[.]file e[x]ecute' })
vim.keymap.set('n', '<leader>.s', ':source %<CR>', { desc = '[.]file [s]ource' })

vim.keymap.set('n', '<leader>..', function()
    local path = vim.fn.expand '%:p'
    vim.cmd('cd ' .. vim.fs.dirname(path))
end, { desc = '[.] file as cwd' })

vim.keymap.set('n', '<leader>.d', function()
    vim.cmd('cd ' .. vim.fs.dirname('/Users/altostratus/Documents/dgrp/'))
end, { desc = '[.] file as cwd' })

-- -- Diagnostic keymaps (use an alternative quickfix?)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Diagnostic keymaps (use an alternative quickfix?)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
