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
                -- re-add after nodejs/npm exists: "prettier", "eslint_d", "markdownlint"
            },
        },
    },
}
