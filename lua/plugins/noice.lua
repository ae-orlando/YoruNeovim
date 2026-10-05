-- Noice for notifications only: keep native cmdline/messages/popupmenu
return {
    {
        "folke/noice.nvim",
        opts = {
            cmdline = { enabled = false },
            messages = { enabled = false },
            popupmenu = { enabled = false },
            notify = { enabled = true, view = "notify" },
            lsp = {
                progress = { enabled = false },
                hover = { enabled = false },
                signature = { enabled = false },
                message = { enabled = false },
            },
            presets = {
                bottom_search = false,
                command_palette = false,
                long_message_to_split = false,
            },
        },
    },
}
