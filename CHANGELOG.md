# Changelog

## 0.2.0 (unreleased)

### Added
- Heading bands: full-width, per-level backgrounds derived in OKLCH, with equal perceived strength across levels.
- Closed-fold text: icon, title, and hidden line count instead of a bare fold marker.
- Exercise and solution note creation (`<leader>me`, `<leader>ms`) with track and concept prompts.
- Markdown and Obsidian image embeds render in floats using the editor background.
- Markdown reading profile: line numbers, cursorline, and fold settings follow editor globals.
- Markdown-oxide LSP and HTML/CSS language tooling.
- Rust language tooling and taskwarrior-backed task capture.
- Vault commands, journal, concept, evidence, and review note templates.
- CI: formatting, unit, and integration checks.

### Changed
- Markdown folds stay open by default (`foldlevel=99`); fold on demand only.
- Heading markers restored alongside the bands.
- README rewritten in a direct, concise style.

### Fixed
- LSP name typo (`masson.lua` → markdown-oxide).
- Automatic linting disabled to reduce editor noise.
- Diagnostic squiggles silenced by default.
- JSON trailing commas removed from tooling config.

## 0.1.0

First stable release with language tooling and better syntax highlighting distinction.