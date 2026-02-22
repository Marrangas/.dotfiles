-- Thus, Language Servers are external tools that must be installed separately from
-- Neovim. This is where `mason` and related plugins come into play.
-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
-- and elegantly composed help section, `:help lsp-vs-treesitter`
-- check the current lsp at https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md

-- There are additional nvim-treesitter modules that you can use to interact
-- with nvim-treesitter. You should go explore a few and see what interests you:
--
--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects

return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      modules = {},
      sync_install = false,
      ignore_install = {},
      ensure_installed = {
        'http',

        'bash',
        'make',
        'c',
        'go',
        'python',
        'lua',
        'luadoc',
        'kconfig',
        'helm',
        'nix',
        'regex',
        'jinja',
        'hcl',
        'sql',
        'html',
        'json',
        'yaml',
        'toml',

        'markdown',
        'markdown_inline',
        'diff',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          scope_incremental = '<Tab>',
          node_decremental = '<BS>',
        },
      },
    }
  end,
}
