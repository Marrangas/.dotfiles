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
        -- { "<leader>st", function() Snacks.picker.todo_comments() end,                                          desc = "Todo" },
        -- { "<leader>st", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },

        -- Xanadu (Wiki) Keymaps
        {
            '<leader>xx',
            function()
                Snacks.picker.files({
                    cwd = vim.fn.expand("~/Documents/wiki"),
                    follow = true,
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
                    cwd = vim.fn.expand("~/Documents/wiki/system"),
                    confirm = function(picker, item)
                        picker:close()
                        if item then
                            local path = Snacks.picker.util.path(item)
                            local content = vim.fn.readfile(path)
                            vim.api.nvim_put(content, "l", true, true)
                        end
                    end,
                })
            end,
            desc = '[X]anadu [I]nsert template',
        },
        { '<C-\\>',     function() Snacks.terminal.toggle() end,                 desc = 'Toggle Terminal' },

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
            '<leader>sa',
            function()
                Snacks.picker.files {
                    ignored = true,
                    khidden = true,
                    follow = true,
                    cmd = 'fd', -- Force fd for speed in large vaults
                }
            end,
            desc = 'Search All (Inc. Media/Ignored)',
        },
    },
}
