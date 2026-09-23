-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Current line number only: clear the row wash, accent + bold the number.
-- Re-applied on colorscheme changes AND matugen live reloads (which bypass :colorscheme).
local cursorline_group = vim.api.nvim_create_augroup("YoruCursorLineNr", { clear = true })
local function style_cursorline_nr()
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
  local accent = vim.api.nvim_get_hl(0, { name = "Function", link = false })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = accent.fg, bold = true })
end
vim.api.nvim_create_autocmd("ColorScheme", {
  group = cursorline_group,
  callback = style_cursorline_nr,
})
vim.api.nvim_create_autocmd("User", {
  group = cursorline_group,
  pattern = "MatugenReloaded",
  callback = style_cursorline_nr,
})
-- autocmds load on VeryLazy, after the initial colorscheme; style now too
pcall(style_cursorline_nr)
