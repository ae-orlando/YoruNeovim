-- Closed-fold text for Markdown notes: the same inline icon render-markdown
-- shows on open headings, the title, and how many lines are hidden.
-- heading_icons lives here so plugins/markdown.lua and the fold display
-- cannot drift apart.
local M = {}

M.heading_icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " }

--- Foldtext for the fold spanning foldstart..foldend. Separate from text()
--- so tests can drive it without a live fold.
function M.render(foldstart, foldend)
    local first = vim.api.nvim_buf_get_lines(0, foldstart - 1, foldstart, false)[1] or ""
    local level, title = first:match("^(#+)%s+(.*)")
    local text
    if level then
        -- Swap the raw markers for the inline icon and drop a closing
        -- sequence (## Title ##).
        local icon = M.heading_icons[math.min(#level, #M.heading_icons)]
        text = icon .. vim.trim(title:gsub("%s*#+%s*$", ""))
    else
        -- Setext headings, fences, and lists keep their own first line.
        text = vim.trim(first)
    end
    local count = foldend - foldstart + 1
    return string.format("%s ─ %d %s", text, count, count == 1 and "line" or "lines")
end

--- 'foldtext' expression evaluated by Neovim for each closed fold.
function M.text()
    return M.render(vim.v.foldstart, vim.v.foldend)
end

return M
