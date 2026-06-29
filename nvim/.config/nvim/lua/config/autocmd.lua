-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

vim.cmd([[
  iabbrev lenght length
]])

-- open help in vertical split and set width
vim.api.nvim_create_autocmd("FileType", {
    pattern = "help",
    callback = function()
        vim.cmd("wincmd L")
        vim.api.nvim_win_set_width(0, 85)
    end,
})

-- Highlight when yanking (copying) text
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
})

-- show cursorline and cursorcolumn only in active window enable
-- Sam Natale
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("active_cursorline", { clear = true }),
    callback = function()
        vim.opt_local.cursorline = true
        vim.opt_local.cursorcolumn = true
    end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = "active_cursorline",
    callback = function()
        vim.opt_local.cursorline = false
        vim.opt_local.cursorcolumn = false
    end,
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

local function netrw_dir_jump(backwards)
    local flags = backwards and "bW" or "W"
    vim.fn.search([[\/ \?$]], flags)
end

local netrw = vim.api.nvim_create_augroup('netrw', { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = netrw,
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "]]", function() netrw_dir_jump(false) end, { remap = false, buffer = true })
        vim.keymap.set("n", "[[", function() netrw_dir_jump(true) end, { remap = false, buffer = true })
    end
})

-- Automatically format JSON files or JSON piped via stdin
local json_format_group = vim.api.nvim_create_augroup("JSONFormatOnOpen", { clear = true })

-- Format on opening JSON files
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = json_format_group,
    pattern = "*.json",
    callback = function()
        if vim.fn.executable("jq") == 1 then
            vim.cmd("silent! %!jq .")
        elseif vim.fn.executable("python3") == 1 then
            vim.cmd("silent! %!python3 -m json.tool")
        end
        vim.bo.modified = false
    end,
})

-- Format JSON piped from stdin (when nvim is used as a pager, e.g. cat data.json | nvim -)
vim.api.nvim_create_autocmd({ "StdinReadPost" }, {
    group = json_format_group,
    callback = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local content = table.concat(lines, "\n")
        -- Simple check to see if content is JSON
        local trimmed = content:gsub("^%s*", "")
        if trimmed:sub(1, 1) == "{" or trimmed:sub(1, 1) == "[" then
            if vim.fn.executable("jq") == 1 then
                vim.cmd("silent! %!jq .")
                vim.bo.filetype = "json"
            elseif vim.fn.executable("python3") == 1 then
                vim.cmd("silent! %!python3 -m json.tool")
                vim.bo.filetype = "json"
            end
            vim.bo.modified = false
        end
    end,
})

return {}
