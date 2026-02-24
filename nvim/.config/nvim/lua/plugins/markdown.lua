return {
    {
        "obsidian-nvim/obsidian.nvim",
        version = "*",
        lazy = false,
        ft = "markdown",
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                desc = "Markdown Enhancements",
                pattern = "markdown",
                callback = function()
                    vim.opt_local.conceallevel = 0
                    pcall(vim.treesitter.start)
                end,
            })
        end,

        keys = {
            { "<leader>x.", ":Obsidian links<CR>",   desc = "[X]anadu [>]" },
            { "<leader>xl", ":Obsidian tags ",       desc = "[X]anadu [l]labels" },
            { "<leader>xd", ":Obsidian dailies<CR>", desc = "[X]anadu [D]ailies" },
            { "<leader>xo", ":Obsidian open<CR>",    desc = "[X]anadu [O]pen" },
        },
        ---@module 'obsidian'
        ---@type obsidian.config
        opts = {
            log_level = vim.log.levels.ERROR, -- Silencia los avisos de conceallevel
            ui = { enable = true },
            -- Optional, set to true if you use the Obsidian Advanced URI plugin.
            -- https://github.com/Vinzent03/obsidian-advanced-uri
            legacy_commands = false,

            open = {
                use_advanced_uri = false,
                func = vim.ui.open,
                schemes = { "https", "http", "file", "mailto" },
            },
            -- https://github.com/obsidian-nvim/obsidian.nvim/wiki/Commands

            -- callbacks = {
            --     enter_note = function(note)
            --         vim.keymap.del('n', '<CR>', { buffer = true })
            --         vim.keymap.set('n', '<leader>xx', '<cmd>Obsidian toggle_checkbox<cr>', {
            --             buffer = true,
            --             desc = 'Toggle checkbox',
            --         })
            --     end,
            -- },

            ---@field sort? string[] | (fun(a: any, b: any): boolean) | vim.NIL | boolean
            frontmatter = {
                enabled = false,
                sort = {},
            },

            completion = {
                nvim_cmp = false,
                lsp = false,
                blink = false,
                min_chars = nil,
                create_new = true,
            },

            new_notes_location = "notes_subdir",
            workspaces = {
                {
                    name = "personal",
                    path = "~/Documents/wiki",
                },
            },
            attachments = {
                folder = "media",
                img_name_func = function()
                    return os.date("image_%Y%m%d_%H%M%S")
                end,
                confirm_img_paste = true,
            },
            daily_notes = {
                folder = "diary",
                date_format = "%Y-%m-%d",
                default_tags = { "time/days" },
                template = "templates/daily.md",
            },
            -- TODO: Wrap my head arround: is this going to be obsidian or nvim
            templates = {
                folder = "templates",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
                substitutions = {},
            },

            ---@class obsidian.config.PickerOpts
            ---@field name obsidian.config.Picker|?
            ---@field note_mappings? obsidian.config.PickerNoteMappingOpts
            ---@field tag_mappings? obsidian.config.PickerTagMappingOpts
            picker = {
                name          = 'snacks.nvim',
                note_mappings = {
                    new = "<C-x>",
                    insert_link = "<C-l>",
                },
                tag_mappings  = {
                    tag_note = "<C-x>",
                    insert_tag = "<C-l>",
                },
            },
        },
    },
}
