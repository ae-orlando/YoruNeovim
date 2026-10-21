-- Vtsls formatting settings follow options.lua:
-- tabstop=4, shiftwidth=4, softtabstop=4, expandtab=true (4 spaces).
-- conform.nvim + prettier is the primary JS/TS formatter, but when it falls
-- back to LSP formatting (lsp_format="fallback"), vtsls must also emit 4 spaces.
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
            },
        },
    },
}
