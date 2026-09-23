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
