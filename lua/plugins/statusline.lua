-- Markdown-only word count and reading estimate in lualine_x.
-- The Matugen lualine theme is owned by colorscheme.lua; this only appends a
-- component and leaves options/theme untouched.
local cache = {}

local function commas(value)
    local reversed = tostring(value):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (reversed:gsub("^,", ""))
end

local function words()
    local buf = vim.api.nvim_get_current_buf()
    local tick = vim.api.nvim_buf_get_changedtick(buf)
    local entry = cache[buf]
    if not entry or entry.tick ~= tick then
        entry = { tick = tick, value = vim.fn.wordcount().words }
        cache[buf] = entry
    end
    return entry.value
end

local function reading_time()
    return math.max(1, math.ceil(words() / 220))
end

local function markdown()
    local filetype = vim.bo.filetype
    return filetype == "markdown" or filetype == "quarto"
end

vim.api.nvim_create_autocmd("BufWipeout", {
    callback = function(args)
        cache[args.buf] = nil
    end,
})

return {
    {
        "nvim-lualine/lualine.nvim",
        opts = function(_, opts)
            opts.sections = opts.sections or {}
            opts.sections.lualine_x = opts.sections.lualine_x or {}
            table.insert(opts.sections.lualine_x, 1, {
                function()
                    if not markdown() then
                        return ""
                    end
                    local count = words()
                    return string.format("%s words · %d min", commas(count), reading_time())
                end,
                cond = markdown,
            })
        end,
    },
}
