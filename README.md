# Yoru Neovim

License: `Apache-2.0` (see `LICENSE`). Base: [LazyVim](https://github.com/LazyVim/LazyVim).

## Overview

Yoru is a LazyVim-based Neovim distro managed with `lazy.nvim`. It restores the classic bottom `:` cmdline and syncs the editor theme to the Hyprland system theme via `matugen` with Kitty blur-through.

For all stock behavior, keymaps, and extras, refer to the [LazyVim docs](https://www.lazyvim.org/).

## Prerequisites

- `Neovim >= 0.9` (tested on `v0.12.5`)
- `Git`
- A `Nerd Font`
- `Node.js` / `npm` (required for `prettier`, `eslint_d`, `vtsls`)
- Optional: `Kitty` (transparency / blur)
- Optional: `matugen` writing `~/.config/matugen/themes/nvim-colors.json`

## Installation

Run:

```sh
mv ~/.config/nvim ~/.config/nvim.bak
git clone <this-repo-url> ~/.config/nvim
nvim
```

On first run `lazy.nvim` bootstraps from `lua/config/lazy.lua`. Use `:Lazy` to sync and `:Mason` to verify tools.

## Usage

Start with `nvim`. Everything not listed below is stock LazyVim; see the [LazyVim docs](https://www.lazyvim.org/). `lua/config/keymaps.lua` adds no maps.

### Classic cmdline

- `lua/plugins/noice.lua` is notify-only: `cmdline`, `messages`, `popupmenu`, LSP `progress` / `hover` / `signature` / `message`, and `bottom_search` / `command_palette` presets are `false`.
- Use native `:`, `/`, `?` at the bottom.

### System theme

- If `~/.config/matugen/themes/nvim-colors.json` is readable, load `daedlock/matugen.nvim` (`watch=true`) as `matugen`; else load `catppuccin-mocha` with `transparent_background=true`.
- See `lua/plugins/colorscheme.lua` to tune `contrast`, `min_contrast`, `harmonize`, fallback flavour, or transparency list.
- `Normal`, `NormalNC`, `SignColumn`, `FoldColumn`, `EndOfBuffer`, `MsgArea` use `bg=NONE` for Kitty blur; floats keep `bg`. Statusline and tabline re-sync on `User MatugenReloaded`.
- `lua/plugins/bg.lua` sets `typicode/bg.nvim` to `enabled=false`; re-enable it for Kitty OSC-11 sync.

### Yoru defaults

- `cursorline=true`, `cursorlineopt="number"` with accent bold number; bold `Comment` / `@comment*`; see `lua/config/options.lua` and `lua/config/autocmds.lua`.
- 4-space indent enforced via `lua/config/options.lua`, `.editorconfig`, `stylua.toml`, `.prettierrc.json`, `lua/plugins/formatting.lua`, and `lua/plugins/lsp.lua`.
- `lua/plugins/dashboard.lua` replaces the header with `YORU`.
- `lua/plugins/live-server.lua` adds `LivePreview` for `html`, `markdown`, `asciidoc`, `svg`.
- `lua/plugins/git.lua` sets `gitsigns.nvim` to `enabled=false`.
- `lazyvim.json` enables only `lazyvim.plugins.extras.lang.typescript`.

## Project Structure

```text
init.lua                  # bootstraps lua/config/lazy.lua
lua/config/
  lazy.lua                # lazy.nvim + LazyVim import
  options.lua             # Yoru options
  autocmds.lua            # CursorLineNr + bold comments
  keymaps.lua             # empty, use LazyVim defaults
lua/plugins/
  colorscheme.lua         # matugen + catppuccin fallback
  dashboard.lua           # YORU header
  noice.lua               # notify-only
  bg.lua                  # bg.nvim disabled
  formatting.lua          # Yoru formatter / linter opts
  mason.lua               # ensure_installed tools
  lsp.lua                 # vtsls indent
  git.lua                 # gitsigns disabled
  live-server.lua         # live-preview
lazyvim.json              # enabled LazyVim extras
lazy-lock.json            # pinned plugin commits
```
