local M = {}

local function vault_root()
    local env = vim.env.NOTES_VAULT
    if env and env ~= "" then
        return vim.fs.normalize(vim.fn.expand(env))
    end
    return vim.fs.normalize(vim.fn.expand("~/Documents/Notes"))
end

local root = vault_root()
local script = root .. "/90-tools/notes.py"

M.root = root

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO)
end

local function run(args)
    if vim.fn.filereadable(script) == 0 then
        notify("notes.py not found at " .. script, vim.log.levels.ERROR)
        return nil
    end

    local cmd = { "python3", script }
    vim.list_extend(cmd, args)
    local result = vim.system(cmd, { text = true }):wait()
    if result.code ~= 0 then
        notify("notes.py: " .. vim.trim(result.stderr or "failed"), vim.log.levels.ERROR)
        return nil
    end

    local path = vim.trim(result.stdout or "")
    if path == "" then
        notify("notes.py returned no path", vim.log.levels.ERROR)
        return nil
    end
    return path
end

local function open(path)
    if not path then
        return
    end
    vim.cmd.edit(vim.fn.fnameescape(path))
end

local function create(args)
    open(run(args))
end

local function ask_title(prompt, callback)
    vim.ui.input({ prompt = prompt }, function(input)
        if input == nil then
            return
        end
        local title = vim.trim(input)
        if title ~= "" then
            callback(title)
        end
    end)
end

local function tracks()
    local found = {}
    local ok, iter = pcall(vim.fs.dir, root .. "/02-notes")
    if not ok then
        return found
    end
    for name, kind in iter do
        if kind == "directory" and not name:match("^%.") then
            found[#found + 1] = name
        end
    end
    table.sort(found)
    return found
end

local function new_concept()
    local available = tracks()
    if #available == 0 then
        notify("No tracks found under 02-notes/", vim.log.levels.WARN)
        return
    end

    vim.ui.select(available, { prompt = "Concept track" }, function(track)
        if not track then
            return
        end
        ask_title("Concept title: ", function(title)
            create({ "concept", "--track", track, title })
        end)
    end)
end

local function new_exercise()
    local available = tracks()
    if #available == 0 then
        notify("No tracks found under 02-notes/", vim.log.levels.WARN)
        return
    end

    vim.ui.select(available, { prompt = "Exercise track" }, function(track)
        if not track then
            return
        end
        vim.ui.input({ prompt = "Concept: " }, function(concept)
            if concept and vim.trim(concept) ~= "" then
                create({ "exercise", "--track", track, "--concept", vim.trim(concept) })
            end
        end)
    end)
end

local function new_solution()
    local available = tracks()
    if #available == 0 then
        notify("No tracks found under 02-notes/", vim.log.levels.WARN)
        return
    end

    vim.ui.select(available, { prompt = "Solution track" }, function(track)
        if not track then
            return
        end
        vim.ui.input({ prompt = "Problem slug: " }, function(problem)
            if problem and vim.trim(problem) ~= "" then
                create({ "solution", "--track", track, "--problem", vim.trim(problem) })
            end
        end)
    end)
end

local function new_note(kind)
    if kind == "concept" then
        new_concept()
    elseif kind == "exercise" then
        new_exercise()
    elseif kind == "solution" then
        new_solution()
    elseif kind == "project" then
        ask_title("Project title: ", function(title)
            create({ "project", title })
        end)
    elseif kind == "evidence" or kind == "review" then
        ask_title(kind:sub(1, 1):upper() .. kind:sub(2) .. " title: ", function(title)
            create({ kind, title })
        end)
    else
        notify("Unknown note type: " .. tostring(kind), vim.log.levels.ERROR)
    end
end

local types = { "concept", "exercise", "solution", "project", "evidence", "review" }

local function project_note(path)
    local repo = path and vim.trim(path) or ""
    if repo == "" then
        repo = vim.fn.getcwd()
    else
        repo = vim.fn.expand(repo)
    end
    create({ "project", "--repo", repo })
end

local function open_in_obsidian()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        notify("Current buffer has no file", vim.log.levels.WARN)
        return
    end

    local absolute = vim.fs.normalize(vim.fn.fnamemodify(file, ":p"))
    local prefix = root .. "/"
    if absolute:sub(1, #prefix) ~= prefix then
        notify("Current note is outside " .. root, vim.log.levels.WARN)
        return
    end

    local relative = absolute:sub(#prefix + 1)
    local uri = "obsidian://open?vault=Notes&file=" .. vim.uri_encode(relative)
    vim.ui.open(uri)
end



local function terminal(cmd)
    local ok = pcall(function()
        Snacks.terminal.open(cmd, {
            auto_close = false,
            win = {
                position = "bottom",
                wo = {
                    winhighlight = "Normal:Normal,NormalNC:Normal",
                },
            },
        })
    end)

    if not ok then
        vim.cmd("terminal " .. table.concat(
            vim.tbl_map(vim.fn.shellescape, cmd),
            " "
        ))
    end
end

-- local function terminal(cmd)
--     local ok = pcall(function()
--         Snacks.terminal.open(cmd, { win = { position = "bottom" } })
--     end)
--     if not ok then
--         vim.cmd("terminal " .. table.concat(vim.tbl_map(vim.fn.shellescape, cmd), " "))
--     end
-- end

local function vcheck()
    terminal({ "python3", root .. "/90-tools/check-vault.py" })
end

local function task_capture()
    local function submit(value)
        if value == nil then
            return
        end
        local text = vim.trim(value)
        if text == "" then
            return
        end
        local result = vim.system({ "task", "add", text }, { text = true }):wait()
        if result.code ~= 0 then
            notify("task add: " .. vim.trim(result.stderr or "failed"), vim.log.levels.ERROR)
        else
            notify("Task captured")
        end
    end

    local opts = { prompt = "Task: " }
    if type(Snacks) == "table" and Snacks.input then
        Snacks.input(opts, submit)
    else
        vim.ui.input(opts, submit)
    end
end

local function task_next()
    terminal({ "task", "next" })
end

local function command(name, callback, opts)
    opts = opts or {}
    opts.force = true
    vim.api.nvim_create_user_command(name, callback, opts)
end

command("Note", function(opts)
    local title = vim.trim(opts.args)
    if title ~= "" then
        create({ "capture", title })
        return
    end
    ask_title("Note title: ", function(input)
        create({ "capture", input })
    end)
end, { nargs = "*", desc = "Capture a note in 00-inbox" })

command("Journal", function()
    create({ "daily" })
end, { desc = "Open today's journal note" })

command("Weekly", function()
    create({ "weekly" })
end, { desc = "Open this week's journal note" })

command("New", function(opts)
    local kind = vim.trim(opts.args)
    if kind == "" then
        vim.ui.select(types, { prompt = "Note type" }, function(choice)
            if choice then
                new_note(choice)
            end
        end)
        return
    end
    if not vim.tbl_contains(types, kind) then
        notify("Unknown note type: " .. kind, vim.log.levels.ERROR)
        return
    end
    new_note(kind)
end, {
    nargs = "?",
    desc = "Create a concept, project, evidence or review note",
    complete = function()
        return types
    end,
})

command("Inbox", function()
    Snacks.picker.files({ cwd = root .. "/00-inbox" })
end, { desc = "Find a note in 00-inbox" })

command("Find", function()
    Snacks.picker.files({ cwd = root })
end, { desc = "Find a note in the vault" })

command("Grep", function()
    Snacks.picker.grep({ cwd = root })
end, { desc = "Search the vault" })

command("Backlinks", function()
    local ok = pcall(vim.lsp.buf.references)
    if not ok then
        notify("No LSP client supports references in this buffer", vim.log.levels.WARN)
    end
end, { desc = "List backlinks for the current note" })

command("ProjectNote", function(opts)
    project_note(opts.args)
end, {
    nargs = "?",
    desc = "Create or open a project note",
    complete = "dir",
})

command("Obsidian", open_in_obsidian, { desc = "Open the current note in Obsidian" })
command("VCheck", vcheck, { desc = "Run the vault link and lab check" })

local map = vim.keymap.set
local function set(key, rhs, desc)
    map("n", key, rhs, { desc = desc, silent = true })
end

set("<leader>mn", "<cmd>Note<cr>", "New note")
set("<leader>mj", "<cmd>Journal<cr>", "Journal")
set("<leader>mw", "<cmd>Weekly<cr>", "Weekly review")
set("<leader>mi", "<cmd>Inbox<cr>", "Inbox picker")
set("<leader>mf", "<cmd>Find<cr>", "Find note")
set("<leader>mg", "<cmd>Grep<cr>", "Search notes")
set("<leader>mb", "<cmd>Backlinks<cr>", "Backlinks")
set("<leader>mt", "<cmd>New<cr>", "New note by type")
set("<leader>mp", "<cmd>ProjectNote<cr>", "Project note")
set("<leader>mo", "<cmd>Obsidian<cr>", "Open in Obsidian")
set("<leader>mv", "<cmd>VCheck<cr>", "Check vault")
set("<leader>mT", task_capture, "Capture task")
set("<leader>mN", task_next, "Next tasks")

set("<leader>mr", function()
    local ok = pcall(vim.cmd, "RenderMarkdown toggle")
    if not ok then
        notify("render-markdown is not available in this buffer", vim.log.levels.WARN)
    end
end, "Toggle rendered markdown")

pcall(function()
    LazyVim.on_load("which-key.nvim", function()
        require("which-key").add({ { "<leader>m", group = "notes" } })
    end)
end)

return M
