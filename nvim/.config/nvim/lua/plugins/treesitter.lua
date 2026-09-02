return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },

        init = function()
            -- On nvim-treesitter 'main' branch (for Neovim 0.11/0.12+), 
            -- we explicitly enable native Treesitter highlighting via FileType autocommands.
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local lang = vim.bo[args.buf].filetype
                    if lang == "html" then return end
                    pcall(vim.treesitter.start, args.buf)
                end,
            })
            
            -- Register language aliases for Treesitter to map code block shorthands correctly
            pcall(vim.treesitter.language.register, 'bash', 'sh')
            pcall(vim.treesitter.language.register, 'bash', 'shell')
            pcall(vim.treesitter.language.register, 'python', 'py')
            pcall(vim.treesitter.language.register, 'javascript', 'js')
            pcall(vim.treesitter.language.register, 'typescript', 'ts')
            pcall(vim.treesitter.language.register, 'terraform', 'tf')
            pcall(vim.treesitter.language.register, 'yaml', 'yml')
        end,

        config = function()
            -- Initialize paths and internal settings.
            require("nvim-treesitter").setup()
            
            local filetypes = {
                'bash', 'make', 'c', 'go', 'python', 'lua', 'luadoc',
                'http', 'regex', 'html', 'css', 'json', 'yaml', 'toml',
                'markdown', 'markdown_inline', 'diff',
                'kconfig', 'helm', 'nix', 'vim', 'vimdoc',
                'jinja', 'hcl', 'terraform',
                'sql',
            }
            
            -- Check if query highlights are actually loadable.
            -- This is the most robust check because some parsers are bundled with Neovim, 
            -- but their highlight queries (.scm files) are NOT bundled, requiring full nvim-treesitter installation.
            local to_install = {}
            for _, lang in ipairs(filetypes) do
                local ok, res = pcall(vim.treesitter.query.get, lang, "highlights")
                if not ok or not res then
                    table.insert(to_install, lang)
                end
            end
            
            if #to_install > 0 then
                vim.schedule(function()
                    pcall(require("nvim-treesitter").install, to_install)
                end)
            end
            
            -- Disable highlighting for large files (100KB) for performance
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local max_filesize = 100 * 1024
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
                    if ok and stats and stats.size > max_filesize then
                        vim.notify("File larger than 100KB treesitter disabled for performance", vim.log.levels.WARN, { title = "Treesitter" })
                        pcall(vim.treesitter.stop, args.buf)
                    end
                end,
            })
        end,
    },
}
