return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "quarto" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("render-markdown").setup({
                enabled = true,
                file_types = { "markdown", "quarto" },
                -- Transparent deitor: don't paint block backgrounds
                -- borders/languages stay.
                code = { disable_background = true }
            })
        end,
    },
}
