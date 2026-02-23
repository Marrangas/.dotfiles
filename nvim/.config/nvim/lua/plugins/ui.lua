return {
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        priority = 1000,
        config = function()
            require('catppuccin').setup {
                flavour = 'mocha',
                integrations = {
                    treesitter = true,
                    native_lsp = {
                        enabled = true,
                        semantic_tokens = true, -- Crucial for markdown-oxide colors
                        underlines = {
                            errors = { 'undercurl' },
                            hints = { 'undercurl' },
                            warnings = { 'undercurl' },
                            information = { 'undercurl' },
                        },
                    },
                },
                custom_highlights = function(colors)
                    return {
                        -- Headers (covered both for Treesitter and Classic)
                        ['@markup.heading.1'] = { fg = colors.red, style = { 'bold' } },
                        ['@markup.heading.2'] = { fg = colors.peach, style = { 'bold' } },
                        ['@markup.heading.3'] = { fg = colors.yellow, style = { 'bold' } },
                        ['@markup.heading.4'] = { fg = colors.green, style = { 'bold' } },
                        ['@markup.heading.5'] = { fg = colors.sapphire, style = { 'bold' } },
                        ['@markup.heading.6'] = { fg = colors.mauve, style = { 'bold' } },
                        markdownH1 = { fg = colors.red, style = { 'bold' } },
                        markdownH2 = { fg = colors.peach, style = { 'bold' } },

                        -- Bold / Italic
                        ['@markup.strong'] = { fg = colors.maroon, style = { 'bold' } },
                        ['@markup.italic'] = { fg = colors.teal, style = { 'italic' } },
                        ['@markup.strikethrough'] = { fg = colors.overlay2, style = { 'strikethrough' } },

                        -- Tables
                        ['@markup.table'] = { fg = colors.text },
                        ['@markup.table.header'] = { fg = colors.blue, style = { 'bold' } },
                        ['@markup.table.separator'] = { fg = colors.lavender },
                        ['@markup.table.delimiter'] = { fg = colors.lavender },

                        -- Code & Inline
                        ['@markup.raw'] = { fg = colors.peach },
                        ['@markup.raw.markdown_inline'] = { fg = colors.peach },
                        ['@markup.raw.block'] = { fg = colors.subtext0 },

                        -- Tags (via LSP semantic tokens)
                        ['@lsp.type.tag'] = { fg = colors.pink, style = { 'bold' } },
                        ['@lsp.type.header'] = { fg = colors.red, style = { 'bold' } },
                        ['@label.markdown'] = { fg = colors.pink, style = { 'bold' } },

                        -- Links
                        ['@markup.link.label'] = { fg = colors.sky, style = { 'bold' } },
                        ['@markup.link.url'] = { fg = colors.sapphire, style = { 'italic' } },
                        ['@markup.list'] = { fg = colors.red },
                    }
                end,
            }


            vim.cmd.colorscheme 'catppuccin-mocha'
            vim.cmd.hi 'Comment gui=none'

            -- Force Markdown Bright Colors (Override everything)
            local cp = require('catppuccin.palettes').get_palette 'mocha'
            local hls = {
                ['@markup.heading.1'] = { fg = cp.red, bold = true },
                ['@markup.heading.2'] = { fg = cp.peach, bold = true },
                ['@markup.heading.3'] = { fg = cp.yellow, bold = true },
                ['@markup.heading.4'] = { fg = cp.green, bold = true },
                ['@markup.heading.5'] = { fg = cp.sapphire, bold = true },
                ['@markup.heading.6'] = { fg = cp.mauve, bold = true },
                ['@markup.strong'] = { fg = cp.maroon, bold = true },
                ['@markup.italic'] = { fg = cp.teal, italic = true },
                ['@markup.link.label'] = { fg = cp.sky, bold = true },
                ['@markup.link.url'] = { fg = cp.sapphire },
                ['@markup.list'] = { fg = cp.red },
                ['@markup.table.header'] = { fg = cp.blue, bold = true },
                ['@markup.table.delimiter'] = { fg = cp.lavender },
                ['@lsp.type.tag'] = { fg = cp.pink, bold = true },
                ['@lsp.type.header'] = { fg = cp.red, bold = true },
                ['@label.markdown'] = { fg = cp.pink, bold = true },
                -- Fallbacks for standard groups
                ['markdownH1'] = { fg = cp.red, bold = true },
                ['markdownH2'] = { fg = cp.peach, bold = true },
                ['markdownH3'] = { fg = cp.yellow, bold = true },
            }
            for group, opts in pairs(hls) do
                vim.api.nvim_set_hl(0, group, opts)
            end
        end,
    },


    {
        'nvim-lualine/lualine.nvim',
        opts = {
            globalstatus = true,
            sections = {
                lualine_c = { { 'filename', path = 4 } },
                lualine_x = { 'lsp_status', 'filetype', 'filesize' },
            },
        },
    },
    {
        'folke/todo-comments.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        keys = {
            { '<leader>st', function() Snacks.picker.todo_comments() end, desc = 'Todo' },
        },
        opts = {
            keywords = {
                TASK = {
                    icon = '❑ ',
                    color = 'info',
                    alt = { '[- [ ]' },
                },
                PENDING = {
                    icon = ' ', -- A clock icon
                    color = 'warning',
                    alt = { '[- [~]' }, -- Matches the pending task syntax
                },
                DONE = {
                    icon = '✔ ',
                    color = 'hint',
                    alt = { '[- [x]' },
                },
            },
        },
    },
}
