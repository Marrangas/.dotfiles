return { -- Autoformatform
  'stevearc/conform.nvim',
  opts = {
    notify_on_error = false,
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      bash = { 'shfmt' },
      terraform = { 'terraformls' },
      -- templ = { 'rustwind', 'templ', 'gopls' },
      -- markdown = { 'markdownling' },
      html = { 'prettier' },
      typescript = { 'prettier' },
      typescripttpreacrt = { 'prettier' },
      javascript = { 'prettier' },
      javascritpreacrt = { 'prettier' },
      python = { 'black' },
    },
  },
}
