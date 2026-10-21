return {
    {
        "folke/todo-comments.nvim",
        event = "BufReadPost",
        dependencies = { "nvim-lua/plenary.nvim" },
        -- Inherit LazyVim's navigation and selected picker's search mappings.
        opts = {
            signs = true,
            sign_priority = 10,
            keywords = {
                FIX = { icon = "", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO = { icon = "", color = "info" },
                HACK = { icon = "", color = "warning" },
                WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = "", color = "warning", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = "", color = "hint", alt = { "INFO" } },
            },
            merge_keywords = true,
            highlight = {
                before = "",
                keyword = "wide",
                after = "fg",
                pattern = [[.*<(KEYWORDS)\s*:]],
                comments_only = true,
                max_line_len = 500,
            },
            colors = {
                error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
                warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
                info = { "DiagnosticInfo", "#2563EB" },
                hint = { "DiagnosticHint", "#10B981" },
                default = { "Identifier", "#7C3AED" },
            },
            search = {
                pattern = [[\b(KEYWORDS)\b]],
            },
        },
    },
}
