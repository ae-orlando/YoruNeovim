-- Run from any directory: nvim --headless -u NONE -i NONE -n -l /path/to/tests/run.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
local passed, failed = 0, 0
local cleanups = {}

local function replace(tbl, key, value)
    local previous = tbl[key]
    tbl[key] = value
    cleanups[#cleanups + 1] = function()
        tbl[key] = previous
    end
end

local function eq(expected, actual)
    assert(vim.deep_equal(expected, actual), "expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
end

local function test(name, callback)
    vim.api.nvim_clear_autocmds({})
    cleanups = {}
    local ok, err = xpcall(callback, debug.traceback)
    for i = #cleanups, 1, -1 do
        cleanups[i]()
    end
    if ok then
        passed = passed + 1
        print("PASS " .. name)
    else
        failed = failed + 1
        print("FAIL " .. name .. "\n" .. err)
    end
end

local function specs(name)
    return dofile(root .. "/lua/plugins/" .. name .. ".lua")
end

local function find(entries, name)
    for _, entry in ipairs(entries) do
        if entry[1] == name then
            return entry
        end
    end
    error("missing plugin spec: " .. name)
end

local function palette()
    return {
        bg = "#111111",
        fg = "#eeeeee",
        fg_alt = "#dddddd",
        base0 = "#101010",
        base1 = "#222222",
        base2 = "#333333",
        base3 = "#444444",
        base5 = "#666666",
        accent = "#aabbcc",
        muted = "#999999",
        warning = "#ffbb00",
        error = "#ff0000",
    }
end

local function mock_matugen()
    local state = { palette = palette() }
    replace(package.loaded, "matugen", {
        get_palette = function()
            return state.palette
        end,
        lualine = function()
            return { normal = { c = { fg = state.palette.fg_alt, bg = state.palette.base1 } } }
        end,
    })
    return state
end

local syntax_groups = {
    fn = { "Function", "@function", "@function.call", "@function.method", "@function.method.call" },
    builtin = { "@function.builtin" },
    type = { "Type", "Structure", "Typedef", "@type", "@type.builtin", "@type.definition", "@constructor" },
    const = { "Constant", "Boolean", "@constant", "@constant.builtin", "@constant.macro", "@boolean" },
    str = { "String", "Character", "@string", "@character" },
    num = { "Number", "Float", "@number", "@number.float" },
    prop = { "@property", "@variable.member", "@tag.attribute" },
}

local syntax_links = {
    ["@lsp.type.class"] = "@type",
    ["@lsp.type.enum"] = "@type",
    ["@lsp.type.enumMember"] = "@constant",
    ["@lsp.type.function"] = "@function",
    ["@lsp.type.interface"] = "@type",
    ["@lsp.type.method"] = "@function.method",
    ["@lsp.type.property"] = "@property",
    ["@lsp.type.struct"] = "@type",
    ["@lsp.type.type"] = "@type",
    ["@lsp.type.typeParameter"] = "@type",
}

local protected_highlights = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "CursorLine",
    "CursorLineNr",
    "WinSeparator",
    "StatusLine",
    "TabLine",
    "Pmenu",
    "PmenuSel",
    "SnacksPicker",
    "NeoTreeNormal",
    "DiagnosticError",
    "DiagnosticWarn",
    "DiagnosticInfo",
    "DiagnosticHint",
    "Keyword",
    "@keyword",
    "@variable",
    "@variable.builtin",
    "@variable.parameter",
    "Comment",
    "@comment",
    "@punctuation.bracket",
    "@markup.heading.2",
    "@tag",
}

local function mock_syntax()
    local state = mock_matugen()
    state.inputs, state.colors, state.requests = {}, {}, {}
    local sources, hues = {}, {}
    for i, role in ipairs({ "fn", "builtin", "type", "const", "str", "num", "prop" }) do
        local source = string.format("#%02x2233", i * 16)
        state.palette[role] = source
        state.inputs[role] = { L = 0.8, C = 0.03, h = i * 30 }
        state.colors[role] = string.format("#%02x4455", i * 16)
        sources[source], hues[i * 30] = role, role
    end
    state.palette.method = state.palette.prop
    package.loaded.matugen.color = function()
        return {
            hex_to_oklch = function(hex)
                return vim.deepcopy(state.inputs[sources[hex]])
            end,
            oklch = function(L, C, h)
                local role = hues[h]
                state.requests[role] = { L = L, C = C, h = h }
                return state.colors[role]
            end,
        }
    end
    return state
end

local function seed_syntax(pal)
    local original = {}
    for role, names in pairs(syntax_groups) do
        for _, name in ipairs(names) do
            local fg = name:find("@function.method", 1, true) and pal.method or pal[role]
            vim.api.nvim_set_hl(0, name, {
                fg = fg,
                bg = "#112233",
                sp = "#778899",
                bold = true,
                italic = true,
                underline = true,
                ctermfg = 12,
                ctermbg = 4,
            })
            original[name] = vim.api.nvim_get_hl(0, { name = name, link = false })
        end
    end
    return original
end

local function reload()
    -- Matugen's watcher calls its loader directly: hi clear wipes colors_name,
    -- then User MatugenReloaded fires without a subsequent ColorScheme event.
    vim.cmd("highlight clear")
    vim.api.nvim_exec_autocmds("User", { pattern = "MatugenReloaded", modeline = false })
end

test("all configuration files compile", function()
    local files = vim.fn.globpath(root, "lua/**/*.lua", false, true)
    files[#files + 1] = root .. "/init.lua"
    for _, file in ipairs(files) do
        assert(loadfile(file))
    end
end)

test("initial colorscheme preserves the transparency boundary", function()
    specs("colorscheme")
    local transparent = { "Normal", "NormalNC", "SignColumn", "FoldColumn", "EndOfBuffer", "MsgArea" }
    local panels = { "NormalFloat", "FloatBorder", "NeoTreeNormal", "SnacksPickerNormal" }
    local original = { fg = "#abcdef", bg = "#123456", ctermfg = 12, ctermbg = 4, bold = true, italic = true }
    local panel_highlights = {}
    for _, name in ipairs(transparent) do
        vim.api.nvim_set_hl(0, name, original)
    end
    for _, name in ipairs(panels) do
        vim.api.nvim_set_hl(0, name, original)
        panel_highlights[name] = vim.api.nvim_get_hl(0, { name = name, link = false })
    end
    local expected = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    expected.bg, expected.ctermbg = nil, nil
    vim.g.colors_name = nil
    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "matugen", modeline = false })
    eq("matugen", vim.g.colors_name)
    for _, name in ipairs(transparent) do
        eq(expected, vim.api.nvim_get_hl(0, { name = name, link = false }))
    end
    for _, name in ipairs(panels) do
        eq(panel_highlights[name], vim.api.nvim_get_hl(0, { name = name, link = false }))
    end
end)

test("watcher reload restores the theme and preserves complete UI configurations", function()
    local state = mock_matugen()
    specs("colorscheme")
    local callback = function() end
    local lualine = {
        options = { theme = "auto", globalstatus = true },
        sections = { lualine_c = { callback } },
        extensions = { "neo-tree", "lazy" },
    }
    local bufferline = {
        options = {
            separator_style = "slant",
            indicator = { style = "underline" },
            diagnostics = "nvim_lsp",
            offsets = { { filetype = "neo-tree" } },
            close_command = callback,
            always_show_bufferline = false,
        },
        highlights = { custom = { fg = "#abcdef" }, fill = { bold = true } },
    }
    local original_lualine, original_bufferline = vim.deepcopy(lualine), vim.deepcopy(bufferline)
    local calls = { lualine = 0, bufferline = 0 }
    replace(package.loaded, "lualine", {
        get_config = function()
            return vim.deepcopy(lualine)
        end,
        setup = function(opts)
            calls.lualine = calls.lualine + 1
            lualine = vim.deepcopy(opts)
        end,
    })
    replace(package.loaded, "bufferline.config", {
        get = function()
            return { user = bufferline }
        end,
        update_highlights = function()
            return bufferline
        end,
    })
    replace(package.loaded, "bufferline", {
        setup = function()
            error("a highlight refresh must not rerun Bufferline setup")
        end,
    })
    replace(package.loaded, "bufferline.highlights", {
        reset_icon_hl_cache = function() end,
        set_all = function(opts)
            calls.bufferline = calls.bufferline + 1
            bufferline = vim.deepcopy(opts)
        end,
    })
    for i = 1, 3 do
        state.palette.fg = string.format("#eeee%02x", i)
        state.palette.base0 = string.format("#1010%02x", i)
        reload()
        eq("matugen", vim.g.colors_name)
        eq(i, calls.lualine)
        eq(i, calls.bufferline)
        eq(state.palette.fg, lualine.options.theme.normal.c.fg)
        eq(original_lualine.sections, lualine.sections)
        eq(original_lualine.extensions, lualine.extensions)
        eq(true, lualine.options.globalstatus)
        eq(original_bufferline.options, bufferline.options)
        eq(original_bufferline.highlights.custom, bufferline.highlights.custom)
        eq(true, bufferline.highlights.fill.bold)
        eq(state.palette.base0, bufferline.highlights.fill.bg)
        eq(nil, vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg)
    end
end)

test("early reload does not force-load UI plugins and late setup uses the live palette", function()
    local state = mock_matugen()
    local loads = 0
    for _, name in ipairs({ "lualine", "bufferline" }) do
        replace(package.loaded, name, nil)
        replace(package.preload, name, function()
            loads = loads + 1
            error("unexpected eager UI load")
        end)
    end
    local entries = specs("colorscheme")
    reload()
    eq(0, loads)
    local lualine = { options = {} }
    find(entries, "nvim-lualine/lualine.nvim").opts({}, lualine)
    eq(state.palette.fg, lualine.options.theme.normal.c.fg)
    local bufferline = { options = {}, highlights = { fill = { bold = true } } }
    find(entries, "akinsho/bufferline.nvim").opts({}, bufferline)
    eq(state.palette.base0, bufferline.highlights.fill.bg)
    eq(true, bufferline.highlights.fill.bold)
    eq("slant", bufferline.options.separator_style)
    eq({ style = "underline" }, bufferline.options.indicator)
end)

test("reloading the spec does not duplicate theme handlers", function()
    specs("colorscheme")
    specs("colorscheme")
    eq(1, #vim.api.nvim_get_autocmds({ event = "ColorScheme", pattern = "matugen" }))
    eq(1, #vim.api.nvim_get_autocmds({ event = "User", pattern = "MatugenReloaded" }))
end)

test("missing palette keeps the transparent Catppuccin fallback", function()
    replace(vim.fn, "filereadable", function()
        return 0
    end)
    local entries = specs("colorscheme")
    local opts = {}
    find(entries, "LazyVim/LazyVim").opts({}, opts)
    eq("catppuccin", opts.colorscheme)
    eq(false, find(entries, "daedlock/matugen.nvim").cond)
    eq(true, find(entries, "catppuccin/nvim").opts.transparent_background)
end)

test("syntax changes only selected foregrounds and preserves semantic links", function()
    local state = mock_syntax()
    replace(vim.g, "colors_name", "matugen")
    local pal = vim.deepcopy(state.palette)
    local original = seed_syntax(state.palette)
    -- Resolve a linked capture's existing styles before changing its foreground.
    vim.api.nvim_set_hl(0, "@function.call", { link = "Function" })
    for name, target in pairs(syntax_links) do
        vim.api.nvim_set_hl(0, name, { link = target })
    end
    local protected = {}
    for _, name in ipairs(protected_highlights) do
        vim.api.nvim_set_hl(0, name, { fg = "#abcdef", bg = "#123456", italic = true })
        protected[name] = vim.api.nvim_get_hl(0, { name = name, link = false })
    end

    require("config.syntax").apply()
    eq(pal, state.palette)
    for role, names in pairs(syntax_groups) do
        for _, name in ipairs(names) do
            local expected = vim.deepcopy(original[name])
            expected.fg = tonumber(state.colors[role]:sub(2), 16)
            eq(expected, vim.api.nvim_get_hl(0, { name = name, link = false }))
        end
    end
    for name, expected in pairs(protected) do
        eq(expected, vim.api.nvim_get_hl(0, { name = name, link = false }))
    end
    for name, target in pairs(syntax_links) do
        eq({ link = target }, vim.api.nvim_get_hl(0, { name = name }))
        eq(
            vim.api.nvim_get_hl(0, { name = target, link = false }).fg,
            vim.api.nvim_get_hl(0, { name = name, link = false }).fg
        )
    end
end)

test("syntax chroma boosts are bounded without changing hue or lightness", function()
    local state = mock_syntax()
    replace(vim.g, "colors_name", "matugen")
    state.inputs.fn.C = 0.05 -- The function boost must stop at its cap.
    state.inputs.type.C = 0.12 -- Do not desaturate stronger user overrides.
    state.inputs.str.C = 0 -- A neutral palette stays neutral.
    seed_syntax(state.palette)
    require("config.syntax").apply()
    eq(0.075, state.requests.fn.C)
    eq(nil, state.requests.type) -- No round trip for colors that should stay unchanged.
    eq(nil, state.requests.str)
    eq(tonumber(state.palette.type:sub(2), 16), vim.api.nvim_get_hl(0, { name = "Type" }).fg)
    eq(tonumber(state.palette.str:sub(2), 16), vim.api.nvim_get_hl(0, { name = "String" }).fg)
    assert(math.abs(state.requests.num.C - 0.0495) < 1e-10)
    assert(math.abs(state.requests.prop.C - 0.036) < 1e-10)
    for role, input in pairs(state.inputs) do
        if state.requests[role] then
            eq(input.L, state.requests[role].L)
            eq(input.h, state.requests[role].h)
        end
    end
end)

test("syntax follows the live palette on initial load and repeat reloads", function()
    local state = mock_syntax()
    replace(vim.g, "colors_name", nil)
    specs("colorscheme")
    seed_syntax(state.palette)
    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "matugen", modeline = false })
    eq(tonumber(state.colors.fn:sub(2), 16), vim.api.nvim_get_hl(0, { name = "Function" }).fg)

    state.palette.fn = state.palette.type -- Simulate a new wallpaper's function tint.
    local pal = vim.deepcopy(state.palette)
    for _ = 1, 3 do
        vim.cmd("highlight clear")
        seed_syntax(state.palette)
        vim.g.colors_name = nil
        vim.api.nvim_exec_autocmds("User", { pattern = "MatugenReloaded", modeline = false })
        eq("matugen", vim.g.colors_name)
        eq(tonumber(state.colors.type:sub(2), 16), vim.api.nvim_get_hl(0, { name = "Function" }).fg)
        eq(tonumber(state.colors.type:sub(2), 16), vim.api.nvim_get_hl(0, { name = "@function.method" }).fg)
        eq(tonumber(state.colors.prop:sub(2), 16), vim.api.nvim_get_hl(0, { name = "@property" }).fg)
        local highlights = vim.api.nvim_get_hl(0, {})
        require("config.syntax").apply()
        eq(highlights, vim.api.nvim_get_hl(0, {}))
        eq(pal, state.palette)
    end
end)

test("syntax leaves fallback and unavailable Matugen state untouched", function()
    local syntax = require("config.syntax")
    replace(vim.g, "colors_name", "catppuccin")
    replace(package.loaded, "matugen", nil)
    replace(package.preload, "matugen", function()
        error("syntax must not force-load Matugen")
    end)
    local original = vim.api.nvim_get_hl(0, {})
    syntax.apply()
    eq(original, vim.api.nvim_get_hl(0, {}))
    vim.g.colors_name = "matugen"
    syntax.apply()
    eq(original, vim.api.nvim_get_hl(0, {}))
    replace(package.loaded, "matugen", {
        get_palette = function() end,
        color = function()
            error("no color derivation without a palette")
        end,
    })
    syntax.apply()
    eq(original, vim.api.nvim_get_hl(0, {}))
end)

test("cursor-line number retains its original tint independently of syntax", function()
    local state = mock_syntax()
    replace(vim.g, "colors_name", "matugen")
    specs("colorscheme")
    seed_syntax(state.palette)
    require("config.syntax").apply()
    dofile(root .. "/lua/config/autocmds.lua")
    eq(tonumber(state.palette.fn:sub(2), 16), vim.api.nvim_get_hl(0, { name = "CursorLineNr" }).fg)
    eq(tonumber(state.colors.fn:sub(2), 16), vim.api.nvim_get_hl(0, { name = "Function" }).fg)
    eq(nil, vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg)

    state.palette.fn = state.palette.type
    seed_syntax(state.palette)
    vim.g.colors_name = nil
    vim.api.nvim_exec_autocmds("User", { pattern = "MatugenReloaded", modeline = false })
    eq(tonumber(state.palette.fn:sub(2), 16), vim.api.nvim_get_hl(0, { name = "CursorLineNr" }).fg)
    vim.g.colors_name = "catppuccin"
    vim.api.nvim_set_hl(0, "Function", { fg = "#fedcba" })
    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "catppuccin", modeline = false })
    eq(0xfedcba, vim.api.nvim_get_hl(0, { name = "CursorLineNr" }).fg)
end)

test("TODO settings inherit picker mappings rather than requiring Telescope", function()
    local entry = specs("todo")[1]
    for _, key in ipairs(entry.keys or {}) do
        assert(type(key[2]) ~= "string" or not key[2]:find("Telescope"), "hardcoded Telescope mapping")
    end
    assert(entry.config == nil, "TODO setup should extend LazyVim opts")
    eq("", entry.opts.keywords.TODO.icon)
    eq("wide", entry.opts.highlight.keyword)
end)

test("stopping persistence prevents automatic saving with a modified buffer", function()
    local entry = specs("session")[1]
    local saves, loads = 0, 0
    local group
    local persistence = {
        setup = function()
            group = vim.api.nvim_create_augroup("YoruPersistenceTest", { clear = true })
            vim.api.nvim_create_autocmd("VimLeavePre", {
                group = group,
                callback = function()
                    saves = saves + 1
                end,
            })
        end,
        save = function()
            saves = saves + 1
        end,
        stop = function()
            vim.api.nvim_del_augroup_by_id(group)
        end,
        load = function(opts)
            eq(nil, opts) -- Keep current project/branch semantics.
            loads = loads + 1
        end,
    }
    replace(package.loaded, "persistence", persistence)
    if entry.config then
        entry.config()
    else
        persistence.setup(entry.opts)
    end
    eq(0, loads) -- No implicit auto-restore.
    entry.keys[1][2]()
    eq(1, saves)
    entry.keys[2][2]()
    eq(1, loads)
    entry.keys[3][2]()
    replace(vim.bo, "modified", true)
    vim.api.nvim_exec_autocmds("VimLeavePre", { modeline = false })
    eq(1, saves)
    eq("Restore project session", entry.keys[2].desc)
end)

test("Colorizer leaves an existing native API intact", function()
    local original = function(value)
        return value
    end
    replace(vim, "tbl_flatten", original)
    replace(package.loaded, "colorizer", {
        setup = function(opts)
            eq(original, vim.tbl_flatten)
            eq({ "*", css = { css = true }, html = { mode = "foreground" } }, opts)
        end,
    })
    specs("visuals")[1].config()
    eq(original, vim.tbl_flatten)
end)

test("Colorizer has its fallback before setup when the API is missing", function()
    replace(vim, "tbl_flatten", nil)
    local calls = 0
    replace(package.loaded, "colorizer", {
        setup = function()
            eq({ 1, 2, 3, 4 }, vim.tbl_flatten({ 1, { 2, { 3 } }, 4 }))
            calls = calls + 1
        end,
    })
    specs("visuals")[1].config()
    eq(1, calls)
end)

test("palette parameters and existing workflow policies stay unchanged", function()
    local entries = specs("colorscheme")
    local matugen = find(entries, "daedlock/matugen.nvim").opts
    eq(0.05, matugen.contrast)
    eq(0.6, matugen.min_contrast)
    eq(8, matugen.harmonize)
    eq(false, specs("git")[1].enabled)
    eq(false, specs("noice")[1].opts.cmdline.enabled)
    eq({ "--tab-width", "4", "--use-tabs", "false" }, specs("formatting")[1].opts.formatters.prettier.prepend_args)
end)

test("fullstack language tooling is declared", function()
    local lazyvim = vim.json.decode(table.concat(vim.fn.readfile(root .. "/lazyvim.json"), "\n"))
    local required_extras = {
        "lazyvim.plugins.extras.dap.core",
        "lazyvim.plugins.extras.lang.docker",
        "lazyvim.plugins.extras.lang.json",
        "lazyvim.plugins.extras.lang.python",
        "lazyvim.plugins.extras.lang.sql",
        "lazyvim.plugins.extras.lang.tailwind",
        "lazyvim.plugins.extras.lang.typescript",
        "lazyvim.plugins.extras.lang.yaml",
        "lazyvim.plugins.extras.linting.eslint",
        "lazyvim.plugins.extras.test.core",
    }
    local seen = {}
    for _, extra in ipairs(lazyvim.extras) do
        assert(not seen[extra], "duplicate extra: " .. extra)
        seen[extra] = true
    end
    for _, extra in ipairs(required_extras) do
        assert(seen[extra], "missing lazyvim.json extra: " .. extra)
    end

    local mason = find(specs("mason"), "mason-org/mason.nvim").opts.ensure_installed
    for _, tool in ipairs({ "debugpy", "eslint-lsp", "markdownlint", "pylint", "shellcheck" }) do
        assert(vim.tbl_contains(mason, tool), "missing mason tool: " .. tool)
    end
    assert(not vim.tbl_contains(mason, "eslint_d"), "eslint_d must be replaced by ESLint LSP")

    local mdlint = vim.fn.readfile(root .. "/.markdownlint.yaml")
    assert(
        table.concat(mdlint, "\n"):find("MD013: false", 1, true) ~= nil,
        "editor markdownlint must disable MD013 like the documented check"
    )

    local lint = specs("formatting")[2]
    eq("mfussenegger/nvim-lint", lint[1])
    local by_ft = lint.opts.linters_by_ft
    eq({ "pylint" }, by_ft.python)
    eq({ "shellcheck" }, by_ft.sh)
    eq({ "markdownlint" }, by_ft.markdown)
    for _, linters in pairs(by_ft) do
        assert(not vim.tbl_contains(linters, "eslint_d"), "eslint_d still wired into nvim-lint")
    end

    local lsp = specs("lsp")[1].opts.servers
    eq({}, lsp.html)
    eq("function", type(lsp.cssls.handlers["workspace/configuration"]))
    eq(false, lsp.ruff.enabled)
    eq(4, lsp.vtsls.settings.typescript.format.indentSize)

    local neotest = specs("test")[1]
    eq(nil, neotest.config, "test setup must extend LazyVim's test.core extra")
    eq("table", type(neotest.opts.adapters["neotest-python"]))
    eq(false, neotest.opts.adapters["neotest-python"].dap.justMyCode)
    assert(neotest.opts.adapters["neotest-vitest"] ~= nil)
    assert(neotest.opts.adapters["neotest-plenary"] ~= nil)
end)

test("quiet diagnostics retain reports and on-demand access", function()
    local opts = specs("lsp")[1].opts.diagnostics
    eq({ underline = false, virtual_text = false, virtual_lines = false }, opts)
    eq(nil, opts.signs) -- Inherit LazyVim's signs and float settings.
    eq(nil, opts.float)

    local namespace = vim.api.nvim_create_namespace("YoruDiagnosticTest")
    local bufnr = vim.api.nvim_create_buf(false, true)
    cleanups[#cleanups + 1] = function()
        vim.diagnostic.reset(namespace, bufnr)
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
    vim.diagnostic.config(opts, namespace)
    vim.diagnostic.set(namespace, bufnr, {
        { lnum = 0, col = 0, message = "A real error", severity = vim.diagnostic.severity.ERROR },
    })
    eq(1, #vim.diagnostic.get(bufnr, { namespace = namespace }))
    eq(true, vim.diagnostic.is_enabled({ bufnr = bufnr, ns_id = namespace }))
end)

test("CSS validation is suppressed per GTK document without changing shared settings", function()
    local settings = {
        css = {
            validate = true,
            lint = { unknownProperties = "warning" },
            completion = { triggerPropertyValueCompletion = true },
        },
        scss = { validate = true },
    }
    local original = vim.deepcopy(settings)
    replace(vim.lsp, "get_client_by_id", function(id)
        eq(71, id)
        return { settings = settings }
    end)
    replace(vim.uv, "fs_realpath", function()
        return nil
    end)
    local handler = specs("lsp")[1].opts.servers.cssls.handlers["workspace/configuration"]
    local response = handler(nil, {
        items = {
            { section = "css", scopeUri = "file:///dotfiles/waybar/colors/style.css" },
            { section = "css", scopeUri = "file:///dotfiles/swaync/Styles/base.css" },
            { section = "css", scopeUri = "file:///dotfiles/web/style.css" },
            { section = "css", scopeUri = "file:///dotfiles/waybar-example/style.css" },
            { section = "css", scopeUri = "file:///dotfiles/myswaync/style.css" },
            { section = "css" },
            { section = "css", scopeUri = "untitled:waybar/style.css" },
            { section = "scss", scopeUri = "file:///dotfiles/waybar/style.scss" },
            { section = "css.lint", scopeUri = "file:///dotfiles/waybar/style.css" },
            { section = "missing", scopeUri = "file:///dotfiles/waybar/style.css" },
            { scopeUri = "file:///dotfiles/waybar/style.css" },
        },
    }, { client_id = 71 })
    local gtk = vim.tbl_extend("force", {}, settings.css, { validate = false })
    eq({
        gtk,
        gtk,
        settings.css,
        settings.css,
        settings.css,
        settings.css,
        settings.css,
        settings.scss,
        settings.css.lint,
        vim.NIL,
        settings,
    }, response)
    eq(original, settings)
end)

test("GTK CSS scoping follows symlinks and supplies missing CSS settings", function()
    replace(vim.lsp, "get_client_by_id", function()
        return { settings = {} }
    end)
    local symlinks = {
        ["/dotfiles/panel/theme.css"] = "/dotfiles/waybar/colors/theme.css",
        ["/home/test/.config/swaync/style.css"] = "/dotfiles/notifications/style.css",
    }
    replace(vim.uv, "fs_realpath", function(path)
        return symlinks[path]
    end)
    local handler = specs("lsp")[1].opts.servers.cssls.handlers["workspace/configuration"]
    local response = handler(nil, {
        items = {
            { section = "css", scopeUri = "file:///dotfiles/panel/theme.css" },
            { section = "css", scopeUri = "file:///home/test/.config/swaync/style.css" },
            { section = "css", scopeUri = "file:///dotfiles/web/theme.css" },
        },
    }, { client_id = 71 })
    eq({ { validate = false }, { validate = false }, vim.NIL }, response)
end)

test("SQLfluff respects project dialect and falls back to ANSI", function()
    local override = specs("formatting")[3]
    eq("stevearc/conform.nvim", override[1])
    local opts = { formatters = {} }
    override.opts({}, opts)
    local args = opts.formatters.sqlfluff.args
    eq("function", type(args))
    replace(vim.fs, "find", function()
        return { "/tmp/proj/.sqlfluff" }
    end)
    eq({ "format", "-" }, args(nil, { filename = "/tmp/proj/query.sql" }))
    replace(vim.fs, "find", function()
        return {}
    end)
    eq({ "format", "--dialect=ansi", "-" }, args(nil, { filename = "/tmp/proj/query.sql" }))
end)

-- Opt in to integration checks against an existing installation. No installs,
-- network requests, real palette changes, or session-file writes are performed.
local plugin_root = vim.env.YORU_TEST_PLUGIN_DIR
if plugin_root then
    test("integration dependencies match the lockfile", function()
        local lock = vim.json.decode(table.concat(vim.fn.readfile(root .. "/lazy-lock.json"), "\n"))
        for _, name in ipairs({
            "matugen.nvim",
            "catppuccin",
            "lualine.nvim",
            "bufferline.nvim",
            "persistence.nvim",
            "nvim-colorizer.lua",
            "LazyVim",
            "lazy.nvim",
        }) do
            local dir = plugin_root .. "/" .. name
            local result = vim.system({ "git", "-C", dir, "rev-parse", "HEAD" }, { text = true }):wait()
            assert(result.code == 0, "missing integration dependency: " .. dir)
            eq(lock[name].commit, vim.trim(result.stdout))
            vim.opt.rtp:prepend(dir)
        end
    end)

    test("integration LazyVim ships every declared extra", function()
        local lazyvim = vim.json.decode(table.concat(vim.fn.readfile(root .. "/lazyvim.json"), "\n"))
        for _, extra in ipairs(lazyvim.extras) do
            local rel = extra:gsub("%.", "/")
            local file = plugin_root .. "/LazyVim/lua/" .. rel .. ".lua"
            local init = plugin_root .. "/LazyVim/lua/" .. rel .. "/init.lua"
            assert(
                vim.fn.filereadable(file) == 1 or vim.fn.filereadable(init) == 1,
                "extra module missing from LazyVim: " .. extra
            )
        end
    end)

    test("real Matugen reloads preserve UI options, highlights, and hook counts", function()
        local entries = specs("colorscheme")
        local matugen = require("matugen")
        matugen._config = vim.tbl_deep_extend("force", matugen._config, entries[1].opts, { watch = false })
        local colors = require("matugen.palette")
        local tokens = vim.deepcopy(colors.BASELINE_MC)
        replace(colors, "read_colors", function()
            return vim.deepcopy(tokens)
        end)
        vim.cmd.colorscheme("matugen")
        dofile(root .. "/lua/config/autocmds.lua")

        local lualine = require("lualine")
        local component = function()
            return "Yoru"
        end
        local lualine_opts = {
            options = { globalstatus = true },
            sections = { lualine_c = { component } },
            extensions = { "quickfix" },
        }
        find(entries, "nvim-lualine/lualine.nvim").opts({}, lualine_opts)
        lualine.setup(lualine_opts)
        local original_lualine = lualine.get_config()

        local bufferline = require("bufferline")
        local bufferline_config = require("bufferline.config")
        local bufferline_opts = {
            options = {
                diagnostics = "nvim_lsp",
                close_command = component,
                always_show_bufferline = false,
                offsets = { { filetype = "neo-tree", text = "Neo-tree" } },
            },
            highlights = { fill = { bold = true }, error = { italic = true } },
        }
        find(entries, "akinsho/bufferline.nvim").opts({}, bufferline_opts)
        bufferline.setup(bufferline_opts)
        local original_options = vim.deepcopy(bufferline_config.options)
        local hooks = #vim.api.nvim_get_autocmds({ event = "SessionLoadPost" })

        for i = 1, 3 do
            tokens.on_surface = string.format("#eeee%02x", i)
            matugen.load()
            local pal = matugen.get_palette()
            eq("matugen", vim.g.colors_name)
            eq(pal.fg, lualine.get_config().options.theme.normal.c.fg)
            eq(original_lualine.sections, lualine.get_config().sections)
            eq(original_lualine.extensions, lualine.get_config().extensions)
            eq(original_options, bufferline_config.options)
            eq(true, bufferline_config.highlights.fill.bold)
            eq(true, bufferline_config.highlights.error.italic)
            eq(tonumber(pal.base0:sub(2), 16), vim.api.nvim_get_hl(0, { name = "BufferLineFill" }).bg)
            eq(nil, vim.api.nvim_get_hl(0, { name = "Normal" }).bg)
            assert(vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg ~= nil)
            eq(true, vim.api.nvim_get_hl(0, { name = "Comment" }).bold)
            eq(tonumber(pal.fn:sub(2), 16), vim.api.nvim_get_hl(0, { name = "CursorLineNr" }).fg)
            eq(
                vim.api.nvim_get_hl(0, { name = "Function" }).fg,
                vim.api.nvim_get_hl(0, { name = "@function.method" }).fg
            )
            eq(hooks, #vim.api.nvim_get_autocmds({ event = "SessionLoadPost" }))
        end
    end)

    test("real syntax preserves palette, UI and styles across dark and light palettes", function()
        local entries = specs("colorscheme")
        local matugen = require("matugen")
        matugen._config = vim.tbl_deep_extend("force", matugen._config, entries[1].opts, { watch = false })
        local palettes = require("matugen.palette")
        local fixtures = {
            vim.deepcopy(palettes.BASELINE_MC),
            { surface = "#0f1512", primary = "#8ad6b7", secondary = "#b3ccbf", tertiary = "#a6cce0" },
            { surface = "#111318", primary = "#8ab4f8", secondary = "#a5c9d5", tertiary = "#dab6e8" },
            { surface = "#f7f2fa", primary = "#6750a4", secondary = "#625b71", tertiary = "#7d5260" },
        }
        local current = palettes.read_colors(entries[1].opts.colors_path)
        if current then
            fixtures[#fixtures + 1] = current
        end
        local tokens
        replace(palettes, "read_colors", function()
            return vim.deepcopy(tokens)
        end)
        local syntax = require("config.syntax")
        local apply = syntax.apply
        -- Capture the unmodified theme on each load, then apply the real layer.
        replace(syntax, "apply", function() end)
        dofile(root .. "/lua/config/autocmds.lua")
        local allowed = {}
        for _, names in pairs(syntax_groups) do
            for _, name in ipairs(names) do
                allowed[name] = true
            end
        end
        local color = matugen.color()
        for _, fixture in ipairs(fixtures) do
            tokens = fixture
            matugen.load()
            local pal = vim.deepcopy(matugen.get_palette())
            local raw = vim.api.nvim_get_hl(0, {})
            local styles, protected = {}, {}
            for name in pairs(allowed) do
                styles[name] = vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
            end
            for _, name in ipairs(protected_highlights) do
                protected[name] = vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
            end
            apply()
            local enhanced = vim.api.nvim_get_hl(0, {})
            eq(pal, matugen.get_palette())
            for name, hl in pairs(raw) do
                if not allowed[name] then
                    eq(hl, enhanced[name])
                end
            end
            for name in pairs(enhanced) do
                assert(raw[name], "syntax created an unrelated highlight: " .. name)
            end
            for name, hl in pairs(protected) do
                eq(hl, vim.api.nvim_get_hl(0, { name = name, link = false, create = false }))
            end
            for role, names in pairs(syntax_groups) do
                local source = color.hex_to_oklch(pal[role])
                for _, name in ipairs(names) do
                    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
                    local expected = vim.deepcopy(styles[name])
                    expected.fg = hl.fg
                    eq(expected, hl) -- No bold/italic/background changes.
                    local result = color.hex_to_oklch(string.format("#%06x", hl.fg))
                    assert(math.abs(source.L - result.L) < 0.005, "syntax changed lightness: " .. name)
                    assert(result.C >= source.C - 0.003, "syntax reduced chroma: " .. name)
                    if source.C > 0.01 then
                        -- Matugen's conversion and 8-bit rounding have a small
                        -- hue drift; keep it within the original color family.
                        assert(color.hue_distance(source.h, result.h) < 6, "syntax changed hue: " .. name)
                    end
                end
            end
            for name, target in pairs(syntax_links) do
                eq({ link = target }, vim.api.nvim_get_hl(0, { name = name }))
                eq(
                    vim.api.nvim_get_hl(0, { name = target, link = false }).fg,
                    vim.api.nvim_get_hl(0, { name = name, link = false }).fg
                )
            end
            eq(tonumber(pal.fn:sub(2), 16), vim.api.nvim_get_hl(0, { name = "CursorLineNr" }).fg)
            apply()
            eq(enhanced, vim.api.nvim_get_hl(0, {}))
        end
    end)

    test("real Catppuccin fallback is unchanged after Matugen syntax overrides", function()
        local entries = specs("colorscheme")
        local catppuccin = require("catppuccin")
        catppuccin.setup(find(entries, "catppuccin/nvim").opts)
        dofile(root .. "/lua/config/autocmds.lua")
        vim.cmd.colorscheme("catppuccin")
        local original = vim.api.nvim_get_hl(0, {})
        require("config.syntax").apply()
        eq(original, vim.api.nvim_get_hl(0, {}))
        eq("catppuccin-mocha", vim.g.colors_name)
        eq(nil, vim.api.nvim_get_hl(0, { name = "Normal" }).bg)
        eq(vim.api.nvim_get_hl(0, { name = "Function" }).fg, vim.api.nvim_get_hl(0, { name = "CursorLineNr" }).fg)
        eq(true, vim.api.nvim_get_hl(0, { name = "Comment" }).bold)
    end)

    test("real Persistence stops automatic saving without touching session files", function()
        local persistence = require("persistence")
        replace(vim.fn, "mkdir", function()
            return 1
        end)
        local saves = 0
        replace(persistence, "save", function()
            saves = saves + 1
        end)
        local entry = specs("session")[1]
        persistence.setup(entry.opts)
        local old_name = vim.api.nvim_buf_get_name(0)
        cleanups[#cleanups + 1] = function()
            persistence.stop()
            vim.api.nvim_buf_set_name(0, old_name)
        end
        vim.api.nvim_buf_set_name(0, root .. "/tests/session-buffer.lua")
        vim.api.nvim_exec_autocmds("VimLeavePre", { modeline = false })
        eq(1, saves)
        entry.keys[3][2]()
        replace(vim.bo, "modified", true)
        vim.api.nvim_exec_autocmds("VimLeavePre", { modeline = false })
        eq(false, persistence.active())
        eq(1, saves)
    end)

    test("real Colorizer initializes with the removed API simulated", function()
        replace(vim, "tbl_flatten", nil)
        specs("visuals")[1].config()
        eq("function", type(vim.tbl_flatten))
    end)

    test("LazyVim resolves TODO search through both supported picker integrations", function()
        local pick = setmetatable({
            register = function()
                return true
            end,
            config_files = function()
                return function() end
            end,
        }, {
            __call = function()
                return function() end
            end,
        })
        replace(_G, "LazyVim", { pick = pick })
        local editor = dofile(plugin_root .. "/LazyVim/lua/lazyvim/plugins/editor.lua")
        local config = require("lazy.core.config")
        replace(config, "options", vim.deepcopy(config.defaults))
        local plugin = require("lazy.core.plugin")
        for _, backend in ipairs({ "fzf", "snacks_picker" }) do
            local picker = dofile(plugin_root .. "/LazyVim/lua/lazyvim/plugins/extras/editor/" .. backend .. ".lua")
            local resolved = plugin.Spec.new({
                find(editor, "folke/todo-comments.nvim"),
                find(picker, "folke/todo-comments.nvim"),
                specs("todo")[1],
            }, { pkg = false }).plugins["todo-comments.nvim"]
            local keys = {}
            for _, key in ipairs(plugin.values(resolved, "keys", true)) do
                keys[key[1]] = key[2]
            end
            local calls, last_opts = 0, nil
            local function todo(opts)
                calls = calls + 1
                last_opts = opts
            end
            replace(package.loaded, "todo-comments.fzf", { todo = todo })
            replace(_G, "Snacks", { picker = { todo_comments = todo } })
            keys["<leader>st"]()
            eq(nil, last_opts)
            keys["<leader>sT"]()
            eq({ keywords = { "TODO", "FIX", "FIXME" } }, last_opts)
            eq(2, calls)
            eq("", plugin.values(resolved, "opts", false).keywords.TODO.icon)
        end
    end)
end

vim.api.nvim_clear_autocmds({})
print(string.format("\n%d passed, %d failed", passed, failed))
if failed > 0 then
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
