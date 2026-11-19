return {
    {
        "stevearc/aerial.nvim",
        opts = function(_, opts)
            -- Markdown headings come from treesitter; markdown-oxide symbols
            -- remain available as a later fallback.
            opts.backends = { "markdown", "treesitter", "lsp", "man" }
        end,
    },
}
