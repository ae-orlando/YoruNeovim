local opt = vim.opt

-- Format only on request (<leader>fp, LazyVim's <leader>cf). LazyVim's own
-- options load first and set this true; this file runs immediately after and
-- wins, so no formatter rewrites files on BufWritePre. <leader>uf re-enables
-- it for a session if wanted.
vim.g.autoformat = false

vim.opt.wrap = false

-- ============================================
-- Visual Settings
-- ============================================
opt.termguicolors = true -- True color support
opt.number = true -- Line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true -- Highlight current line
opt.cursorlineopt = "number"
-- opt.signcolumn = "yes" -- Always show sign column
opt.scrolloff = 8 -- Keep cursor centered
opt.list = true -- Show invisible characters
opt.listchars = { tab = "➤ ", trail = "·" }

-- ============================================
-- Cursor Settings
-- ============================================
opt.guicursor =
    "n-v-c-sm:block-blinkon500-blinkoff500-blinkwait200,i-ci-ve:ver25-blinkon500-blinkoff500-blinkwait200,r-cr:hor20,o:hor20"

-- ============================================
-- Tab Settings
-- ============================================
opt.tabstop = 4 -- Tab width
opt.shiftwidth = 4 -- Indent width
opt.softtabstop = 4 -- Tab in insert mode
opt.expandtab = true -- Use spaces
opt.autoindent = true -- Auto indent
opt.smartindent = true -- Smart indent

-- ============================================
-- Line Alignment
-- ============================================
vim.opt.statuscolumn = "%s%{%v:relnum == 0 ? v:lnum .. ' ' : '%=' .. v:relnum%} "

-- ============================================
-- Search Settings
-- ============================================
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Override if search has capitals
opt.hlsearch = true -- Highlight matches
opt.incsearch = true -- Show matches while typing

-- ============================================
-- Behavior Settings
-- ============================================
opt.mouse = "a" -- Enable mouse
opt.clipboard = "unnamedplus" -- System clipboard
opt.undofile = true -- Persistent undo
opt.swapfile = false -- No swap files (cleaner)
opt.backup = false -- No backup files
opt.splitright = true -- Vertical splits go right
opt.splitbelow = true -- Horizontal splits go down

-- ============================================
-- Performance
-- ============================================
opt.timeoutlen = 300 -- Faster key sequences
opt.updatetime = 250 -- Faster CursorHold

-- ============================================
-- Spell check
-- ============================================
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
