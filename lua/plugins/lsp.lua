-- Vtsls formatting settings follow options.lua:
-- tabstop=4, shiftwidth=4, softtabstop=4, expandtab=true (4 spaces).
-- conform.nvim + prettier is the primary JS/TS formatter, but when it falls
-- back to LSP formatting (lsp_format="fallback"), vtsls must also emit 4 spaces.
-- Language extras (Python, Tailwind, JSON, YAML, Docker, SQL, ESLint) add
-- their own servers via lazyvim.json; the entries below cover what LazyVim
-- has no extra for.
return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                vtsls = {
                    settings = {
                        typescript = {
                            format = {
                                indentSize = 4,
                                tabSize = 4,
                                convertTabsToSpaces = true,
                            },
                        },
                        javascript = {
                            format = {
                                indentSize = 4,
                                tabSize = 4,
                                convertTabsToSpaces = true,
                            },
                        },
                    },
                },
                -- ESLint tooling is installed in mason.lua; its policy is unchanged
                -- here. Prettier remains the primary JS/TS formatter.
                -- Web markup/styling: no LazyVim extra covers these servers.
                html = {},
                cssls = {},
                -- lang.python enables the Ruff LSP by default; Yoru keeps Pylint
                -- as the single Python linter so diagnostics are not doubled.
                ruff = { enabled = false },
            },
        },
    },
}
