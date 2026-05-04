return {
    {
        "chipsenkbeil/org-roam.nvim",
        tag = "0.2.0",
        ft = "org",
        cmd = { "RoamNodeFind", "RoamNodeInsert", "RoamUpdate", "RoamSave", "RoamLoad" },
        dependencies = {
            {
                "nvim-orgmode/orgmode",
                tag = "0.7.0",
            },
        },
        config = function()
            require("org-roam").setup({
                directory = "~/Documents/wiki/",
                -- optional
                -- org_files = {
                --     "~/another_org_dir",
                --     "~/some/folder/*.org",
                --     "~/a/single/org_file.org",
                -- }
            })
        end
    }
}
