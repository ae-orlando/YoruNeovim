return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "quarto" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("render-markdown").setup({
        enabled = true,
        file_types = { "markdown", "quarto" },
      })
    end,
  },
}
