return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "moon", -- "storm", "night", "day", "moon"
            transparent = false,
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
                sidebars = "dark",
                floats = "dark",
            },
            on_highlights = function(hl, c)
                hl.markdownH1                         = { fg = c.magenta2, bold = true }
                hl.markdownH2                         = { fg = c.red1, bold = true }
                hl.markdownH3                         = { fg = c.red, bold = true }
                hl.markdownH4                         = { fg = c.orange, bold = true }
                hl.markdownH5                         = { fg = c.purple, bold = true }
                hl.markdownH6                         = { fg = c.magenta, bold = true }
                hl.markdownH1Delimiter                = { fg = c.magenta2, bold = true }
                hl.markdownH2Delimiter                = { fg = c.red1, bold = true }
                hl.markdownH3Delimiter                = { fg = c.red, bold = true }
                hl.markdownH4Delimiter                = { fg = c.orange, bold = true }
                hl.markdownH5Delimiter                = { fg = c.purple, bold = true }
                hl.markdownH6Delimiter                = { fg = c.magenta, bold = true }
                hl.markdownH7Delimiter                = { fg = c.magenta, bold = true }
                -- hl.markdownH4          = { fg = c.magenta2, bold = true }

                -- Direct Treesitter & LSP links to ensure the colors stick
                hl["@markup.heading.1.markdown"]      = { link = "markdownH1" }
                hl["@markup.heading.2.markdown"]      = { link = "markdownH2" }
                hl["@markup.heading.3.markdown"]      = { link = "markdownH3" }
                hl["@markup.heading.4.markdown"]      = { link = "markdownH4" }
                hl["@markup.heading.5.markdown"]      = { link = "markdownH5" }
                hl["@markup.heading.6.markdown"]      = { link = "markdownH6" }

                -- YAML / Frontmatter
                hl.yamlPlainScalar                    = { fg = c.blue }
                hl["@string.yaml"]                    = { link = "yamlPlainScalar" }

                hl["@markup.metadata.markdown"]       = { fg = c.comment }
                hl["@property.yaml"]                  = { fg = c.blue, bold = true }
                hl["@string.yaml"]                    = { fg = c.green }
                hl["@number.yaml"]                    = { fg = c.orange }

                hl.markdownBold                       = { fg = c.red, bold = true }
                hl.markdownBoldDelimiter              = { fg = c.red }
                hl["@markup.strong"]                  = { link = "markdownBold" }
                hl["@markup.strong.markdown_inline"]  = { link = "markdownBold" }

                hl.markdownItalic                     = { fg = c.yellow, italic = true }
                hl.markdownItalicDelimiter            = { fg = c.orange }
                hl["@markup.italic"]                  = { link = "markdownItalic" }
                hl["@markup.italic.markdown_inline"]  = { link = "markdownItalic" }
                hl["@punctuation.delimiter.markdown"] = { fg = c.blue8 }

                hl.markdownOrderedListMarker          = { fg = c.orange, bold = true }
                hl.markdownListMarker                 = { fg = c.orange, bold = true }

                hl.markdownCode                       = { fg = c.green1, italic = true }
                hl.markdownCodeDelimiter              = { fg = c.green1, italic = true }
                hl.markdownCodeBlock                  = { fg = c.green2 }

                hl.markdownUrlDelimiter               = { fg = c.pink, bold = true }
                hl.markdownAutomaticLink              = { fg = c.pink, bold = true, italic = true }
                hl["@markup.link.url.markdown"]       = { link = "markdownAutomaticLink" }
                hl["@markup.link.label.markdown"]     = { link = "markdownUrlDelimiter" }



                hl.markdownBlockquote = { fg = c.green1, bold = true }
                hl["@markup.quote"] = { link = "markdownBlockquote" }
                hl["@markup.quote.markdown"] = { link = "markdownBlockquote" }
                hl["@punctuation.definition.quote.markdown"] = { link = "markdownBlockquote" }


                hl.markdownUrl = { fg = c.green2, italic = true }
                hl.markdownLinkDelimiter = { fg = c.green1, italic = true }
                hl.markdownLinkTextDelimiter = { fg = c.green1 }

                hl["@lsp.type.decorator.markdown"] = { fg = c.purple, bold = true }
                hl["@lsp.typemod.link.resolved.markdown"] = { fg = c.purple, bold = true }
                hl["@lsp.typemod.wikiLink.resolved.markdown"] = { fg = c.purple, bold = true }
                -- Standard WikiLink labels (fallback)
                hl["@markup.link.label.markdown_inline"] = { fg = c.purple, bold = true }
                hl["@markup.link.url.markdown_inline"] = { fg = c.cyan, italic = true }
                -- Brackets for resolved links (slightly different color to distinguish)
                hl["@lsp.typemod.punctuation.bracket.resolved.markdown"] = { fg = c.blue0 }

                -- Tables (Magenta2 & Bold)
                hl.markdownTableHeader = { fg = c.magenta2, bold = true }
                hl.markdownTableSeparator = { fg = c.magenta2 }
                hl.markdownTable = { fg = c.magenta2 }
                hl.markdownTableRegex = { fg = c.magenta2, bold = true }

                hl["@markup.table"] = { link = "markdownTable" }
                hl["@markup.table.header"] = { link = "markdownTableHeader" }
                hl["@markup.table.separator"] = { link = "markdownTableSeparator" }
                hl["@markup.table.delimiter"] = { fg = c.magenta2 }
                hl["@markup.table.pipe"] = { fg = c.magenta2 }
                hl["@punctuation.special.markdown"] = { fg = c.magenta2 }
                hl["@punctuation.special.markdown_inline"] = { fg = c.magenta2 }
                hl["@punctuation.delimiter.markdown"] = { fg = c.magenta2 }
                hl["@punctuation.delimiter.markdown_inline"] = { fg = c.magenta2 }
                hl["@punctuation.bracket.markdown_inline"] = { fg = c.magenta2 }

                -- bold lines for render-markdown.nvim
                hl.RenderMarkdownTableHead = { fg = c.magenta2, bold = true }
                hl.RenderMarkdownTableRow = { fg = c.magenta2, bold = true }
                hl.RenderMarkdownTableFill = { fg = c.magenta2, bold = true }

                -- Checkbox highlights
                hl.RenderMarkdownTodo = { fg = c.cyan }
                hl.RenderMarkdownSuccess = { fg = c.green }
                hl.RenderMarkdownWarn = { fg = c.yellow }
                hl.RenderMarkdownError = { fg = c.red }
                hl.RenderMarkdownInfo = { fg = c.blue }

                -- Window Separators
                hl.WinSeparator = { fg = c.dark3, bold = true }
            end,
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd.colorscheme "tokyonight"
        end,
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

    {
        'folke/todo-comments.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            keywords = {
                TASK = { icon = '󰄱 ', color = 'info', alt = { '[- [ ]' }, },
                PENDING = { icon = ' ', color = 'warning', alt = { '[- [~]' } },
                DONE = { icon = '✔ ', color = 'hint', alt = { '[- [x]' } },
            },
        },
    },
}
