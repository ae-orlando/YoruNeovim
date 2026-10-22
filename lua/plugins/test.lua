-- Fullstack tests: vitest + pytest (+ plenary), driven by LazyVim's
-- test.core extra (see lazyvim.json). The extra supplies core setup and
-- base mappings; Yoru's keys below override its same-lhs bindings and the
-- adapters merge with the extra's opts.
return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-plenary",
            "marilari88/neotest-vitest",
        },
        opts = {
            adapters = {
                ["neotest-python"] = { dap = { justMyCode = false } },
                ["neotest-plenary"] = {},
                ["neotest-vitest"] = {},
            },
        },
        keys = {
            {
                "<leader>tr",
                function()
                    require("neotest").run.run()
                end,
                desc = "Run nearest test",
            },
            {
                "<leader>tf",
                function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end,
                desc = "Run test file",
            },
            {
                "<leader>ta",
                function()
                    require("neotest").run.run(vim.fn.getcwd())
                end,
                desc = "Run all tests",
            },
            {
                "<leader>ts",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Toggle test summary",
            },
            {
                "<leader>to",
                function()
                    require("neotest").output.open()
                end,
                desc = "Open test output",
            },
        },
    },
}
