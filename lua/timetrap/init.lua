local utils = require("timetrap.utils")
local display = require("timetrap.display")


local M = {}

local timetrap_exec = function (str)
    local output = vim.api.nvim_exec("!t " .. str, true)
    print(output)
end

M.timetrap_display = function (buf)
    local isRefresh = buf ~= nil
    local output = vim.api.nvim_exec("!t d --ids", true)

    local lines = {}
    for s in output:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    table.remove(lines, 1)

    if isRefresh == false then
        buf = vim.api.nvim_create_buf(true, true)
    else
        vim.api.nvim_buf_set_option(buf, "modifiable", true)
    end
    local win = nil


    local w = math.floor(vim.o.columns * 0.8)
    local h = math.floor(vim.o.lines * 0.8)

    local c = ( vim.o.columns - (vim.o.columns * 0.8) ) / 2
    local r = ( vim.o.lines - (vim.o.lines * 0.8) ) / 2

    if isRefresh == false then
        if M.options.display == "float" then
            win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = w,
                height = h,
                row = r,
                col = c,
                border = "rounded"
            })

        elseif M.options.display == "horizontal" then
            vim.api.nvim_command("split")
            win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, buf)

        elseif M.options.display == "vertical" then
            vim.api.nvim_command("split")
            win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, buf)
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    if isRefresh == false then
        display.set_timetrap_display_keymaps(buf, function ()
            -- Refresh function
            M.timetrap_display(buf)
        end)
    end
end

local add_commands = function ()
    
    -- Add timetrap commands
    vim.api.nvim_create_user_command(
        "Timetrap",
        function (opts)
            -- vim.pretty_print(opts.args)
            -- vim.pretty_print(opts.fargs)

            if opts.fargs[1] == "d" then
                M.timetrap_display()
                return
            end

            timetrap_exec(opts.args)
        end,
        {
            nargs = "*"
        }
    )
end

M.setup = function (opts)
    M.options = {
        display = opts.display or "horizontal"
    }
    add_commands()
end

return M
