-- Vtsls formatting settings follow options.lua:
-- tabstop=4, shiftwidth=4, softtabstop=4, expandtab=true (4 spaces).
-- conform.nvim + prettier is the primary JS/TS formatter, but when it falls
-- back to LSP formatting (lsp_format="fallback"), vtsls must also emit 4 spaces.
-- Language extras (C/C++, Python, Tailwind, JSON, YAML, Docker, SQL, ESLint)
-- add their own servers via lazyvim.json; the entries below cover what
-- LazyVim has no extra for, plus Yoru overrides of extra-provided servers.
local function gtk_css_path(path)
    return path ~= nil and (path:find("/waybar/", 1, true) ~= nil or path:find("/swaync/", 1, true) ~= nil)
end

local function gtk_css_uri(uri)
    if not uri or not uri:match("^file:") then
        return false
    end
    local path = vim.uri_to_fname(uri)
    return gtk_css_path(path) or gtk_css_path(vim.uv.fs_realpath(path))
end

local function css_configuration(err, params, ctx, config)
    local response = vim.lsp.handlers["workspace/configuration"](err, params, ctx, config)
    if not response then
        return
    end
    -- cssls requests settings per document. Do not disable validation for its
    -- entire workspace: GTK and web CSS can share the same dotfiles client.
    for i, item in ipairs(params.items or {}) do
        if item.section == "css" and gtk_css_uri(item.scopeUri) then
            response[i] = vim.tbl_extend("force", {}, type(response[i]) == "table" and response[i] or {}, {
                validate = false,
            })
        end
    end
    return response
end

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            -- Quiet editing; signs, floats, diagnostic lists and counts remain.
            diagnostics = {
                underline = false,
                virtual_text = false,
                virtual_lines = false,
                severity = { min = vim.diagnostic.severity.WARN },
            },
            -- Inline parameter/return hints are noise in every language; hover
            -- (<K>/Ctrl-k) still shows signatures when wanted.
            inlay_hints = {
                enabled = false,
            },
            servers = {
                vtsls = {
                    settings = {
                        typescript = {
                            format = {
                                indentSize = 4,
                                tabSize = 4,
                                convertTabsToSpaces = true,
                            },
                        },
                        javascript = {
                            format = {
                                indentSize = 4,
                                tabSize = 4,
                                convertTabsToSpaces = true,
                            },
                        },
                    },
                },
                -- ESLint tooling is installed in mason.lua; its policy is unchanged
                -- here. Prettier remains the primary JS/TS formatter.
                -- Web markup/styling: no LazyVim extra covers these servers.
                html = {},
                cssls = {
                    -- GTK colors (@blue, alpha(...)) are not web CSS. Suppress
                    -- this validator only below waybar/ and swaync/ directories,
                    -- including symlink targets; completion and hover stay on.
                    handlers = {
                        ["workspace/configuration"] = css_configuration,
                    },
                },
                -- lang.json enables jsonls formatting on top of its validation.
                -- Conform's prettier_json is the only JSON formatter, so keep
                -- jsonls for schemas + validation only.
                jsonls = {
                    settings = {
                        json = {
                            format = {
                                enable = false,
                            },
                        },
                    },
                },
                -- Bash: no LazyVim extra covers it. bashls brings hover,
                -- completion and definition; ShellCheck remains the manual
                -- linter so its rules are never reported twice.
                bashls = {},
                -- lang.python enables the Ruff LSP by default; Yoru keeps Pylint
                -- as the single Python linter so diagnostics are not doubled.
                ruff = { enabled = false },
            },
        },
    },
}
