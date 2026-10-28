--  __  __              _  __             _
--  \ \/ /__  ______ __/ |/ /__ ___ _  __(_)_ _
--   \  / _ \/ __/ // /    / -_) _ \ |/ / /  ' \
--   /_/\___/_/  \_,_/_/|_/\__/\___/___/_/_/_/_/

-- Yoru Neovim: bootstrap lazy.nvim, LazyVim base and Yoru plugins

-- Language tooling only rewrites files when asked. LazyVim's eslint extra reads
-- this flag while plugin specs are collected, which happens inside
-- config.lazy, so it must be set here (config.options loads too late).
-- ESLint diagnostics stay; only its save-time auto-fix is disabled.
vim.g.lazyvim_eslint_auto_format = false

require("config.lazy")
