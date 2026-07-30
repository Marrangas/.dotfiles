return {
    {
        "stevearc/quicker.nvim",
        lazy = false,
        config = function()
            vim.cmd("packadd cfilter")
        end,
        ft = "qf",
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {
            opts = {
                number = true,
                relativenumber = true,
                wrap = false,
            },
        },
        keys = {
            {
                ">",
                function()
                    require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                end,
                desc = "Expand quickfix context",
                ft = "qf",
            },
            {
                "<",
                function()
                    require("quicker").collapse()
                end,
                desc = "Collapse quickfix context",
                ft = "qf",
            },
        },
    },
}
