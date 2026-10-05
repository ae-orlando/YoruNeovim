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

-- Bold comments (preserve fg/italic, works for matugen + catppuccin fallback)
local comment_group = vim.api.nvim_create_augroup("YoruBoldComments", { clear = true })
local comment_groups = {
    "Comment",
    "@comment",
    "@comment.documentation",
    "@comment.error",
    "@comment.hint",
    "@comment.info",
    "@comment.note",
    "@comment.todo",
    "@comment.warning",
}
local function style_comments()
    for _, name in ipairs(comment_groups) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        if ok and hl and next(hl) ~= nil then
            hl.bold = true
            pcall(vim.api.nvim_set_hl, 0, name, hl)
        end
    end
end
vim.api.nvim_create_autocmd("ColorScheme", {
    group = comment_group,
    callback = style_comments,
})
vim.api.nvim_create_autocmd("User", {
    group = comment_group,
    pattern = "MatugenReloaded",
    callback = style_comments,
})
-- autocmds load on VeryLazy, after the initial colorscheme; style now too
pcall(style_cursorline_nr)
pcall(style_comments)
