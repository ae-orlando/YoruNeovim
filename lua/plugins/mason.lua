-- Yoru tool list. LazyVim extras add more: hadolint (lang.docker), sqlfluff
-- (lang.sql), js-debug-adapter (lang.typescript), clangd + codelldb (lang.clangd),
-- codelldb + crates.nvim (lang.rust), taplo (lang.toml).
-- eslint_d was replaced by ESLint LSP (extras.linting.eslint) to avoid
-- duplicate diagnostics; already-installed binaries are left untouched.
-- rustfmt and clippy remain system toolchain components; rust-analyzer and
-- taplo are installed by Mason so the editor setup does not depend on rustup.
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
                "rust-analyzer",
                "taplo",
                "eslint-lsp",
                "bash-language-server",
                "debugpy",
            },
        },
    },
}
