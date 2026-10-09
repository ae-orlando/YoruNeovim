-- Fullstack formatting + linting, LazyVim opts-style (no custom `config`, see lazyvim/plugins/formatting.lua)
return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "black" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                javascriptreact = { "prettier" },
                json = { "prettier" },
                html = { "prettier" },
                css = { "prettier" },
                markdown = { "prettier" },
                yaml = { "prettier" },
                sh = { "shfmt" },
            },
            -- Single source of truth for indent: your options.lua
            -- (tabstop=4, shiftwidth=4, softtabstop=4, expandtab=true).
            -- CLI args here override any missing/conflicting project config,
            -- so formatters ALWAYS emit 4 spaces even with no local rc file.
            formatters = {
                prettier = {
                    -- --tab-width 4  -> matches shiftwidth=4
                    -- --use-tabs false -> matches expandtab=true (spaces, not tabs)
                    -- CLI flags win over .prettierrc, so this is the "always" guarantee.
                    prepend_args = { "--tab-width", "4", "--use-tabs", "false" },
                },
                shfmt = {
                    -- -i 4 -> 4-space indent (shfmt defaults to tabs, must override)
                    prepend_args = { "-i", "4" },
                },
                isort = {
                    -- keep isort output compatible with black (which always uses 4 spaces)
                    prepend_args = { "--profile", "black" },
                },
                -- stylua needs no args: stylua.toml already has
                -- indent_type="Spaces", indent_width=4.
                -- black needs no args: black always emits 4 spaces.
            },
        },
        keys = {
            {
                "<leader>fp",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = { "n", "v" },
                desc = "Format code",
            },
        },
    },
    {
        "mfussenegger/nvim-lint",
        opts = {
            -- only linters with installable binaries for now;
            -- re-add eslint_d/markdownlint after nodejs/npm exists
            linters_by_ft = {
                python = { "pylint" },
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
            },
        },
        keys = {
            {
                "<leader>fl",
                function()
                    require("lint").try_lint()
                end,
                desc = "Lint file",
            },
        },
    },
}
