return {
    { -- Autoformat
        'stevearc/conform.nvim',
        event = { 'BufWritePre' },
        cmd = { 'ConformInfo' },
        keys = {
            -- Triggered on save so no need to add keymap
            {
                '<leader>f',
                function() require('conform').format { async = true, lsp_format = 'fallback' } end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        opts = {
            notify_on_error = false,
            format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for languages that don't
                -- have a well standardized coding style.
                local disable_filetypes = { c = true, cpp = true }
                if disable_filetypes[vim.bo[bufnr].filetype] then
                    return nil
                end

                -- Dynamic timeout: increase for large files
                local timeout = 1000
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
                if ok and stats and stats.size > 200000 then -- > 200KB
                    timeout = 2000
                end

                return {
                    timeout_ms = timeout,
                    lsp_format = 'fallback',
                }
            end,
            formatters_by_ft = {
                lua = { 'stylua' },
                c = { 'clang-format' },
                bash = { 'shfmt' },
                -- go = { 'goimports', 'gofmt' },
                python = function(bufnr)
                    if require("conform").get_formatter_info("ruff_format", bufnr).available then
                        return { "ruff_format" }
                    else
                        return { "isort", "black" }
                    end
                end,
                -- Use the "*" filetype to run formatters on all filetypes.
                -- ["*"] = { "textlint", "codebook" },
                -- Use the "_" filetype to run formatters on filetypes that don't
                -- have other formatters configured.
                -- ["_"] = { "trim_whitespace"
            --  },
                html = { 'prettierd', 'prettier', stop_after_first = true },
                markdown = { 'prettierd', 'prettier', stop_after_first = true },
                javascript = { 'prettierd', 'prettier', stop_after_first = true },
                typescript = { 'prettierd', 'prettier', stop_after_first = true },
                -- Conform can also run multiple formatters sequentially
                -- python = { "isort", "black" },
                --
                -- You can use 'stop_after_first' to run the first available formatter from the list
                -- javascript = { "prettierd", "prettier", stop_after_first = true },
                formatters = {
                    ['clang-format'] = {
                        prepend_args = { '-style=file', '-fallback-style=LLVM' },
                    },
                },
            },
        },
    },
}
