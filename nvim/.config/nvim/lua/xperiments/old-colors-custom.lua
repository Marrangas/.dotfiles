return    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        priority = 1000,
        config = function()
            require('catppuccin').setup {
                flavour = 'mocha',
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
                        ['@lsp.type.section.markdown'] = { link = 'markdownH1' }, -- markdown-oxide often uses 'section' for H1

                        -- Frontmatter (YAML Metadata) - Separación Robusta
                        ['@markup.metadata.markdown'] = { fg = cp.overlay1 },             -- Los marcadores ---
                        ['@punctuation.delimiter.markdown'] = { fg = cp.overlay1 },       -- Alternativa para ---
                        ['@property.yaml'] = { fg = cp.blue, style = { 'bold' } },        -- Claves
                        ['@variable.member.yaml'] = { fg = cp.blue, style = { 'bold' } }, -- Claves (alternativa)
                        ['@punctuation.delimiter.yaml'] = { fg = cp.rosewater },          -- El colon :
                        ['@string.yaml'] = { fg = cp.green },                             -- Valores de texto
                        ['@string.unquoted.yaml'] = { fg = cp.green },                    -- Valores sin comillas
                        ['@number.yaml'] = { fg = cp.peach },                             -- Valores numéricos
                        ['@boolean.yaml'] = { fg = cp.peach },                            -- Valores booleanos
                        ['@type.yaml'] = { fg = cp.yellow },
                        ['@label.yaml'] = { fg = cp.blue },

                        -- Elementos Inline con más contraste
                        ['@markup.raw.markdown_inline'] = { fg = cp.teal },                 -- Código `inline` en Teal (Cian)
                        ['@markup.list.markdown'] = { fg = cp.yellow, style = { 'bold' } }, -- Balas en Amarillo
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
                        ['@punctuation.special.markdown_inline'] = { fg = cp.lavender }, -- Los pipes |

                        -- General Overrides
                        Comment = { style = {} }, -- Clean comments (no italics)
                    }
                end,
            }
            vim.cmd.colorscheme 'catppuccin-mocha'
        end,
    },