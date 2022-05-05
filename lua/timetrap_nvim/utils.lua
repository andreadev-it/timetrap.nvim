local Input = require("nui.input")
local event = require("nui.utils.autocmd").event
local configs = require("timetrap_nvim.config")


local showInputPrompt = function (display_text, on_submit, _)
    local value = vim.fn.input(display_text .. " ")
    on_submit(value)
end


local showFloatingPrompt = function (display_text, on_submit, on_close)
    local prompt = Input({
        position = "50%",
        size = {
            width = 60,
            height = 2,
        },
        relative = "editor",
        border = {
            style = configs.display.border,
            text = {
                top = display_text,
                top_align = "center"
            }
        },
        win_options = {
            winhighlight = "Normal:Normal"
        },
    }, {
        prompt = "> ",
        on_submit = on_submit,
        on_close = on_close,
    })

    prompt:mount()

    -- close the input window by pressing `<Esc>` on normal mode
    prompt:map("n", "<Esc>", prompt.input_props.on_close, { noremap = true })

    prompt:on(event.BufLeave, function ()
        prompt:unmount()
    end)
end

local splitLines = function (str)
    local lines = {}
    for s in str:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

    return lines
end

-- Parse a line that corresponds to a entry in the display table. If it is not a entry, return nil
local parseRecordLine = function (buf, cursor)
    -- Get info positions in buffer (headers are in the second line)
    local headers_str = vim.api.nvim_buf_get_lines(buf, 1, 2, false)
    headers_str = headers_str[1]

    local r, _ = unpack(cursor)
    r = r - 1

    local cur_line = vim.api.nvim_buf_get_lines(buf, r, r+1, false)
    cur_line = cur_line[1]

    local first_char = cur_line:sub(1,1)
    -- If the first character of the string is a space, it is not a entry
    if first_char == " " then
        return
    end

    -- And neither is a entry if the first character is not a number
    if tonumber(first_char, 10) == nil then
        return
    end

    -- Get the index at which I should split the line (extracted from the headers)
    local was_space = false
    local headers_split = {}
    for i=1, #headers_str do
        local c = headers_str:sub(i, i)
        if c ~= " " then
            if was_space then
                table.insert(headers_split, i-1)
                was_space = false
            end
        else
            was_space = true
        end
    end

    -- Split the line and return the info as a table
    local headers = {}
    local from = 0
    for i=1, #headers_split do
        local h = headers_str:sub(from, headers_split[i])
        h = h:match("^%s*(.-)%s*$")
        table.insert(headers, h)
        from = headers_split[i]
    end
    local last_h = headers_str:sub(from, -1)
    last_h = last_h:match("^%s*(.-)%s*$")
    table.insert(headers, last_h)

    local values = {}
    from = 0
    for i=1, #headers_split do
        local v = cur_line:sub(from, headers_split[i])
        v = v:match("^%s*(.-)%s*$")
        table.insert(values, v)
        from = headers_split[i]
    end
    local last_v = cur_line:sub(from, -1)
    last_v = last_v:match("^%s*(.-)%s*$")
    table.insert(values, last_v)

    local parsed = {}
    for i=1, #headers do
        parsed[headers[i]] = values[i]
    end
    -- Fix Start time (remove " -")
    parsed.Start = parsed.Start:sub(0, -3)

    return parsed
end

-- Module exports
local M = {}

M.prompt = function (display_text, type, on_submit, on_close)
    if type == "input" then
        return showInputPrompt(display_text, on_submit, on_close)
    end
    if type == "float" then
        return showFloatingPrompt(display_text, on_submit, on_close)
    end
end

M.splitLines = splitLines

M.parseRecordLine = parseRecordLine

return M
