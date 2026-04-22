return {
  {

    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    lazy = false,
    keys = {
      { '<leader>.f', ':Neotree float<CR>', desc = 'NeoTree floating mode', silent = true },
    },
    opts = {
      window = {
        position = 'float',
        popup_border_style = 'rounded',
        popup = {
          position = '50%',
          border = 'rounded',
          title = nil,
        },
        mappings = {
          ['<esc>'] = 'close_window',
          ['-'] = 'navigate_up',
          ['/'] = 'noop',
        },
      },
    },
    filesystem = {
      header = '',
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = true,
        never_show = {
          '.DS_Store',
          'thumbs.db',
          'icon',
        },
        hide_by_pattern = {
          --"*.meta",
        },
      },
    },
  },
  {
    'folke/noice.nvim',
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
      views = {
        cmdline_popup = {
          position = {
            row = '50%',
            col = '50%',
          },
          size = {
            min_width = 60,
            width = 'auto',
            height = 'auto',
          },
        },
      },
    },
  },
}
