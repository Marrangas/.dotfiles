return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            quote = {
                enabled = false,
                -- icon = '▌▌',
                -- 1/8	▏	\u258f
                -- 2/8	▎	\u258e
                -- 3/8	▍	\u258d
                -- 4/8	▌	\u258c
                -- 5/8	▋	\u258b
                -- 6/8  ▊	\u258a
                -- 7/8	▉	\u2589
                -- 8/8	█	\u2588
            },
            heading = {
                enabled = true,
                sign = true,
                position = 'inline',
                icons = {},
            },
            pipe_table = {
                enabled = false,
                render_modes = false,
                preset = 'none',
                cell = 'raw',
                style = 'none',
            },
            -- Disable link rendering if icons cause shifting
            link = { enabled = false },
            -- Disable checkboxes if they cause shifting
            checkbox = {
                enabled = true,
                unchecked = { icon = '[ ]', highlight = 'RenderMarkdownTodo' },
                checked = { icon = '[󰄲]', highlight = 'RenderMarkdownSuccess' },
                custom = {
                    pending = { raw = '[~]', rendered = '[󰥔]', highlight = 'RenderMarkdownWarn' },
                    important = { raw = '[!]', rendered = '[]', highlight = 'RenderMarkdownError' },
                    deferred = { raw = '[>]', rendered = '[󰒊]', highlight = 'RenderMarkdownInfo' },
                }
            },
            bullet = { enabled = false },
            -- Remove features that shift layout
            padding = { enabled = false },
            anti_conceal = {
                enabled = false,
                ignore = { 'code_foreground', 'code_background' },
            },
            -- Window options to prevent shifting and ensure rendering
            win_options = {
                conceallevel = { default = 0, rendered = 0 },
                concealcursor = { default = '', rendered = '' },
            },
        },
    },
}