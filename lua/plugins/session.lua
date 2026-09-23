return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = {
      { "<leader>Ss", function() require("persistence").save() end, desc = "Save session" },
      { "<leader>Sl", function() require("persistence").load() end, desc = "Restore last session" },
      { "<leader>Sd", function() require("persistence").stop() end, desc = "Don't save current session" },
    },
    config = function()
      require("persistence").setup({
        dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
        options = { "buffers", "curdir", "tabpages", "winsize" },
        save_empty = false,
        pre_save = nil,
        post_save = nil,
        pre_load = nil,
        post_load = nil,
      })

      -- Auto-save/restore when entering/leaving a project
      vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
        callback = function()
          if vim.bo.modified then
            require("persistence").save()
          end
        end,
      })
    end,
  },
}
