local utils = require("timetrap_nvim.utils")
local configs = require("timetrap_nvim.config")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local cur_win = nil
local cur_popup = nil

local M = {}

-- Display the "t display" output in a buffer
M.timetrap_display_open = function (opts)
    opts = opts or {}

    local buf = opts.buf
    local win_type = opts.win_type or configs.display.win_type

    local isRefresh = buf ~= nil
    if isRefresh == false and cur_win ~= nil then
        buf = vim.api.nvim_win_get_buf(cur_win)
        isRefresh = true
    end
    if isRefresh == false and cur_popup ~= nil then
        buf = cur_popup.bufnr
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



    if isRefresh == false then
        if win_type == "float" then
            local w = math.floor(vim.o.columns * 0.8)
            local h = math.floor(vim.o.lines * 0.8)

            local popup = Popup({
                position = "50%",
                size = {
                    width = w,
                    height = h,
                },
                enter = true,
                border = {
                    padding = {
                        left = 1,
                        right = 1,
                    },
                    style = configs.display.border
                },
                win_options = {
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                },
                zindex = 25,
                bufnr = buf
            })

            popup:mount()

            -- unmount component when cursor leaves buffer
            popup:on(event.WinClosed, function()
                M.timetrap_display_close()
            end)

            cur_popup = popup

        elseif win_type == "horizontal" then
            vim.api.nvim_command("split")
            win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, buf)
            cur_win = win

        elseif win_type == "vertical" then
            vim.api.nvim_command("split")
            win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, buf)
            cur_win = win
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    if isRefresh == false then
        M.set_timetrap_display_keymaps(buf)
    end
end

-- Close the timetrap display window
M.timetrap_display_close = function ()
    if cur_popup ~= nil then
        cur_popup:unmount()
        cur_popup = nil
        return
    end

    if cur_win ~= nil then
        vim.api.nvim_win_close(cur_win)
        cur_win = nil
    end
end


-- Add keymaps to the display buffer
M.set_timetrap_display_keymaps = function (buf)
    -- Delete the record
    vim.api.nvim_buf_set_keymap(buf, "n", "d", "", {
        callback = function ()
            print(vim.pretty_print(utils.parseRecordLine(buf, vim.api.nvim_win_get_cursor(0))))
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

                    M.timetrap_display_open({buf = buf})
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
            if cur_popup ~= nil then
                cur_popup:unmount()
            else
                vim.api.nvim_win_close(0, false)
            end
        end,
        noremap = true
    })

    -- Refresh the window
    vim.api.nvim_buf_set_keymap(buf, "n", "r", "", {
        callback = function ()
            M.timetrap_display_open({buf = buf})
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

                    M.timetrap_display_open({buf = buf})
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

                    M.timetrap_display_open({buf = buf})
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

                    M.timetrap_display_open({buf = buf})
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
