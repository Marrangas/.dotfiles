return {
    {
        "stevearc/quicker.nvim",
        lazy = false,
        config = function(_, opts)
            vim.cmd("packadd cfilter")
            require("quicker").setup(opts)
        end,
        ft = "qf",
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {
            use_default_opts = true,
        },
    },
}
