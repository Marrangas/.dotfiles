-- Fast leader
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- the most repeated, with one less keypress
-- who knows if I will still be doing it
vim.keymap.set('n', '<leader>w', ':w')

--[[ :help ALT (I always forget)
M-…>           alt-key or meta-key             *META* *ALT* *<M-*
<A-…>           same as <M-…>                   *<A-*
<T-…>           meta-key when it's not alt      *<T-*
<D-…>           command-key or "super" key      *<D-*
]]

-- paste without loosing clipboard
vim.keymap.set('x', '<leader>p', [["_dP]])

-- copy to clypboard: asbjornHaland
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set('n', '<leader>Y', [["+Y]])
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["+d]])

-- Control C as Esc for all
vim.keymap.set('i', '<C-c>', '<Esc>')

-- Searching keymaps
vim.keymap.set('n', '<leader>S', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set('v', '<leader>/', [[<Esc>/\%V]])

-- Rename keymaps
vim.keymap.set({ 'n', 'v' }, '<leader>rl', [[:s/\(^\s*\)\(.*\S\)\s*/\1\2<Left><Left>]])

-- Visualization
vim.keymap.set({ 'n', 'v' }, '<Space>w', ':set nowrap<CR>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>n', ':NoNeckPain<CR>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>zi', ':set foldmethod=indent<CR>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>zc', ':set foldmethod=manual<CR>', { silent = true })

-- Line move
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Page navegation
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-f>', '<C-f>zz')
vim.keymap.set('n', '<C-b>', '<C-b>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

vim.keymap.set('n', '<leader>.', function()
  local path = vim.fn.expand '%:p'
  vim.cmd('cd ' .. vim.fs.dirname(path))
end, { desc = 'cwd [.]' })

-- File navegation Keymaps
-- vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = 'enter netrw' })
vim.keymap.set('n', '<C-j>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-k>', '<cmd>cprev<CR>zz')

-- [[ harpoon config ]]
vim.keymap.set('n', '<leader>a', function()
  require('harpoon.mark').add_file()
end)
vim.keymap.set('n', '<C-e>', function()
  require('harpoon.ui').toggle_quick_menu()
end)
vim.keymap.set('n', '<leader>h', function()
  require('harpoon.ui').nav_file(1)
end)
vim.keymap.set('n', '<leader>j', function()
  require('harpoon.ui').nav_file(2)
end)
vim.keymap.set('n', '<leader>k', function()
  require('harpoon.ui').nav_file(3)
end)
vim.keymap.set('n', '<leader>l', function()
  require('harpoon.ui').nav_file(4)
end)

-- File Actions
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = '[F]ormat file' })
vim.keymap.set('n', '<leader>X', '<cmd>!chmod +x %<CR>', { silent = true, desc = 'file e[X]ecutable' })
vim.keymap.set('n', '<leader>%', function()
  vim.cmd 'so'
end, { desc = 'source [%]' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- help cmdline-editing
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<M-b>', '<S-Left>')
vim.keymap.set('c', '<M-f>', '<S-Right>')
vim.keymap.set('c', '<C-U>', '<C-E><C-U>')

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Telescope others
vim.keymap.set('n', '<leader>st', ':TodoTelescope<CR>', { desc = '[S]earch [T]odo' })

-- Quickfix jumps
vim.keymap.set('n', '<C-j>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-k>', '<cmd>cprev<CR>zz')

-- Location list jumps
-- vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz')
-- vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

-- Undotree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

--Terraform
vim.keymap.set('n', '<leader>ti', ':!terraform init -no-color<CR>')
vim.keymap.set('n', '<leader>tv', ':!terraform validate -no-color<CR>')
vim.keymap.set('n', '<leader>tp', ':!terraform plan -lock=false -no-color<CR>')
vim.keymap.set('n', '<leader>ta', ':!terraform apply -no-color<CR>')
vim.keymap.set('n', '<leader>tqp', ':!terraform plan -lock=false -no-color -refresh=false<CR>')
vim.keymap.set('n', '<leader>tqa', ':!terraform apply -no-color -auto-approve -refresh=false<CR>')

-- Obsidian Xanadu
vim.keymap.set('n', '<leader>sx', function()
  require('telescope.builtin').find_files { cwd = '~/Documents/wiki/' }
end, { desc = '[S]earch [X]anadu' })

vim.keymap.set('n', '<leader>xg', ':ObsidianSearch', { desc = '[X]anadu [G]rep' })
vim.keymap.set('n', '<leader>x.', ':ObsidianOpen<CR>', { desc = '[X]anadu Open [.]' })
vim.keymap.set('n', '<leader>x<', ':ObsidianBacklink<CR>', { desc = '[X]anadu [<]' })
vim.keymap.set('n', '<leader>x>', ':ObsidianLinks<CR>', { desc = '[X]anadu [>]' })
vim.keymap.set('n', '<leader>xt', ':ObsidianTOC<CR>', { desc = '[X]anadu [T]OC' })
vim.keymap.set('n', '<leader>x#', ':ObsidianTag', { desc = '[X]anadu [#]tag' })
vim.keymap.set('n', '<leader>xs', ':ObsidianQuickSwitch<CR>', { desc = '[X]anadu [S]earch' })
vim.keymap.set('n', '<leader>xd', ':ObsidianToday<CR>', { desc = '[X]anadu [D]aily' })

-- tmux config
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux neww tmux-sessionizer -w one<CR>")
-- vim.keymap.set("n", "<M-t>", "<cmd>silent !tmux neww tmux-sessionizer -w two<CR>")
-- vim.keymap.set("n", "<M-n>", "<cmd>silent !tmux neww tmux-sessionizer -w three<CR>")
-- vim.keymap.set("n", "<M-s>", "<cmd>silent !tmux neww tmux-sessionizer -w four<CR>")
--
