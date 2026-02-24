-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
})

local autoInsert = vim.api.nvim_create_augroup('autoInsert', { clear = true })

vim.api.nvim_create_autocmd('TermOpen', {
    desc = 'Start terminal in insert mode',
    group = autoInsert,
    pattern = '*',
    callback = function()
        vim.cmd 'startinsert'
        vim.opt_local.winfixheight = true
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    desc = 'start git commit in insert mode',
    group = autoInsert,
    pattern = { 'gitcommit', 'gitrebase' },
    callback = function()
        vim.cmd 'startinsert'
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    desc = 'open file in the same line as previous edit',
    group = autoInsert,
    pattern = '*',
    callback = function()
        local last_pos = vim.fn.line '\'"'
        if last_pos > 0 and last_pos <= vim.fn.line '$' then
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

-- [[ Folding ]]
local fold = vim.api.nvim_create_augroup('fold', { clear = true })

vim.api.nvim_create_autocmd('BufReadPre', {
    desc = 'Set foldmethod to indent before reading buffer',
    group = fold,
    pattern = '*',
    callback = function()
        -- Use Treesitter folding if available, otherwise indent
        local has_ts = pcall(vim.treesitter.get_parser)
        if has_ts then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        else
            vim.wo.foldmethod = 'indent'
        end
        vim.wo.foldlevel = 99
    end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
    desc = 'Freeze foldmethod to manual if it was indent',
    group = fold,
    pattern = '*',
    callback = function()
        if vim.wo.foldmethod == 'indent' or vim.wo.foldmethod == 'expr' then
            vim.wo.foldmethod = 'manual'
            vim.wo.foldlevel = 99
        end
    end,
})

-- Detect initial folds after LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
    group = fold,
    callback = function(event)
        -- Use Treesitter folding if available, otherwise indent
        local has_ts = pcall(vim.treesitter.get_parser, event.buf)
        if has_ts then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        else
            vim.wo.foldmethod = 'indent'
        end
        -- Force recalculation immediately
        vim.cmd.normal { 'zx', bang = true }
        -- Freeze to manual so we can use zf/zd etc.
        vim.wo.foldmethod = 'manual'
        vim.wo.foldlevel = 99
    end,
})

return {}
