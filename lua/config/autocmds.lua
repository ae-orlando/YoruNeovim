local cursorline_group = vim.api.nvim_create_augroup("YoruCursorLineNr", { clear = true })
local function style_cursorline_nr()
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
    local accent = vim.api.nvim_get_hl(0, { name = "Function", link = false })
    vim.api.nvim_set_hl(0, "CursorLineNr", {
        fg = accent.fg,
        bold = true,
    })
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
