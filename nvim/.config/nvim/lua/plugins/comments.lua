return {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        { '<leader>st', function() Snacks.picker.todo_comments() end, desc = 'Todo' },
    },

    opts = { signs = false },
}

