return {
    'mbbill/undotree',
    config = function()
        local target_path = vim.fn.expand '~/.cache/undodir'

        if vim.fn.has 'persistent_undo' == 1 then
            if vim.fn.isdirectory(target_path) == 0 then
                vim.fn.mkdir(target_path, 'p', 448) -- 0700 in decimal
            end
            vim.opt.undodir = target_path
            vim.opt.undofile = true
        end
        vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
    end,
}
