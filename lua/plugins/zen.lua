local saved_laststatus

return {
    {
        "folke/zen-mode.nvim",
        cmd = "ZenMode",
        keys = { { "<leader>mz", "<cmd>ZenMode<cr>", desc = "Zen mode" } },
        opts = {
            window = {
                options = {
                    number = false,
                    relativenumber = false,
                    signcolumn = "no",
                    foldcolumn = "0",
                },
            },
            on_open = function()
                saved_laststatus = vim.o.laststatus
                vim.o.laststatus = 0
                if vim.bo.filetype == "markdown" or vim.bo.filetype == "quarto" then
                    vim.wo.wrap = true
                    vim.wo.linebreak = true
                    vim.wo.spell = true
                end
            end,
            on_close = function()
                vim.o.laststatus = saved_laststatus or 3
            end,
        },
    },
}
