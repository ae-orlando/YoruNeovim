-- Terminal bg sync: disabled (reversible) so Kitty blur shows through.
-- When enabled, bg.nvim sets Kitty bg via OSC-11 to match Normal.
-- With transparent Normal (bg=NONE) it resets instead, but disabled = no OSC at all.
return {
    { "typicode/bg.nvim", enabled = false },
}
