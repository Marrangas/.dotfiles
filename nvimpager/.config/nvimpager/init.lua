-- ~/.config/nvimpager/init.lua
-- Custom nvimpager configuration that reuses standard Neovim configurations.

-- 1. Prepend standard Neovim config directory to runtimepath
vim.opt.runtimepath:prepend(vim.fn.expand("~/.config/nvim"))

-- 2. Add lazy.nvim plugins to runtimepath so themes and plugins are discoverable
local lazy_dir = vim.fn.expand("~/.local/share/nvim/lazy")
if vim.fn.isdirectory(lazy_dir) == 1 then
    for _, plugin in ipairs(vim.fn.readdir(lazy_dir)) do
        local plugin_path = lazy_dir .. "/" .. plugin
        if vim.fn.isdirectory(plugin_path) == 1 then
            vim.opt.runtimepath:append(plugin_path)
        end
    end
end

-- 3. Load standard options and keymaps safely
pcall(require, 'config.options')
pcall(require, 'config.keymaps')

-- 4. Enable true color support
vim.opt.termguicolors = true

-- 5. Set colorscheme (prefer tokyonight if available)
if pcall(require, 'tokyonight') then
    pcall(require('tokyonight').setup, {
        style = "moon",
        transparent = false,
    })
    vim.cmd("colorscheme tokyonight")
else
    vim.cmd("colorscheme habamax")
end

-- 6. Configure nvimpager specific options
if nvimpager then
    -- Keep standard less-like keymaps (q to quit, space to page down, etc.)
    nvimpager.maps = true
    -- Prefer Neovim's native syntax highlighting for softer/more cohesive theme colors
    nvimpager.git_colors = false
end
