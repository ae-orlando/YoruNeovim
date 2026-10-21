return {
    {
        "norcalli/nvim-colorizer.lua",
        event = "BufReadPost",
        config = function()
            -- Older Colorizer calls this during setup; only supply it if Neovim removed it.
            if vim.tbl_flatten == nil then
                vim.tbl_flatten = function(value)
                    return vim.iter(value):flatten(math.huge):totable()
                end
            end
            require("colorizer").setup({ "*", css = { css = true }, html = { mode = "foreground" } })
        end,
    },
}
