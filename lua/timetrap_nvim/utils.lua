local Input = require("nui.input")
local event = require("nui.utils.autocmd").event


local showInputPrompt = function (display_text, on_submit, _)
    local value = vim.fn.input(display_text)
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
            style = "rounded",
            text = {
                top = display_text,
                top_align = "center"
            }
        },
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal"
        },
    }, {
        prompt = "> ",
        on_submit = on_submit,
        on_close = on_close,
    })

    prompt:mount()

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

local parseRecordLine = function (buf, cursor)
    -- Get info positions in buffer (headers are in the second line)
    local headers = vim.api.nvim_buf_get_lines(buf, 1, 2, false)

    local r, _ = unpack(cursor)
    local cur_line = vim.api.nvim_buf_get_lines(buf, r, r+1, false)

    local first_char = cur_line:sub(1,1)
    -- If the first character of the string is a space, it is not a record
    if first_char == " " then
        return
    end

    -- And neither is a record if the first character is not a number
    if tonumber(first_char, 10) == nil then
        return
    end

    -- Get the index at which I should split the line (extracted from the headers)
    local was_space = false
    local headers_split = {}
    for i=1, #headers do
        local c = headers:sub(i, i)
        if c ~= " " then
            if was_space then
                table.insert(headers_split, i)
                was_space = false
            end
        else
            was_space = true
        end
    end

    -- Split the line and return the info as a table



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
