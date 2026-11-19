-- Matugen-driven highlight groups for render-markdown.nvim.
-- The editor background stays transparent; these groups only set foregrounds
-- and borders, except where a background must be explicitly cleared.
local M = {}

local function set(name, spec)
    vim.api.nvim_set_hl(0, name, spec)
end

function M.apply()
    local ok, matugen = pcall(require, "matugen")
    if not ok or vim.g.colors_name ~= "matugen" then
        return
    end

    local pal = matugen.get_palette()
    if not pal then
        return
    end

    set("RenderMarkdownH1", { fg = pal.accent, bold = true })
    set("RenderMarkdownH2", { fg = pal.blue, bold = true })
    set("RenderMarkdownH3", { fg = pal.teal, bold = true })
    set("RenderMarkdownH4", { fg = pal.yellow })
    set("RenderMarkdownH5", { fg = pal.orange })
    set("RenderMarkdownH6", { fg = pal.muted })

    -- Keep the underlying treesitter captures in step so heading text and icons
    -- share the same Matugen colors.
    for level, fg in ipairs({ pal.accent, pal.blue, pal.teal, pal.yellow, pal.orange, pal.muted }) do
        set("@markup.heading." .. level .. ".markdown", { fg = fg, bold = level <= 2 })
        set("@markup.heading." .. level, { fg = fg, bold = level <= 2 })
    end
    set("@markup.heading.markdown", { fg = pal.accent, bold = true })
    set("@markup.heading", { fg = pal.accent, bold = true })

    set("RenderMarkdownBullet", { fg = pal.accent })
    set("RenderMarkdownUnchecked", { fg = pal.muted })
    set("RenderMarkdownChecked", { fg = pal.success })

    set("RenderMarkdownLink", { fg = pal.blue })
    set("RenderMarkdownLinkTitle", { fg = pal.blue, underline = false })
    set("RenderMarkdownWikiLink", { fg = pal.blue })

    set("RenderMarkdownCode", { bg = "NONE" })
    set("RenderMarkdownCodeBorder", { fg = pal.base6 })
    set("RenderMarkdownCodeInline", { fg = pal.fg_alt, bg = "NONE" })

    set("RenderMarkdownQuote", { fg = pal.muted, italic = true })
    set("RenderMarkdownTableHead", { fg = pal.accent, bold = true })
    set("RenderMarkdownTableRow", { bg = "NONE" })

    set("RenderMarkdownInfo", { fg = pal.blue })
    set("RenderMarkdownSuccess", { fg = pal.success })
    set("RenderMarkdownHint", { fg = pal.teal })
    set("RenderMarkdownWarn", { fg = pal.warning })
    set("RenderMarkdownError", { fg = pal.error })

    set("RenderMarkdownHtmlComment", { fg = pal.muted })
    set("RenderMarkdownDash", { fg = pal.base6 })
    set("RenderMarkdownMath", { fg = pal.yellow })
    set("RenderMarkdownIndent", { fg = pal.base6 })
    set("RenderMarkdownSign", { bg = "NONE" })
end

M.apply()

local group = vim.api.nvim_create_augroup("YoruMarkdownTheme", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = M.apply })
vim.api.nvim_create_autocmd("User", { group = group, pattern = "MatugenReloaded", callback = M.apply })

return M
