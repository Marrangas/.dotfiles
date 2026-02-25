return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },

        config = function()
            local filetypes = {
                'bash', 'make', 'c', 'go', 'python', 'lua', 'luadoc',
                'http', 'regex', 'html', 'css', 'json', 'yaml', 'toml',
                'markdown', 'markdown_inline', 'diff',
                'kconfig', 'helm', 'nix', 'vim', 'vimdoc',
                'jinja', 'hcl', 'terraform',
                'sql',
            }
            require('nvim-treesitter.config').setup({
                ensure_installed = filetypes,
                highlight = {
                    enable = true,
                    disable = function(lang, buf)
                        if lang == "html" then
                            print("disabled")
                            return true
                        end

                        local max_filesize = 100 * 1024
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            vim.notify(
                                "File larger than 100KB treesitter disabled for performance",
                                vim.log.levels.WARN,
                                { title = "Treesitter" }
                            )
                            return true
                        end
                    end,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true, },
                fold = { enable = false }
            })
        end,
    },
}
