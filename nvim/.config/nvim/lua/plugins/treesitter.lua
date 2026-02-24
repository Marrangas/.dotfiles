return {
    'nvim-treesitter/nvim-treesitter',
    config = function()
        local filetypes = {
            'http',
            'bash',
            'make',
            'c',
            'go',
            'python',
            'lua',
            'luadoc',
            'kconfig',
            'helm',
            'nix',
            'regex',
            'jinja',
            'hcl',
            'sql',
            'html',
            'json',
            'yaml',
            'toml',
            'markdown',
            'markdown_inline',
            'diff',
            'vim',
            'vimdoc',
        }
        require('nvim-treesitter').install(filetypes)
        require('nvim-treesitter.config').setup({
            ensure_installed = filetypes,
            highlight = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<Enter>",
                    node_incremental = "<Enter>",
                    scope_incremental = "<Tab>",
                    node_decremental = "<BS>",
                },
            },
        })
    end,
}
