--[[ This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
-- it is better explained there). This allows easily switching between pickers if you prefer using something else!
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- Find references for the word under your cursor.
vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

-- Jump to the implementation of the word under your cursor.
-- Useful when your language has ways of declaring types without an actual implementation.
vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

-- Jump to the definition of the word under your cursor.
-- This is where a variable was first declared, or where a function is defined, etc.
-- To jump back, press <C-t>.
vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

-- Fuzzy find all the symbols in your current document.
-- Symbols are things like variables, functions, types, etc.
vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

-- Fuzzy find all the symbols in your current workspace.
-- Similar to document symbols, except searches over your entire project.
vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

-- Jump to the type of the word under your cursor.
-- Useful when you're not sure what type a variable is and you want to see
-- the definition of its *type*, not where it was *defined*.
vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
-- Override default behavior and theme when searching
vim.keymap.set('n', '<leader>/', function() -- You can pass additional configuration to Telescope to change the theme, layout, etc. builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false, }) end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set( 'n', '<leader>s/', function() builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files', } end, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
-- Legacy Telescope mappings (Disabled)
]] --

return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        picker = {
            enabled = true,
            ui_select = true,
        },
        bigfile = { enabled = true },
        image = { enabled = true },
        terminal = { enabled = true },
        explorer = { enabled = false },
        dashboard = { enabled = false },
        notifier = { enabled = false },
        input = { enabled = false },
    },
    keys = {
        -- High performance replacements for Telescope
        { '<leader>sf', function() Snacks.picker.files() end,                                   desc = 'Search [F]iles' },

        { '<leader>sg', function() Snacks.picker.grep() end,                                    desc = 'Search [G]rep' },
        { '<leader>sb', function() Snacks.picker.buffers() end,                                 desc = 'Search [B]uffers' },
        { '<leader>sh', function() Snacks.picker.help() end,                                    desc = 'Search [H]elp' },
        { '<leader>sk', function() Snacks.picker.keymaps() end,                                 desc = 'Search [K]eymaps' },
        { '<leader>sq', function() Snacks.picker.qflist() end,                                  desc = 'Search [Q]uickfix List' },
        { '<leader>ss', function() Snacks.picker.pickers() end,                                 desc = 'Search [S]elect Picker' },
        { '<leader>sw', function() Snacks.picker.grep_word() end,                               desc = 'Search current [W]ord' },
        { '<leader>sd', function() Snacks.picker.diagnostics() end,                             desc = 'Search [D]iagnostics' },
        { '<leader>s.', function() Snacks.picker.resume() end,                                  desc = 'Search [R]esume' },
        { '<leader>sc', function() Snacks.picker.commands() end,                                desc = 'Search [C]ommands' },
        { '<leader>sn', function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = 'Search [N]eovim files' },
        { '<leader>/',  function() Snacks.picker.lines() end,                                   desc = 'Search [/] in Buffer' },
        { '<leader>s/', function() Snacks.picker.grep_buffers() end,                            desc = 'Search [/] in Open Files' },

        -- Xanadu (Wiki) Keymaps
        {
            '<leader>xf',
            function()
                Snacks.picker.files({
                    cwd = vim.fn.expand("~/Documents/wiki"),
                    win = {
                        input = {
                            keys = {
                                ['<C-l>'] = { 'insert_link', mode = { 'n', 'i' } },
                            },
                        },
                    },
                    actions = {
                        insert_link = function(picker, item)
                            picker:close()
                            local name = vim.fn.fnamemodify(item.file, ':t:r')
                            vim.api.nvim_put({ '[[' .. name .. ']]' }, 'c', true, true)
                        end,
                    },
                    transform = function(item)
                        if item.file:match("%.pdf$") or item.file:match("%.png$") or item.file:match("%.jpg$") or item.file:match("%.jpeg$") then
                            item.score_add = (item.score_add or 0) - 100
                        end
                        return item
                    end,
                })
            end,
            desc = '[X]anadu [F]iles',
        },
        {
            '<leader>xg',
            function()
                Snacks.picker.grep({
                    cwd = vim.fn.expand("~/Documents/wiki"),
                    win = {
                        input = {
                            keys = {
                                ['<C-l>'] = { 'insert_link', mode = { 'n', 'i' } },
                            },
                        },
                    },
                    actions = {
                        insert_link = function(picker, item)
                            picker:close()
                            local name = vim.fn.fnamemodify(item.file, ':t:r')
                            vim.api.nvim_put({ '[[' .. name .. ']]' }, 'c', true, true)
                        end,
                    },
                })
            end,
            desc = '[X]anadu [G]rep',
        },
        {
            '<leader>xt',
            function()
                Snacks.picker.lsp_symbols({
                    filter = { default = { 'Interface', 'String' } },
                    layout = {
                        layout = {
                            box = "vertical",
                            width = 0.8,
                            height = 0.9,
                            { win = "preview", title = "{preview}", border = "rounded" },
                            {
                                box = "vertical",
                                border = "rounded",
                                height = 15,
                                title = "{title} {live} {flags}",
                                { win = "input", height = 1, border = "bottom" },
                                { win = "list" },
                            },
                        },
                    },
                })
            end,
            desc = '[X]anadu [T]OC',
        },
        {
            '<leader>x,',
            function()
                Snacks.picker.lsp_references({
                    title = "Backlinks (LSP)",
                    layout = {
                        layout = {
                            box = "vertical",
                            width = 0.8,
                            height = 0.9,
                            { win = "preview", title = "{preview}", border = "rounded" },
                            {
                                box = "vertical",
                                border = "rounded",
                                height = 15,
                                title = "{title} {live} {flags}",
                                { win = "input", height = 1, border = "bottom" },
                                { win = "list" },
                            },
                        },
                    },
                })
            end,
            desc = '[X]anadu Backlinks (LSP)',
        },
        {
            '<leader>xi',
            function()
                Snacks.picker.files({
                    cwd = vim.fn.expand("~/Documents/wiki/templates"),
                    confirm = function(picker, item)
                        picker:close()
                        if item then
                            local path = (item.dir or picker:dir()) .. "/" .. item.file
                            local content = vim.fn.readfile(path)
                            vim.api.nvim_put(content, "l", true, true)
                        end
                    end,
                })
            end,
            desc = '[X]anadu [I]nsert template',
        },
        {
            '<leader>xi',
            function()
                Snacks.picker.files({
                    title = "Insert Wikilink",
                    cwd = vim.fn.expand("~/Documents/wiki"),
                    confirm = function(picker, item)
                        picker:close()
                        if item then
                            local name = vim.fn.fnamemodify(item.file, ':t:r')
                            vim.api.nvim_put({ '[[' .. name .. ']]' }, 'c', true, true)
                        end
                    end,
                })
            end,
            desc = '[X]anadu [I]nsert',
        },
        { '<leader>bd', function() Snacks.bufdelete() end,                       desc = 'Delete Buffer' },
        { '<C-/>',      function() Snacks.terminal.toggle() end,                 desc = 'Toggle Terminal' },

        -- LSP Keymaps
        { 'grr',        function() Snacks.picker.lsp_references() end,           desc = '[G]oto [R]eferences' },
        { 'gri',        function() Snacks.picker.lsp_implementations() end,      desc = '[G]oto [I]mplementation' },
        { 'grd',        function() Snacks.picker.lsp_definitions() end,          desc = '[G]oto [D]efinition' },
        { 'grt',        function() Snacks.picker.lsp_type_definitions() end,     desc = '[G]oto [T]ype Definition' },
        { 'gO',         function() Snacks.picker.lsp_symbols() end,              desc = 'Document Symbols' },
        { 'gt',         function() require 'man'.show_toc() end,                 desc = 'Document Symbols' },
        { 'gW',         function() Snacks.picker.lsp_workspace_symbols() end,    desc = 'Workspace Symbols' },
        { 'gli',        function() Snacks.picker.lsp_incoming_calls() end,       desc = 'Ca[l]ls Incoming' },
        { 'glo',        function() Snacks.picker.lsp_outgoing_calls() end,       desc = 'Ca[l]ls Outgoing' },

        -- GitHub Keymaps
        { '<leader>gi', function() Snacks.picker.gh_issue() end,                 desc = 'GitHub Issues (open)' },
        { '<leader>gI', function() Snacks.picker.gh_issue { state = 'all' } end, desc = 'GitHub Issues (all)' },
        { '<leader>gp', function() Snacks.picker.gh_pr() end,                    desc = 'GitHub Pull Requests (open)' },
        { '<leader>gP', function() Snacks.picker.gh_pr { state = 'all' } end,    desc = 'GitHub Pull Requests (all)' },

        -- THE COMPROMISE: "Discovery Mode"
        -- This ignores your 'file_ignore_patterns' so you can find media/hidden files
        {
            '<leader>sA',
            function()
                Snacks.picker.files {
                    ignored = true,
                    hidden = true,
                    follow = true,
                    cmd = 'fd', -- Force fd for speed in large vaults
                }
            end,
            desc = 'Search All (Inc. Media/Ignored)',
        },
    },
}
