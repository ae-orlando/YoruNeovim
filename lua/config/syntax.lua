-- Syntax-only color separation. Keep Matugen's shared palette and UI untouched.
local M = {}

-- Scale chroma, not lightness or hue. Caps keep supporting colors restrained;
-- stronger user overrides are never desaturated.
local roles = {
    {
        source = "fn",
        gain = 1.6,
        cap = 0.075,
        groups = { "Function", "@function", "@function.call", "@function.method", "@function.method.call" },
    },
    { source = "builtin", gain = 1.5, cap = 0.065, groups = { "@function.builtin" } },
    {
        source = "type",
        gain = 1.55,
        cap = 0.075,
        groups = { "Type", "Structure", "Typedef", "@type", "@type.builtin", "@type.definition", "@constructor" },
    },
    {
        source = "const",
        gain = 1.5,
        cap = 0.075,
        groups = { "Constant", "Boolean", "@constant", "@constant.builtin", "@constant.macro", "@boolean" },
    },
    { source = "str", gain = 1.65, cap = 0.06, groups = { "String", "Character", "@string", "@character" } },
    { source = "num", gain = 1.65, cap = 0.06, groups = { "Number", "Float", "@number", "@number.float" } },
    { source = "prop", gain = 1.2, cap = 0.045, groups = { "@property", "@variable.member", "@tag.attribute" } },
}

function M.apply()
    if vim.g.colors_name ~= "matugen" then
        return
    end
    -- A theme event must not force-load Matugen (or interfere with a fallback).
    local matugen = package.loaded["matugen"]
    if type(matugen) ~= "table" or not matugen.get_palette or not matugen.color then
        return
    end
    local palette = matugen.get_palette()
    if not palette then
        return
    end
    local color = matugen.color()
    for _, role in ipairs(roles) do
        local source = palette[role.source]
        if source then
            -- Always derive from the original palette, never the last highlight.
            local lch = color.hex_to_oklch(source)
            local chroma = math.max(lch.C, math.min(lch.C * role.gain, role.cap))
            local fg = source
            if chroma > lch.C then
                fg = color.oklch(lch.L, chroma, lch.h)
            end
            for _, name in ipairs(role.groups) do
                local hl = vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
                if next(hl) then
                    -- Preserve the effective styling of linked captures, too.
                    hl.fg = fg
                    vim.api.nvim_set_hl(0, name, hl)
                end
            end
        end
    end
end

return M
