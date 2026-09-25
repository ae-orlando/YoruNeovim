# Yoru Neovim

Personal Neovim config built on [LazyVim](https://github.com/LazyVim/LazyVim), managed with `lazy.nvim`.
Wallpaper-adaptive colors via `matugen`, transparent editor for Kitty blur, fullstack (TS/Python/Tailwind/Docker) extras.

## Requirements

- Neovim >= 0.9
- Git
- Optional: `matugen` generating `~/.config/matugen/themes/nvim-colors.json` (enables wallpaper theme, otherwise falls back to `catppuccin-mocha`)
- Optional: Kitty (transparency/blur) + a Nerd Font
- Optional: Node.js/npm (needed before re-enabling `prettier`, `eslint_d`, `markdownlint`)

## Install

```sh
# backup existing config, then:
git clone <this-repo> ~/.config/nvim
nvim  # lazy.nvim bootstraps on first run, see lua/config/lazy.lua
```

Updates are checked silently (`checker.enabled = true, notify = false`).

## Layout

```text
init.lua                  # bootstraps lua/config/lazy.lua
lua/config/
  lazy.lua                # lazy.nvim setup, LazyVim import, disabled RTP plugins, rocks disabled
  options.lua             # cursorline=number only
  autocmds.lua            # YoruCursorLineNr styling, re-applied on ColorScheme + MatugenReloaded
  keymaps.lua             # no custom maps (LazyVim defaults only)
lua/plugins/
  colorscheme.lua         # matugen primary + catppuccin fallback, lualine/bufferline sync
  dashboard.lua           # Snacks dashboard with YORU header
  noice.lua               # notifications only
  git.lua                 # gitsigns only
  project.lua             # Snacks projects picker
  session.lua             # persistence.nvim
  formatting.lua          # conform.nvim + nvim-lint
  mason.lua               # ensure_installed tools
  test.lua                # neotest (python/plenary/vitest)
  trouble.lua             # trouble.nvim
  todo.lua                # todo-comments.nvim
  markdown.lua            # render-markdown.nvim
  visuals.lua             # nvim-colorizer.lua
  bg.lua                  # typicode/bg.nvim (disabled)
  example.lua             # disabled template (returns {})
lazyvim.json              # enabled LazyVim extras
```

## Colors / UI

- `lua/plugins/colorscheme.lua`:
  - If `~/.config/matugen/themes/nvim-colors.json` is readable, loads `daedlock/matugen.nvim` (`watch=true`, `contrast=0.05`, `min_contrast=0.6`, `harmonize=8`) as `matugen`. Otherwise `catppuccin-mocha` with `transparent_background=true`.
  - Clears bg on `Normal, NormalNC, SignColumn, FoldColumn, EndOfBuffer, MsgArea` so Kitty blur shows through; floats/pickers/sidebars keep bg. Restores `vim.g.colors_name` after matugen's `:hi clear`. Re-syncs lualine + bufferline on `User MatugenReloaded`.
  - Lualine: built from `matugen.lualine()`, `c` section lifted to full `fg` for contrast.
  - Bufferline: palette-derived highlights (inactive `base1`, visible `base2`, selected `bg`), `separator_style="slant"`, `indicator.style="underline"`.
- `lua/config/options.lua` + `lua/config/autocmds.lua`:
  - `cursorline=true`, `cursorlineopt="number"` — no row wash. Number takes `Function` (accent) fg + bold, re-applied on colorscheme change and matugen live reload.
- `lua/plugins/dashboard.lua`: Snacks dashboard `YORU` ANSI Shadow header.
- `lua/plugins/noice.lua`: notify-only. `cmdline`, `messages`, `popupmenu`, LSP progress/hover/signature/message, and `bottom_search`/`command_palette` presets all off.
- `lua/plugins/bg.lua`: `typicode/bg.nvim` set `enabled=false` — no OSC-11, preserves transparency.
- `lua/config/lazy.lua`: `install.colorscheme = { "tokyonight", "habamax" }`, `rocks.enabled=false`, disabled RTP: `gzip, tarPlugin, tohtml, tutor, zipPlugin`.

## LazyVim extras (`lazyvim.json`)

`typescript`, `json`, `yaml`, `docker`, `python`, `tailwind`. Language servers come from these extras.

## Keymaps

LazyVim defaults plus (all `silent`, buffer-local where noted):

### Git (`lua/plugins/git.lua`, gitsigns, `BufReadPre`)

| Key | Mode | Action |
| --- | ---- | ------ |
| `]h` / `[h` | n | Next / prev hunk (respects `diff` mode) |
| `<leader>ghs` | n,x | Stage hunk |
| `<leader>ghr` | n,x | Reset hunk |
| `<leader>ghp` | n | Preview hunk inline |
| `<leader>ghb` | n | Blame line (full) |

No fugitive/gitgraph — intentionally slim.

### Projects / sessions

| Key | Plugin | Action |
| --- | ------ | ------ |
| `<leader>pp` | snacks picker (`lua/plugins/project.lua`) | Projects |
| `<leader>Ss` | persistence (`lua/plugins/session.lua`) | Save session |
| `<leader>Sl` | persistence | Restore last session |
| `<leader>Sd` | persistence | Don't save current session |

Sessions stored in `stdpath("state")/sessions/`, `options = { buffers, curdir, tabpages, winsize }`, `save_empty=false`. Auto-saves on `VimLeavePre` if buffer modified.

### Diagnostics / todos

Trouble (`lua/plugins/trouble.lua`, `cmd = Trouble`, `focus=false`):

| Key | Action |
| --- | ------ |
| `<leader>xx` | Diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>cs` | Symbols |
| `<leader>cS` | LSP references/defs |
| `<leader>xL` | Loclist |
| `<leader>xQ` | Quickfix |
| `[q` / `]q` | Prev / next Trouble item, falls back to `cprev`/`cnext` |

Todo-comments (`lua/plugins/todo.lua`, `BufReadPost`):

| Key | Action |
| --- | ------ |
| `]t` / `[t` | Next / prev todo |
| `<leader>xt` | Todo (Trouble) |
| `<leader>xT` | TODO/FIX/FIXME (Trouble) |
| `<leader>st` | Todo (Telescope) |
| `<leader>sT` | TODO/FIX/FIXME (Telescope) |

Keywords: `FIX/FIXME/BUG/FIXIT/ISSUE` (error), `TODO` (info), `HACK/PERF` (warning), `WARN/WARNING/XXX` (warning), `NOTE/INFO` (hint).

### Format / lint / test

Conform (`lua/plugins/formatting.lua`):

| Key | Mode | Action |
| --- | ---- | ------ |
| `<leader>fp` | n,v | Format (`lsp_format="fallback"`) |
| `<leader>fl` | n | `lint.try_lint()` |

Neotest (`lua/plugins/test.lua`, `VeryLazy`):

| Key | Action |
| --- | ------ |
| `<leader>tr` | Run nearest |
| `<leader>tf` | Run file |
| `<leader>ta` | Run all (cwd) |
| `<leader>ts` | Toggle summary |
| `<leader>to` | Open output |

Adapters: `neotest-python` (`justMyCode=false`), `neotest-plenary`, `neotest-vitest`.

## Formatting / linting / tools

`lua/plugins/formatting.lua` (opts-style):

- `conform.formatters_by_ft`: `lua: stylua`, `python: isort, black`, `javascript/typescript/javascriptreact/typescriptreact/json/html/css/markdown/yaml: prettier`.
- `nvim-lint.linters_by_ft`: `python: pylint` only. `eslint_d`/`markdownlint` intentionally omitted until Node/npm exists.

`lua/plugins/mason.lua`:

- `ensure_installed = { stylua, black, isort, pylint, shellcheck, shfmt }`. `prettier/eslint_d/markdownlint` commented out pending Node; `luacheck` dropped (requires luarocks, `rocks.enabled=false`).

## Other plugins

- `markdown.lua`: `render-markdown.nvim` for `markdown, quarto` (+ treesitter dep).
- `visuals.lua`: `norcalli/nvim-colorizer.lua` on `BufReadPost` (`*`, `css={css=true}`, `html={mode="foreground"}`), with `vim.tbl_flatten` compat shim.
- `example.lua`: template file, early `return {}` — loads nothing.

## Customizing

- Colors: edit `lua/plugins/colorscheme.lua` (matugen `opts`, fallback flavour, transparency list, lualine/bufferline functions).
- Cursorline number color follows `Function` hl — change that hl or `style_cursorline_nr()` in `lua/config/autocmds.lua`.
- Add plugins as new `lua/plugins/*.lua` files (auto-imported via `{ import = "plugins" }` in `lua/config/lazy.lua`).
- Re-enable `bg.nvim` in `lua/plugins/bg.lua` if you want Kitty bg OSC-11 sync instead of blur-through.
