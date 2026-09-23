-- Keep Noice messages but use native bottom cmdline
-- Upstream enables floating cmdline_popup via presets.command_palette
return {
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        view = "cmdline", -- classic bottom, not cmdline_popup floating
      },
      presets = {
        command_palette = false,
        bottom_search = true,
        long_message_to_split = true,
      },
    },
  },
}
