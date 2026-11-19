-- Resolve Markdown and Obsidian image embeds against the vault attachment home.
-- Snacks already parses both ![alt](path) and ![[image.png]]; this only fixes
-- resolution from notes that live in subfolders.
local image_cache = {}

local function resolve_image(file, src)
    src = src:gsub("|.*$", ""):gsub("^<", ""):gsub(">$", "")
    if src == "" or src:match("^%a[%w+.-]*://") then
        return nil
    end

    local note_dir = vim.fs.dirname(file)
    local key = note_dir .. "\0" .. src
    if image_cache[key] then
        return image_cache[key]
    end

    local root = require("config.notes").root
    local candidates = {
        note_dir .. "/" .. src,
        root .. "/" .. src,
        root .. "/attachments/" .. src,
        root .. "/Excalidraw/" .. src,
    }
    for _, candidate in ipairs(candidates) do
        if vim.fn.filereadable(candidate) == 1 then
            image_cache[key] = candidate
            return candidate
        end
    end
    return nil
end

return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "quarto" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("render-markdown").setup({
                enabled = true,
                file_types = { "markdown", "quarto" },
                heading = {
                    sign = false,
                    icons = {},
                    backgrounds = {},
                    border = false,
                },
                bullet = { enabled = true },
                checkbox = { enabled = true },
                code = {
                    disable_background = true,
                    border = "thin",
                    language = true,
                },
                link = { enabled = true },
                pipe_table = { enabled = true, cell = "padded", preset = "none" },
                quote = { enabled = true },
                anti_conceal = { enabled = true },
            })
        end,
    },
    {
        "folke/snacks.nvim",
        opts = function(_, opts)
            opts.image = vim.tbl_deep_extend("force", opts.image or {}, {
                enabled = true,
                doc = { enabled = true, inline = true, max_width = 80, max_height = 40 },
                img_dirs = { "attachments", "Excalidraw" },
                resolve = resolve_image,
            })
            return opts
        end,
    },
}
