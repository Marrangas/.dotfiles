--[[]This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
-- it is better explained there). This allows easily switching between pickers if you prefer using something else!
vim.api.nvim_create_autocmd('LspAttach', { group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }), callback = function(event) local buf = event.buf
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
--]]

return {
    -- { 'ggandor/leap.nvim', },
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        -- Do not use pcall here in the table keys; it executes immediately!
        keys = {
            {
                '<leader>a',
                function() require('harpoon'):list():add() end,
                desc = 'Harpoon [A]dd file',
            },
            {
                '<leader>-',
                function()
                    local harpoon = require 'harpoon'
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end,
                desc = 'Harpoon [E]xplore',
            },
            -- stylua: ignore start
            { '<leader>j', function() pcall(function() require('harpoon'):list():select(1) end) end, desc = 'Harpoon finger 1', },
            { '<leader>k', function() pcall(function() require('harpoon'):list():select(2) end) end, desc = 'Harpoon finger 2', },
            { '<leader>l', function() pcall(function() require('harpoon'):list():select(3) end) end, desc = 'Harpoon finger 3', },
            { '<leader>;', function() pcall(function() require('harpoon'):list():select(4) end) end, desc = 'Harpoon finger 4', },
            -- stylua: ignore end
        },
        config = function() require('harpoon'):setup {} end,
    },
    {
        'mbbill/undotree',
        config = function()
            local target_path = vim.fn.expand '~/.cache/undodir'

            if vim.fn.has 'persistent_undo' == 1 then
                if vim.fn.isdirectory(target_path) == 0 then
                    vim.fn.mkdir(target_path, 'p', 448) -- 0700 in decimal
                end
                vim.opt.undodir = target_path
                vim.opt.undofile = true
            end
            vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
        end,
    },
    -- load a location list                 :cfile quickfix.txt
    -- (edit it by hand)                    :set modifiable
    -- (update the qfix list on the buffer) :cgetbuffer
    -- how to populate from external commands (terraform  logs, compiler...) terraform...
    -- diferences in quickfixlist vs location ()

    --:cexpr system('git grep -n "pattern"').
    --:vim /pattern/gj (d do not jump) **/*

    -- {
    --     "stevearc/quicker.nvim",
    --     opts = {
    --         opts = {
    --             number = true,
    --             relativenumber = true,
    --             wrap = false,
    --         },
    --     },
    --     keys = {
    --         { ">", function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end, desc = "Expand quickfix context", },
    --         { "<", function() require("quicker").collapse() end,                                                desc = "Collapse quickfix context", },
    --     },
    -- }
    -- vim quickfix
    -- vim unimpared
}
