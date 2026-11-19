local cursorline_group = vim.api.nvim_create_augroup("YoruCursorLineNr", { clear = true })
local function style_cursorline_nr()
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
    local accent = vim.api.nvim_get_hl(0, { name = "Function", link = false })
    -- Syntax foregrounds are enhanced separately; keep the original UI tint.
    local matugen = vim.g.colors_name == "matugen" and package.loaded["matugen"]
    if type(matugen) == "table" and matugen.get_palette then
        local palette = matugen.get_palette()
        if palette and palette.fn then
            accent.fg = palette.fn
        end
    end
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

-- Notes command layer and <leader>m mappings.
require("config.notes")
require("config.markdown_theme")

-- Markdown reading profile. These options are window-local (plus a few
-- buffer-local ones), so they are applied on FileType and again on BufWinEnter.
local markdown_group = vim.api.nvim_create_augroup("YoruMarkdown", { clear = true })

local function apply_markdown_profile()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.breakindentopt = "shift:2"
    vim.opt_local.showbreak = "↳ "
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en"
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.cursorline = false
    vim.opt_local.list = false
    vim.opt_local.textwidth = 0
    vim.opt_local.signcolumn = "auto"
    vim.opt_local.foldcolumn = "0"
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt_local.formatoptions:remove("t")
end

vim.api.nvim_create_autocmd("FileType", {
    group = markdown_group,
    pattern = { "markdown", "quarto" },
    callback = function()
        apply_markdown_profile()
        if vim.api.nvim_buf_get_name(0):match("%.excalidraw%.md$") then
            vim.b.autoformat = false
            local function disable()
                pcall(vim.cmd, "RenderMarkdown buf_disable")
            end
            if package.loaded["render-markdown"] then
                vim.schedule(disable)
            else
                pcall(function()
                    LazyVim.on_load("render-markdown.nvim", function()
                        vim.schedule(disable)
                    end)
                end)
            end
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
    group = markdown_group,
    callback = function(args)
        local filetype = vim.bo[args.buf].filetype
        if filetype == "markdown" or filetype == "quarto" then
            apply_markdown_profile()
        end
    end,
})
