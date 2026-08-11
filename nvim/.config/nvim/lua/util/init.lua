local M = {}

-- Dynamically load all lua files in the util directory
local util_dir = vim.fn.stdpath("config") .. "/lua/util"
local files = vim.fn.glob(util_dir .. "/*.lua", false, true)

for _, file in ipairs(files) do
    local name = vim.fn.fnamemodify(file, ":t:r")
    if name ~= "init" then
        local ok, err = pcall(require, "util." .. name)
        if not ok then
            vim.notify(string.format("Failed to dynamically load util.%s:\n%s", name, err), vim.log.levels.ERROR)
        end
    end
end

return M
