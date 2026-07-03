-- ~/.config/nvimpager/init.lua
-- Custom nvimpager configuration that reuses standard Neovim configurations.

vim.opt.runtimepath:prepend(vim.fn.expand("~/.config/nvim"))

local lazy_dir = vim.fn.expand("~/.local/share/nvim/lazy")
if vim.fn.isdirectory(lazy_dir) == 1 then
    local skip_plugins = {
        ["vim-man"] = true,
        ["blink.cmp"] = true,
        ["nvim-cmp"] = true,
        ["avante.nvim"] = true,
    }

    for _, plugin in ipairs(vim.fn.readdir(lazy_dir)) do
        if not skip_plugins[plugin] then
            local plugin_path = lazy_dir .. "/" .. plugin
            if vim.fn.isdirectory(plugin_path) == 1 then
                vim.opt.runtimepath:append(plugin_path)
            end
        end
    end
end

pcall(require, "config.options")
pcall(require, "config.keymaps")

vim.opt.termguicolors = true
vim.opt.number = false
vim.opt.relativenumber = false

if pcall(require, "tokyonight") then
    pcall(require("tokyonight").setup, {
        style = "moon",
        transparent = false,
    })
    vim.cmd("colorscheme tokyonight")
else
    vim.cmd("colorscheme habamax")
end

if nvimpager then
    nvimpager.maps = true
    nvimpager.git_colors = false
end
