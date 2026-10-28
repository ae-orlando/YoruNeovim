-- Yoru tool list. LazyVim extras add more: hadolint (lang.docker), sqlfluff
-- (lang.sql), js-debug-adapter (lang.typescript), clangd + codelldb (lang.clangd).
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
                "clang-format",
                "vtsls",
                "eslint-lsp",
                "bash-language-server",
                "debugpy",
            },
        },
    },
}
