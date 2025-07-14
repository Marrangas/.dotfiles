return { -- Autoformat
  'stevearc/conform.nvim',
  opts = {
    notify_on_error = false,
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      terraform = { 'terraformls' },
      bash = { 'shfmt' },
      -- html = { 'prettierd' },
      markdown = { 'prettierd' },
      templ = { 'rustwind', 'templ', 'gopls' },
      -- typescript = { 'rustwind' },
      -- typescripttpreacrt = { 'rustwind' },
      -- javascritp = { 'rustwind' },
      -- javascritpreacrt = { 'prettierd' },
      -- Conform can also run multiple formatters sequentially
      python = { 'brunette' },
      --
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
      -- javascript = { { "prettierd", "prettier" } },
    },
  },
}
