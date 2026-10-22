-- Yoru formatting + linting, LazyVim opts-style (no custom `config`, see lazyvim/plugins/formatting.lua)
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
                jsonc = { "prettier" },
                json5 = { "prettier" },
                html = { "prettier" },
                css = { "prettier" },
                markdown = { "prettier" },
                yaml = { "prettier" },
                sh = { "shfmt" },
            },
            -- Keep Prettier/Shfmt aligned with options.lua's four-space defaults.
            -- Explicit CLI arguments override conflicting project indentation.
            -- StyLua follows the target project's config; Black uses four spaces.
            -- Editor options alone do not configure external formatters globally.
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
                -- stylua follows the target project's config; this repository's
                -- stylua.toml sets indent_type="Spaces", indent_width=4.
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
            -- Tool installation is declared in mason.lua plus LazyVim extras.
            -- JS/TS diagnostics come from ESLint LSP (extras.linting.eslint);
            -- eslint_d was removed so diagnostics are not reported twice.
            linters_by_ft = {
                python = { "pylint" },
                sh = { "shellcheck" },
                markdown = { "markdownlint" },
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
    -- SQL: respect the project's .sqlfluff dialect. The upstream lang.sql
    -- extra hardcodes --dialect=ansi, which overrides project config; fall
    -- back to ANSI only for scratch files without a .sqlfluff file.
    {
        "stevearc/conform.nvim",
        optional = true,
        opts = function(_, opts)
            opts.formatters = opts.formatters or {}
            opts.formatters.sqlfluff = {
                args = function(_, ctx)
                    local path = ctx and ctx.filename
                    if not path or path == "" then
                        path = vim.fn.getcwd()
                    end
                    local found = vim.fs.find({ ".sqlfluff" }, { path = path, upward = true })[1]
                    return found and { "format", "-" } or { "format", "--dialect=ansi", "-" }
                end,
            }
        end,
    },
}
