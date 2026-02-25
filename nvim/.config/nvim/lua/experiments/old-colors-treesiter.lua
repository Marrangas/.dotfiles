
return {
    {
        'folke/tokyonight.nvim',
        lazy = true,
    },
    {
        'NvChad/nvim-colorizer.lua',
        event = 'BufReadPre',
        config = function()
            require('colorizer').setup {
                user_default_options = {
                    names = true,
                },
                names_custom = function()
                    return require('tokyonight.colors').setup()
                end,
                filetypes = {
                    '*',
                    markdown = {
                        names_custom = function()
                            return require('tokyonight.colors').setup()
                        end,
                    },
                },
            }
        end,
    },
}