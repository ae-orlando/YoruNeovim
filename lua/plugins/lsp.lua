-- Force every LSP that can format/indents to follow options.lua:
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
                -- eslint is diagnostics-only here (prettier owns formatting),
                -- so no indent settings needed for eslint-lsp.
            },
        },
    },
}
