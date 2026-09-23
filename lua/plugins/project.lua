-- Projects via Snacks picker (replaces archived project.nvim + telescope-project, which broke config)
return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>pp", function() Snacks.picker.projects() end, desc = "Projects" },
    },
  },
}
