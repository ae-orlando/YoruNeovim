return {
    "brianhuster/live-preview.nvim",
    cmd = { "LivePreview" },
    ft = { "html", "markdown", "asciidoc", "svg" },
    config = function()
        require("livepreview.config").set({
            port = 5500,
            browser = "default",
            dynamic_root = false,
            sync_scroll = true,
            picker = "",
            address = "127.0.0.1",
        })
    end,
    keys = {
        { "<leader>mp", "<cmd>LivePreview start<CR>", desc = "Start Live Preview" },
        { "<leader>mx", "<cmd>LivePreview close<CR>", desc = "Stop Live Preview" },
        { "<leader>mf", "<cmd>LivePreview pick<CR>", desc = "Pick File to Preview" },
    },
}
