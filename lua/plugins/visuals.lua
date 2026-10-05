return {
    {
        "norcalli/nvim-colorizer.lua",
        event = "BufReadPost",
        config = function()
            local flatten = vim.tbl_flatten
            if vim.iter then
                flatten = function(value)
                    return vim.iter(value):flatten(math.huge):totable()
                end
            end
            require("colorizer").setup({ "*", css = { css = true }, html = { mode = "foreground" } })
            vim.tbl_flatten = flatten
        end,
    },
}
