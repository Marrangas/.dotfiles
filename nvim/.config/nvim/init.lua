-- Environment variables (such as DOTFILE_LSP_SERVERS) are loaded directly from the shell (sourced in zshrc).

-- [[ Diagnostic Config & Keymaps ]] :help vim.diagnostic.Opts
-- vim.lsp.set_log_level("debug")
vim.o.background = 'dark'
vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    virtual_text = true,
    virtual_lines = false,
    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = { on_jump = { float = true } },
}
vim.keymap.set(
    'n',
    '<leader>q',
    vim.diagnostic.setloclist,
    { desc = 'Open diagnostic [Q]uickfix list' }
)

-- [[ Install `lazy.nvim` plugin manager ]] `:help lazy.nvim.txt`
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        '--branch=stable',
        lazyrepo,
        lazypath,
    }
    if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require 'config.autocmd'
require 'config.options'
require 'config.keymaps'

-- Thanks to Pavol Z. Kutaj
package.loaded['obsidian.lsp'] = nil
package.preload['obsidian.lsp'] = function()
    return {
        start = function() return nil end,
    }
end

require('lazy').setup {
    -- { import = 'xperiments' },
    { import = 'plugins' },
}

require 'util'
