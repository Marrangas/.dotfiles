# config.sh - Global Layer Definitions for Dotfiles Workspace
# This file is the single source of truth for layering arrays.

# --- LAYER 1: MINIMAL (CI/CD, Headless Server, thin VMs) ---
DOTFILE_FONT="FiraCode Nerd Font"
DOTFILE_FONT_SIZE=12

DOTFILE_STYLE="dark"
DOTFILE_THEME="tokyonight"
DOTFILE_TERMINAL="ghostty"
DOTFILE_SEARCH_TOOL="ripgrep"
DOTFILE_TERMINAL_OPACITY=0.85

DOTFILE_LSP_SERVERS=(
  "pyright"
  "gopls"
  "lua_ls"
)

DOTFILE_LAYER_MINIMAL=(
  "nvim/.config/nvim/init.lua"
  "nvim/.config/nvim/lua/config/autocmd.lua"
  "nvim/.config/nvim/lua/config/options.lua"
  "nvim/.config/nvim/lua/config/keymaps.lua"
  "nvim/.config/nvim/lua/plugins/mini.lua"
)

# --- LAYER 2: STANDARD (Full-featured Developer IDE Profile) ---
DOTFILE_LAYER_STANDARD=(
  "nvim/.config/nvim/lua/plugins/treesitter.lua"
  "nvim/.config/nvim/lua/plugins/lsp.lua"
  "nvim/.config/nvim/lua/plugins/completion.lua"
  "nvim/.config/nvim/lua/plugins/picker.lua"
  "nvim/.config/nvim/lua/plugins/format.lua"
  "nvim/.config/nvim/lua/plugins/lint.lua"
  "nvim/.config/nvim/lua/plugins/comments.lua"
  "nvim/.config/nvim/lua/plugins/git.lua"
  "nvim/.config/nvim/lua/plugins/navegation.lua"
  "nvim/.config/nvim/lua/plugins/quickfix.lua"
  "nvim/.config/nvim/lua/plugins/ui.lua"
  "nvim/.config/nvim/lua/plugins/undo.lua"
  "nvim/.config/nvim/lua/util/wiki_completions.lua"
  "nvim/.config/nvim/luasnippets/markdown.lua"
  "nvim/.config/nvim/luasnippets/all.lua"
  "nvim/.config/nvim/luasnippets/sh.lua"
)

DOTFILE_LAYER_SPECIFIC=(
  "nvim/.config/nvim/lua/plugins/markdown.lua"
  "nvim/.config/nvim/lua/plugins/ia.lua"
  "nvim/.config/nvim/lua/plugins/sec.lua"
  "nvim/.config/nvim/lua/plugins/debug.lua"
)

DOTFILE_PACKAGES=(
  "aerospace"
  "bat"
  "copyq"
  "editorconfig"
  "fonts"
  "fzf"
  "garden"
  "gemini"
  "ghostty"
  "git"
  "htop"
  "macOs"
  "nvim"
  "nvimpager"
  "scripts"
  "starship"
  "tmux"
  "vim"
  "zsh"
)
