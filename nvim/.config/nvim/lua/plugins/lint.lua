return {
    { -- Linting
        'mfussenegger/nvim-lint',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            local lint = require 'lint'
            lint.linters_by_ft = {
                ["*"] = {
                    "codespell",
                    "misspell",
                },
                clojure = { nil },
                dockerfile = { "hadolint" },
                inko = { nil },
                janet = { nil },
                json = { nil },
                rst = { nil },
                ruby = { nil },
                terraform = {
                    "tflint",
                    "tfsec"
                },
                text = { nil }
            }

            -- Configuration for codespell
            local codespell = lint.linters.codespell
            codespell.args = {
                "--quiet-level",
                "3", -- (1: encoding, 2: binary)
                "-",
            }

            -- Configuration for textlint (usually needs a .textlintrc in project root)
            -- If you find it too noisy, we can specifically ignore certain rules here or in .textlintrc


            -- Create autocommand which carries out the actual linting
            -- on the specified events.
            local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
            vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
                group = lint_augroup,
                callback = function()
                    -- Only run the linter in buffers that you can modify in order to
                    -- avoid superfluous noise, notably within the handy LSP pop-ups that
                    -- describe the hovered symbol using Markdown.
                    if vim.bo.modifiable then lint.try_lint() end
                end,
            })
        end,
    },
}
