-- : <leader> Must happen before plugins are loaded (otherwise wrong leader will be used)intintintintinitinit
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install`lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  'mbbill/undotree',
  'tpope/vim-sleuth',
  'tpope/vim-vinegar',
  -- 'pope/vim-markdown',

  -- documentation
  'vim-utils/vim-man',

  -- 'oil'
  { 'numToStr/Comment.nvim', opts = {} },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- git
  'tpope/vim-fugitive',
  -- - [ ] https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-align.md
  -- - [ ] https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md

  -- html
  {
    'barrett-ruth/live-server.nvim',
    build = 'pnpm add -g live-server',
    cmd = { 'LiveServerStart', 'LiveServerStop' },
    config = true,
  },

  -- ia + avante.
  -- 'github/copilot.vim', -- run: Copilot setup || Copilot enable

  -- terraform
  'hashicorp/terraform-ls',
  'terraform-linters/tflint',
  'aquasecurity/vim-tfsec',
  'yangzhixuan/bipandoc',

  { import = 'plugins' },
}

require 'marrangas.keymaps'
require 'marrangas.options'
require 'marrangas.autocmd'

-- thank you kikstart nvim
