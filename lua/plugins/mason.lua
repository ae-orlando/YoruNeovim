-- Yoru tool list. LazyVim extras add more: hadolint (lang.docker),
-- sqlfluff (lang.sql), js-debug-adapter (lang.typescript).
-- eslint_d was replaced by ESLint LSP (extras.linting.eslint) to avoid
-- duplicate diagnostics; already-installed binaries are left untouched.
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
                "markdownlint",
                "vtsls",
                "eslint-lsp",
                "debugpy",
            },
        },
    },
}
