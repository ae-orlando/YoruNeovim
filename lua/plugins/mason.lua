return {
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "stylua",
                "black",
                "isort",
                "pylint",
                "shellcheck",
                "shfmt",
                "prettier",
                "eslint_d",
                "markdownlint",
                "vtsls",
                "eslint-lsp",
            },
        },
    },
}
