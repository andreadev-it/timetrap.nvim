local utils = require("timetrap_nvim.utils")
local configs = require("timetrap_nvim.config")

local cur_win = nil

local M = {}

-- Display the "t display" output in a buffer
M.timetrap_display = function (opts)
    opts = opts or {}

    local buf = opts.buf
    local win_type = opts.win_type or configs.display.win_type

    local isRefresh = buf ~= nil
    if isRefresh == false and cur_win ~= nil then
        buf = vim.api.nvim_win_get_buf(cur_win)
        isRefresh = true
    end

    local output = vim.api.nvim_exec("!t d --ids", true)

    local lines = utils.splitLines(output)
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
        if win_type == "float" then
            win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = w,
                height = h,
                row = r,
                col = c,
                border = "rounded",
                zindex = 25
            })

        elseif win_type == "horizontal" then
            vim.api.nvim_command("split")
            win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, buf)

        elseif win_type == "vertical" then
            vim.api.nvim_command("split")
            win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, buf)
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    if isRefresh == false then
        M.set_timetrap_display_keymaps(buf)
    end
end

-- Add keymaps to the display buffer
M.set_timetrap_display_keymaps = function (buf)
    -- Delete the record
    vim.api.nvim_buf_set_keymap(buf, "n", "d", "", {
        callback = function ()
            local r,_ = unpack(vim.api.nvim_win_get_cursor(0))
            r = r - 1 -- Cursor row is indexed from 1, while nvim_buf_get_lines requires 0

            local line = vim.api.nvim_buf_get_lines(buf, r, r+1, false)[1]

            if line:sub(1,1) == " " then
                return
            end

            local id = line:match("%d+")

            utils.prompt("Deleting item with id " .. id .. ". Are you sure? (y/n)", "float",
                function (choice)
                    if choice == "n" then
                        return
                    end

                    if choice ~= "y" then
                        print("Only 'y' and 'n' answers are accepted.")
                        return
                    end

                    local output = vim.api.nvim_exec("!t kill -y --id " .. id, true)

                    M.timetrap_display({buf = buf})
                end,
                function ()
                    print("Aborted.")
                end
            )

        end,
        noremap = true
    })

    -- Close the window
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        callback = function ()
            vim.api.nvim_win_close(0, false)
        end,
        noremap = true
    })

    -- Refresh the window
    vim.api.nvim_buf_set_keymap(buf, "n", "r", "", {
        callback = function ()
            M.timetrap_display({buf = buf})
        end,
        noremap = true
    })

    -- Change starting time
    vim.api.nvim_buf_set_keymap(buf, "n", "cs", "", {
        callback = function ()
            local r,_ = unpack(vim.api.nvim_win_get_cursor(0))
            r = r - 1 -- Cursor row is indexed from 1, while nvim_buf_get_lines requires 0

            local line = vim.api.nvim_buf_get_lines(buf, r, r+1, false)[1]

            if line:sub(1,1) == " " then
                return
            end

            local id = line:match("%d+")

            utils.prompt("Insert new starting time for item #"..id, "float",
                function (value)

                    local output = vim.api.nvim_exec('!t edit --id ' .. id .. ' -s "'.. value .. '"', true)
                    print(output)

                    M.timetrap_display({buf = buf})
                end,
                function ()
                    print("Aborted.")
                end
            )

        end,
        noremap = true
    })

    -- Change ending time
    vim.api.nvim_buf_set_keymap(buf, "n", "ce", "", {
        callback = function ()
            local r,_ = unpack(vim.api.nvim_win_get_cursor(0))
            r = r - 1 -- Cursor row is indexed from 1, while nvim_buf_get_lines requires 0

            local line = vim.api.nvim_buf_get_lines(buf, r, r+1, false)[1]

            if line:sub(1,1) == " " then
                return
            end

            local id = line:match("%d+")

            utils.prompt("Insert new ending time for item #"..id, "float",
                function (value)

                    local output = vim.api.nvim_exec('!t edit --id ' .. id .. ' -e "'.. value .. '"', true)
                    print(output)

                    M.timetrap_display({buf = buf})
                end,
                function ()
                    print("Aborted.")
                end
            )

        end,
        noremap = true
    })

    -- Change note
    vim.api.nvim_buf_set_keymap(buf, "n", "cn", "", {
        callback = function ()
            local r,_ = unpack(vim.api.nvim_win_get_cursor(0))
            r = r - 1 -- Cursor row is indexed from 1, while nvim_buf_get_lines requires 0

            local line = vim.api.nvim_buf_get_lines(buf, r, r+1, false)[1]

            if line:sub(1,1) == " " then
                return
            end

            local id = line:match("%d+")

            utils.prompt("Insert new note for item #"..id, "float",
                function (value)

                    local output = vim.api.nvim_exec('!t edit --id ' .. id .. ' '.. value , true)
                    print(output)

                    M.timetrap_display({buf = buf})
                end,
                function ()
                    print("Aborted.")
                end
            )

        end,
        noremap = true
    })
end

return M
