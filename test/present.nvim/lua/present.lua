local M = {}

---@class present.Slide
---@field title string
---@field body string[]
---@field blocks present.Block[]

---@class present.Block
---@field lang string
---@field body string

local state = {
    title = "",
    slides = {},
    index = 1,
    windows = {}
}


local capture_print_output = function(cb)
    local output = {}
    local original_print = print

    print = function(...)
        local args = { ... }
        local message = table.concat(vim.tbl_map(tostring, args), "\t")
        table.insert(output, message)
    end

    cb(output)

    print = original_print

    return output
end


---@param block present.Block
local execute_lua_code = function(block)
    local output = capture_print_output(function(out)
        if block.lang ~= "lua" then
            return
        end

        local code = loadstring(block.body, "code to execute")
        if code == nil then
            table.insert(out, "<<<BROKEN CODE>>>")
        else
            pcall(code)
        end
    end)

    return output
end

local create_interpreter_executor = function(program)
    return function(block)
        local temp = vim.fn.tempname()
        vim.fn.writefile(vim.split(block.body, "\n"), temp)
        local result = vim.system({ program, temp }, { text = true }):wait()
        vim.fn.delete(temp)
        return vim.split(result.stdout, "\n")
    end
end

local options = {
    exec = {
        lua = execute_lua_code,
        js = create_interpreter_executor("node"),
        python = create_interpreter_executor("python3"),
    }
}

local setup = function(opts)
    opts = opts or {}
    opts.exec = opts.exec or {}

    for name, func in ipairs(opts.exec) do
        options.exec[name] = func
    end
end

---@param lines string[]
---@return present.Slide[]
local parse_slides = function(lines)
    local slides = {}
    local current_slide = {
        title = "",
        body = {},
        blocks = {},
    }

    local separator = "^#"

    for _, line in ipairs(lines) do
        if line:find(separator) then
            if #current_slide.title > 0 then
                table.insert(slides, current_slide)
            end

            current_slide = {
                title = line,
                body = {},
                blocks = {},
            }
        else
            table.insert(current_slide.body, line)
        end
    end

    table.insert(slides, current_slide)

    for _, slide in ipairs(slides) do
        local block = {}
        local inside = false
        for _, line in ipairs(slide.body) do
            if vim.startswith(line, "```") then
                inside = not inside

                if inside then
                    block = {
                        lang = vim.trim(string.sub(line, 4)),
                        body = ""
                    }
                else
                    block.body = vim.trim(block.body)
                    table.insert(slide.blocks, block)
                end
            elseif inside then
                block.body = block.body .. line .. "\n"
            end
        end
    end

    return slides
end

local foreach_windows = function(cb)
    for name, win in pairs(state.windows) do
        cb(name, win)
    end
end

local create_keymap = function(mode, key, cb)
    vim.keymap.set(mode, key, cb, { buffer = state.windows.body.buf })
end

local function create_floating_window(config, enter)
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, enter or false, config)
    return { buf = buf, win = win }
end

local create_window_configurations = function()
    local width = vim.o.columns
    local height = vim.o.lines

    local header_height = 1 + 2
    local footer_height = 1
    local body_height = height - header_height - footer_height - 3

    return {
        background = {
            relative = "editor",
            width = width,
            height = height,
            style = "minimal",
            col = 0,
            row = 0,
            zindex = 1,
        },
        header = {
            relative = "editor",
            width = width,
            height = 1,
            style = "minimal",
            border = "rounded",
            col = 0,
            row = 0,
            zindex = 2,
        },
        body = {
            relative = "editor",
            width = width - 8,
            height = body_height,
            style = "minimal",
            border = { " ", " ", " ", " ", " ", " ", " ", " ", },
            col = 8,
            row = 4,
            zindex = 2,
        },
        footer = {
            relative = "editor",
            width = width,
            height = 1,
            style = "minimal",
            col = 0,
            row = height - 1,
            zindex = 2,
        }
    }
end

local start_presentation = function(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0

    state.slides = parse_slides(vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false))
    state.index = 1
    state.title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(opts.bufnr), ":t")

    local windows_config = create_window_configurations()
    state.windows.background = create_floating_window(windows_config.background)
    state.windows.header = create_floating_window(windows_config.header)
    state.windows.body = create_floating_window(windows_config.body, true)
    state.windows.footer = create_floating_window(windows_config.footer)

    foreach_windows(function(_, win)
        vim.bo[win.buf].filetype = "markdown"
    end)


    ---@param idx integer
    local set_slide_content = function(idx)
        local slide = state.slides[idx]
        local padding = string.rep(" ", (vim.o.columns - #slide.title) / 2)
        local title = padding .. slide.title
        local footer = string.format(
            " %d / %d | %s",
            state.index,
            #state.slides,
            state.title
        )

        vim.api.nvim_buf_set_lines(state.windows.header.buf, 0, -1, false, { title })
        vim.api.nvim_buf_set_lines(state.windows.body.buf, 0, -1, false, slide.body)
        vim.api.nvim_buf_set_lines(state.windows.footer.buf, 0, -1, false, { footer })
    end

    local presets = {
        cmdheight = {
            original = vim.o.cmdheight,
            present = 0
        },
    }

    ---@param preset "present" | "original"
    local set_options = function(preset)
        for option, config in pairs(presets) do
            vim.opt[option] = config[preset]
        end
    end

    create_keymap("n", "n", function()
        state.index = math.min(state.index + 1, #state.slides)
        set_slide_content(state.index)
    end)

    create_keymap("n", "p", function()
        state.index = math.max(state.index - 1, 1)
        set_slide_content(state.index)
    end)

    create_keymap("n", "q", function()
        vim.api.nvim_win_close(state.windows.body.win, true)
    end)

    create_keymap("n", "X", function()
        local result = {}

        for _, block in ipairs(state.slides[state.index].blocks) do
            vim.list_extend(result, { "# Code", "", "```" .. block.lang })
            vim.list_extend(result, vim.split(block.body, "\n"))
            vim.list_extend(result, { "```", "", "# Output", "" })

            local execute = options.exec[block.lang]

            if execute then
                vim.list_extend(result, execute(block))
            else
                table.insert(result, "Executor for language \"" .. block.lang .. "\" was not found.")
            end

            table.insert(result, "")
        end

        if #result == 0 then
            table.insert(result, "No code blocks found on current slide.")
        end

        local buf = vim.api.nvim_create_buf(false, true)
        local temp_width = math.floor(vim.o.columns * 0.8)
        local temp_height = math.floor(vim.o.lines * 0.8)

        vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            style = "minimal",
            noautocmd = true,
            width = temp_width,
            height = temp_height,
            row = math.floor((vim.o.lines - temp_height) / 2),
            col = math.floor((vim.o.columns - temp_width) / 2),
            border = "rounded",
        })

        vim.bo[buf].filetype = "markdown"
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
    end)

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = state.windows.body.buf,
        callback = function()
            set_options("original")
            foreach_windows(function(_, win)
                pcall(vim.api.nvim_win_close, win.win, true)
            end)
        end,
    })

    vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("present-resized", {}),
        callback = function()
            if vim.api.nvim_win_is_valid(state.windows.body.win) and state.windows.body.win ~= nil then
                local config = create_window_configurations()
                foreach_windows(function(name, win)
                    vim.api.nvim_win_set_config(win.win, config[name])
                end)
                set_slide_content(state.index)
            end
        end
    })

    set_options("present")
    set_slide_content(state.index)
end

-- start_presentation({ bufnr = 5 })

M.setup = setup
M.start_presentation = start_presentation
M.create_interpreter_executor = create_interpreter_executor
M._parse_slides = parse_slides

return M
