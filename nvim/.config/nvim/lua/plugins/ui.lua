return {
  { 'NMAC427/guess-indent.nvim', opts = {} },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      globalstatus = true,
      sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'lsp_status', 'filetype', 'filesize' },
      },
    },
  },
}
