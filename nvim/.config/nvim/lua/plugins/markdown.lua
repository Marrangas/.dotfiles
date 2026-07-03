return {
    {
        'obsidian-nvim/obsidian.nvim',
        version = '*',
        lazy = true,
        cmd = {
            'ObsidianOpen',
            'ObsidianNew',
            'ObsidianQuickSwitch',
            'ObsidianSearch',
            'ObsidianLinks',
            'ObsidianTags',
            'ObsidianDailies',
            'ObsidianWorkspace',
        },
        init = function()
            vim.api.nvim_create_autocmd('FileType', {
                desc = 'Markdown Enhancements',
                pattern = 'markdown',
                callback = function() vim.opt_local.conceallevel = 0 end,
            })
        end,

        keys = {
            { '<leader>x.', ':Obsidian links<CR>', desc = '[X]anadu [>]' },
            { '<leader>xg', ':Obsidian tags ', desc = '[X]anadu [l]labels' },
            { '<leader>xd', ':Obsidian dailies<CR>', desc = '[X]anadu [D]ailies' },
            { '<leader>xo', ':Obsidian open<CR>', desc = '[X]anadu [O]pen' },
            { '<leader>xn', ':Obsidian new<CR>', desc = '[X]anadu [N]ew' },
        },
        ---@module 'obsidian'
        ---@type obsidian.config
        opts = {
            log_level = vim.log.levels.ERROR,
            ui = { enable = false },
            legacy_commands = false,

            open = {
                use_advanced_uri = false,
                func = vim.ui.open,
                schemes = { 'https', 'http', 'file', 'mailto' },
            },

            callbacks = {
                enter_note = function()
                    -- vim.keymap.del('n', '<CR>', { buffer = true })
                    -- vim.keymap.set("n", "<leader>x<CR>", require("obsidian.api").smart_action, { buffer = true })
                end,
            },

            ---@field sort? string[] | (fun(a: any, b: any): boolean) | vim.NIL | boolean
            frontmatter = {
                enabled = false,
                sort = {},
            },

            follow_strategy = 'open',
            new_notes_location = 'vault_root',
            ---@param title string|?
            ---@return string
            note_id_func = function(title)
                if title ~= nil then return title end
                return tostring(os.time())
            end,

            workspaces = {
                {
                    name = 'personal',
                    path = '~/Documents/wiki',
                },
            },
            attachments = {
                folder = 'media',
                confirm_img_paste = true,
            },
            daily_notes = {
                folder = 'time',
                date_format = '%Y-%m-%d',
                default_tags = { 'time/days' },
                template = '.local/templates/t-days.md',
            },
            -- TODO: Wrap my head arround: is this going to be obsidian or nvim
            templates = {
                folder = '.local/templates/',
                date_format = '%Y-%m-%d',
                time_format = '%H:%M',
                substitutions = {},
            },

            ---@class obsidian.config.PickerOpts
            ---@field name obsidian.config.Picker|?
            ---@field note_mappings? obsidian.config.PickerNoteMappingOpts
            ---@field tag_mappings? obsidian.config.PickerTagMappingOpts
            picker = {
                name = 'snacks.nvim',
                note_mappings = {
                    new = '<C-x>',
                    insert_link = '<C-l>',
                },
                tag_mappings = {
                    tag_note = '<C-x>',
                    insert_tag = '<C-l>',
                },
            },
        },
    },

    -- TODO: maybe they are useful but not bundled with nvim
    -- as the start of it but as a bigger suite of tools
    -- { "zk-org/zk-nvim",}
    -- { 'iwe-org/iwe.nvim',}
}
