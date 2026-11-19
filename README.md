# Yoru Neovim

This is here so you have a Neovim configuration for TypeScript, Rust, and writing, managed with `lazy.nvim`. It keeps the native bottom command line and follows the desktop palette through Matugen, with transparent editor backgrounds.

If you just want to read the guide, see the [LazyVim docs](https://www.lazyvim.org/).

## Prerequisites

- Neovim **0.12+** built with LuaJIT; verified on **0.12.6**.
- **Git** for cloning and partial clones.
- **ripgrep**, **fd**, **fzf** for search and picker workflows.
- A **C compiler**, `tar`, `curl` for plugin installs.
- Node.js/npm for Prettier, ESLint, Vtsls, Emmet.
- Python 3 for Python tools and tests.
- A **Rust toolchain** (`rustc`, `cargo`, `rustfmt`, `clippy`) for Rust builds; Mason installs `rust-analyzer` and Taplo.
- A **Nerd Font** for icons and a clipboard provider (e.g., `wl-clipboard` on Wayland).

Optional: Matugen writing `~/.config/matugen/themes/nvim-colors.json`, Kitty and Hyprland for the transparency/blur presentation shown in screenshots.

## Installation

### Try without replacing your existing setup

```bash
git clone https://github.com/ae-orlando/YoruNeovim.git "${XDG_CONFIG_HOME:-$HOME/.config}/yoru"
NVIM_APPNAME=yoru nvim
```

`NVIM_APPNAME=yoru` keeps Neovim's configuration, plugin data, state, and cache separate from the default `nvim` directories. Keep using that prefix when launching this installation. The Matugen palette path is shared with the desktop, not isolated by the application name.

### Use as your default

Move any existing Neovim configuration to a backup location first. Then clone into the default location; Git refuses to clone over a non‑empty configuration directory:

```bash
git clone https://github.com/ae-orlando/YoruNeovim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

On first run, `lua/config/lazy.lua` bootstraps `lazy.nvim`. Allow plugin and tool installation to finish, then inspect `:Lazy`, `:Mason`, and `:checkhealth`. Existing Mason tools and plugins in a default installation may affect the result; use the isolated installation for a clean trial.

## Usage

Start with `NVIM_APPNAME=yoru nvim`, or `nvim` for a default installation. The leader key is **Space**.

### Core features

- **Notes** (`<leader>m` group): capture, journal, concept, evidence, and review notes with auto‑dated markdown templates. *Advantage*: quick capture → organized review; templates enforce structure without thinking.
- **In‑box / Find / Grep** (`<leader>mi`, `<leader>mf`, `<leader>mg`): Snacks picker navigation of `00‑inbox`, the vault, or vault‑wide grep. *Advantage*: locate any note in under two seconds.
- **Obsidian integration** (`<leader>mo`): opens the current note via `obsidian://open`. *Advantage*: seamless switch between Neovim and Obsidian vault.
- **Task capture** (`<leader>mT`): prompts for a task and creates it in taskwarrior. *Advantage*: capture ideas from Neovim directly into your task system.
- **Backlinks** (`<leader>mb`): attempts LSP‑based reference lookup. *Advantage*: see where a note is referenced without leaving the buffer.
- **Which‑key help** (`<leader>m`): pops a Which‑key menu of note commands. *Advantage*: discover note commands without memorising keys.
- **Terminal / Taskwarrior** (`<leader>mN`): bottom‑terminal toggles for `task next` or custom commands. *Advantage*: run task management without leaving Neovim.
- **LSP / Language tooling**: pre‑configured LSPs for JavaScript/TypeScript, Python, Rust, and more; inlay hints off by default. *Advantage*: sensible defaults; keep buffers clean, enable help on demand.
- **Formatting / Lint** (`<leader>fp` format, `<leader>fl` manual lint; auto‑format off). *Advantage*: no surprise rewrites; explicit control when you need it.
- **Session management** (`<leader>Sl`): saves/restores project sessions. *Advantage*: re‑open exactly where you left off after a break.
- **Matugen palette**: wallpaper‑adaptive colors via `matugen.nvim`; fallback to Catppuccin Mocha. *Advantage*: your wallpaper drives the editor theme, or a reliable default out of the box.

## Checks

Run the dependency‑free regression checks from the repository root:

```bash
nvim --headless -u NONE -i NONE -n -l tests/run.lua
```

To also exercise the real plugins, point `YORU_TEST_PLUGIN_DIR` at an existing installation whose commits match `lazy-lock.json`:

```bash
YORU_TEST_PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/yoru/lazy" \
    nvim --headless -u NONE -i NONE -n -l tests/run.lua
```

GitHub Actions runs the formatting, unit, and integration checks on every push and pull request (`.github/workflows/ci.yml`).