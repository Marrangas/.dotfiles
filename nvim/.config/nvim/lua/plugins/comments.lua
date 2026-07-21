return {
    {
        'folke/todo-comments.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            keywords = {
                TODO = { icon = '󰄱 ', color = 'info', alt = { '- [ ]' } },
                ONGOING = { icon = ' ', color = 'warning', alt = { '- [~]' } },
                DONE = { icon = '✔ ', color = 'hint', alt = { '- [x]' } },
            },
            highlight = {
                comments_only = false,
                pattern = {
                    '.*<(KEYWORDS)\\s*:', -- matches standard KEYWORDS:
                    '\\s*-\\s*\\[[ x~]\\]', -- Vim regex matching - [ ], - [x], or - [~]
                },
            },
            search = {
                pattern = '\\b(KEYWORDS):|[-]\\s*\\[[ x~]\\]',
            },
        },
        keys = {
            { '<leader>st', function() Snacks.picker.todo_comments() end, desc = 'Todo' },
        },
    },
    { 'nvim-mini/mini.comment' },
    { 'numToStr/Comment.nvim' },
}
