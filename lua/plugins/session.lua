return {
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {}, -- Persistence owns automatic saving and the default state/sessions directory.
        keys = {
            {
                "<leader>Ss",
                function()
                    require("persistence").save()
                end,
                desc = "Save session",
            },
            {
                "<leader>Sl",
                function()
                    require("persistence").load()
                end,
                desc = "Restore project session",
            },
            {
                "<leader>Sd",
                function()
                    require("persistence").stop()
                end,
                desc = "Don't save current session",
            },
        },
    },
}
