-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

local bufcheck = vim.api.nvim_create_augroup('bufcheck', { clear = true })

vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Start terminal in insert mode',
  group = bufcheck,
  pattern = '*',
  callback = function()
    vim.cmd 'startinsert'
    vim.opt_local.winfixheight = true
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'start git commit in insert mode',
  group = bufcheck,
  pattern = { 'gitcommit', 'gitrebase' },
  callback = function()
    vim.cmd 'startinsert'
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  end,
})

local fn = vim.fn
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'open file in the same line as previous edit',
  group = bufcheck,
  pattern = '*',
  callback = function()
    local last_pos = fn.line '\'"'
    if last_pos > 0 and last_pos <= fn.line '$' then
      if vim.bo.filetype ~= 'commit' then
        vim.cmd 'normal! g`"'
        vim.cmd 'silent! foldopen'
      end
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
  desc = 'Disable automatic commenting on new lines',
  pattern = '*',
  callback = function()
    -- Remove 'c' (auto-wrap comments),
    -- 'r' (insert comment after <Enter>),
    -- and 'o' (insert comment after 'o' or 'O')
    vim.opt_local.formatoptions:remove { 'o', 'O' }
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Treesitter folding for json and yaml',
  pattern = { 'json', 'yaml' },
  callback = function()
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

    -- Optional: Start with everything unfolded for a better experience
    vim.opt_local.foldlevel = 99
  end,
})

return {}
