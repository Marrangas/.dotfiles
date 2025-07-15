return {
  'shortcuts/no-neck-pain.nvim',
  config = function()
    require('no-neck-pain').setup {
      version = '*',
      autocmds = {
        enableOnVimEnter = false,
        enableOnTabEnter = true,
      },
      buffers = {
        right = {
          enabled = false,
        },
        left = {
          enabled = true,
          scratchPad = {},
        },
      },
    }
  end,
}
