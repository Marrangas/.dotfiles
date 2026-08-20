local active_theme = vim.env.DOTFILE_THEME
if not active_theme or active_theme == '' then
    vim.api.nvim_err_writeln "Error: 'DOTFILE_THEME' environment variable is not defined or is empty!"
    active_theme = 'tokyonight-moon'
end

local theme_plugin

if active_theme:match '^catppuccin' then
    theme_plugin = {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        priority = 1000,
        config = function()
            local flavour = active_theme:match 'catppuccin%-(%w+)' or 'mocha'
            require('catppuccin').setup {
                flavour = flavour,
                integrations = {
                    treesitter = true,
                    markdown = true,
                    native_lsp = {
                        enabled = true,
                        semantic_tokens = true,
                    },
                    obsidian = true,
                },
                custom_highlights = function(cp)
                    return {
                        -- Headers: Comprehensive hijacking of Syntax, Treesitter, and LSP
                        markdownH1 = { fg = cp.blue, style = { 'bold' } },
                        markdownH2 = { fg = cp.peach, style = { 'bold' } },
                        markdownH3 = { fg = cp.green, style = { 'bold' } },
                        markdownH4 = { fg = cp.sapphire, style = { 'bold' } },
                        markdownH5 = { fg = cp.lavender, style = { 'bold' } },
                        markdownH6 = { fg = cp.mauve, style = { 'bold' } },

                        -- Link Treesitter captures to these groups
                        ['@markup.heading.1.markdown'] = { link = 'markdownH1' },
                        ['@markup.heading.2.markdown'] = { link = 'markdownH2' },
                        ['@markup.heading.3.markdown'] = { link = 'markdownH3' },
                        ['@markup.heading.4.markdown'] = { link = 'markdownH4' },
                        ['@markup.heading.5.markdown'] = { link = 'markdownH5' },
                        ['@markup.heading.6.markdown'] = { link = 'markdownH6' },

                        -- Link LSP Semantic Tokens (markdown-oxide)
                        ['@lsp.type.heading.markdown'] = { link = 'markdownH1' },
                        ['@lsp.type.section.markdown'] = { link = 'markdownH1' },

                        -- Frontmatter (YAML Metadata) - Separación Robusta
                        ['@markup.metadata.markdown'] = { fg = cp.overlay1 },
                        ['@punctuation.delimiter.markdown'] = { fg = cp.overlay1 },
                        ['@property.yaml'] = { fg = cp.blue, style = { 'bold' } },
                        ['@variable.member.yaml'] = { fg = cp.blue, style = { 'bold' } },
                        ['@punctuation.delimiter.yaml'] = { fg = cp.rosewater },
                        ['@string.yaml'] = { fg = cp.green },
                        ['@string.unquoted.yaml'] = { fg = cp.green },
                        ['@number.yaml'] = { fg = cp.peach },
                        ['@boolean.yaml'] = { fg = cp.peach },
                        ['@type.yaml'] = { fg = cp.yellow },
                        ['@label.yaml'] = { fg = cp.blue },

                        -- Elementos Inline con más contraste
                        ['@markup.raw.markdown_inline'] = { fg = cp.teal },
                        ['@markup.list.markdown'] = { fg = cp.yellow, style = { 'bold' } },
                        ['@markup.strong.markdown_inline'] = { fg = cp.maroon, style = { 'bold' } },
                        ['@markup.italic.markdown_inline'] = { fg = cp.sky, style = { 'italic' } },

                        -- UI de Obsidian y Enlaces
                        ObsidianTag = { fg = cp.pink, style = { 'bold' } },
                        ObsidianCheckbox = { fg = cp.blue },
                        ObsidianRefText = { fg = cp.mauve, style = { 'bold' } },
                        ['@markup.link.label.markdown_inline'] = { fg = cp.blue, style = { 'bold' } },
                        ['@markup.link.url.markdown_inline'] = { fg = cp.rosewater, style = { 'italic' } },

                        -- Tablas
                        ['@markup.table.header.markdown'] = { fg = cp.sky, style = { 'bold' } },
                        ['@punctuation.special.markdown_inline'] = { fg = cp.lavender },

                        -- General Overrides
                        Comment = { style = {} },
                    }
                end,
            }
            vim.cmd.colorscheme 'catppuccin'
        end,
    }
else
    theme_plugin = {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        opts = {
            style = active_theme:match 'tokyonight%-(%w+)' or 'moon',
            transparent = false,
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
                sidebars = 'dark',
                floats = 'dark',
            },
            on_highlights = function(hl, c)
                hl.markdownH1 = { fg = c.magenta2, bold = true }
                hl.markdownH2 = { fg = c.red1, bold = true }
                hl.markdownH3 = { fg = c.red, bold = true }
                hl.markdownH4 = { fg = c.orange, bold = true }
                hl.markdownH5 = { fg = c.purple, bold = true }
                hl.markdownH6 = { fg = c.magenta, bold = true }
                hl.markdownH1Delimiter = { fg = c.magenta2, bold = true }
                hl.markdownH2Delimiter = { fg = c.red1, bold = true }
                hl.markdownH3Delimiter = { fg = c.red, bold = true }
                hl.markdownH4Delimiter = { fg = c.orange, bold = true }
                hl.markdownH5Delimiter = { fg = c.purple, bold = true }
                hl.markdownH6Delimiter = { fg = c.magenta, bold = true }
                hl.markdownH7Delimiter = { fg = c.magenta, bold = true }

                hl['@markup.heading.1.markdown'] = { link = 'markdownH1' }
                hl['@markup.heading.2.markdown'] = { link = 'markdownH2' }
                hl['@markup.heading.3.markdown'] = { link = 'markdownH3' }
                hl['@markup.heading.4.markdown'] = { link = 'markdownH4' }
                hl['@markup.heading.5.markdown'] = { link = 'markdownH5' }
                hl['@markup.heading.6.markdown'] = { link = 'markdownH6' }

                hl.yamlPlainScalar = { fg = c.blue }
                hl['@string.yaml'] = { link = 'yamlPlainScalar' }

                hl['@markup.metadata.markdown'] = { fg = c.comment }
                hl['@property.yaml'] = { fg = c.blue, bold = true }
                hl['@string.yaml'] = { fg = c.green }
                hl['@number.yaml'] = { fg = c.orange }

                hl.markdownBold = { fg = c.red, bold = true }
                hl.markdownBoldDelimiter = { fg = c.red }
                hl['@markup.strong'] = { link = 'markdownBold' }
                hl['@markup.strong.markdown_inline'] = { link = 'markdownBold' }

                hl.markdownItalic = { fg = c.yellow, italic = true }
                hl.markdownItalicDelimiter = { fg = c.orange }
                hl['@markup.italic'] = { link = 'markdownItalic' }
                hl['@markup.italic.markdown_inline'] = { link = 'markdownItalic' }
                hl['@punctuation.delimiter.markdown'] = { fg = c.blue8 }

                hl.markdownOrderedListMarker = { fg = c.orange, bold = true }
                hl.markdownListMarker = { fg = c.orange, bold = true }

                hl.markdownCode = { fg = c.green1, italic = true }
                hl.markdownCodeDelimiter = { fg = c.green1, italic = true }
                hl.markdownCodeBlock = { fg = c.green2 }

                hl.markdownUrlDelimiter = { fg = c.pink, bold = true }
                hl.markdownAutomaticLink = { fg = c.pink, bold = true, italic = true }
                hl['@markup.link.url.markdown'] = { link = 'markdownAutomaticLink' }
                hl['@markup.link.label.markdown'] = { link = 'markdownUrlDelimiter' }

                hl.markdownBlockquote = { fg = c.green1, bold = true }
                hl['@markup.quote'] = { link = 'markdownBlockquote' }
                hl['@markup.quote.markdown'] = { link = 'markdownBlockquote' }
                hl['@punctuation.definition.quote.markdown'] = { link = 'markdownBlockquote' }

                hl.markdownUrl = { fg = c.green2, italic = true }
                hl.markdownLinkDelimiter = { fg = c.green1, italic = true }
                hl.markdownLinkTextDelimiter = { fg = c.green1 }

                hl['@lsp.type.decorator.markdown'] = { fg = c.purple, bold = true }
                hl['@lsp.typemod.link.resolved.markdown'] = { fg = c.purple, bold = true }
                hl['@lsp.typemod.wikiLink.resolved.markdown'] = { fg = c.purple, bold = true }
                hl['@markup.link.label.markdown_inline'] = { fg = c.purple, bold = true }
                hl['@markup.link.url.markdown_inline'] = { fg = c.cyan, italic = true }
                hl['@lsp.typemod.punctuation.bracket.resolved.markdown'] = { fg = c.blue0 }

                hl.markdownTableHeader = { fg = c.magenta2, bold = true }
                hl.markdownTableSeparator = { fg = c.magenta2 }
                hl.markdownTable = { fg = c.magenta2 }
                hl.markdownTableRegex = { fg = c.magenta2, bold = true }

                hl['@markup.table'] = { link = 'markdownTable' }
                hl['@markup.table.header'] = { link = 'markdownTableHeader' }
                hl['@markup.table.separator'] = { link = 'markdownTableSeparator' }
                hl['@markup.table.delimiter'] = { fg = c.magenta2 }
                hl['@markup.table.pipe'] = { fg = c.magenta2 }
                hl['@punctuation.special.markdown'] = { fg = c.magenta2 }
                hl['@punctuation.special.markdown_inline'] = { fg = c.magenta2 }
                hl['@punctuation.delimiter.markdown'] = { fg = c.magenta2 }
                hl['@punctuation.delimiter.markdown_inline'] = { fg = c.magenta2 }
                hl['@punctuation.bracket.markdown_inline'] = { fg = c.magenta2 }

                hl.RenderMarkdownTableHead = { fg = c.magenta2, bold = true }
                hl.RenderMarkdownTableRow = { fg = c.magenta2, bold = true }
                hl.RenderMarkdownTableFill = { fg = c.magenta2, bold = true }
                hl.RenderMarkdownTodo = { fg = c.cyan }
                hl.RenderMarkdownSuccess = { fg = c.green }
                hl.RenderMarkdownWarn = { fg = c.yellow }
                hl.RenderMarkdownError = { fg = c.red }
                hl.RenderMarkdownInfo = { fg = c.blue }

                hl.WinSeparator = { fg = c.dark3, bold = true }
                hl.CursorColumn = { bg = c.bg_dark }
            end,
        },
        config = function(_, opts)
            require('tokyonight').setup(opts)
            vim.cmd.colorscheme 'tokyonight'
        end,
    }
end

return {
    theme_plugin,
    {
        'powerman/vim-plugin-AnsiEsc',
    },
    {
        'nvim-lualine/lualine.nvim',
        opts = {
            globalstatus = true,
            sections = {
                lualine_c = { { 'filename', path = 1 } },
                lualine_x = { 'diagnostics', 'lsp_status', 'filetype', 'filesize' },
            },
        },
    },
}

