local utils = require("timetrap_nvim.utils")
local configs = require("timetrap_nvim.config")
local Popup = require("nui.popup")
local Split = require("nui.split")
local event = require("nui.utils.autocmd").event

local cur_win = nil

local M = {}

-- Write the command output inside the buffer
M.timetrap_display_write = function (buf)
    local output = vim.api.nvim_exec("!t d --ids", true)

    local lines = utils.splitLines(output)
    table.remove(lines, 1)

    vim.api.nvim_buf_set_option(buf, "modifiable", true)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

M.display_help = function ()

    local lines = {
        "============== KEYBINDINGS =============",
        "",
        "cs - Change Start time for record ",
        "",
        "ce - Change End time for record",
        "",
        "cn - Change Notes for record",
        "",
        "d  - Delete the record",
        "",
        "q  - Quit the window",
        "",
        "?  - Show this help"
    }

    local w = 40
    local h = 15

    local help_window = Popup({
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
    })

    help_window:mount()

    local buf = help_window.bufnr

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    help_window:on(event.BufLeave, function ()
        help_window:unmount()
    end)
end

-- Display the "t display" output in a buffer
M.timetrap_display_open = function (opts)
    opts = opts or {}

    local win_type = opts.win_type or configs.display.win_type

    local isRefresh = cur_win ~= nil

    if isRefresh == false then

        local window = nil

        if win_type == "float" then
            local w = math.floor(vim.o.columns * 0.8)
            local h = math.floor(vim.o.lines * 0.8)

            window = Popup({
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
            })

        elseif win_type == "horizontal" then
            window = Split({
                relative = "editor",
                position = "top",
                size = "40%",
            })

        elseif win_type == "vertical" then
            window = Split({
                relative = "editor",
                position = "right",
                size = "25%",
            })
        end


        window:mount()

        -- unmount component when cursor leaves buffer
        window:on(event.WinClosed, function()
            M.timetrap_display_close()
        end)

        cur_win = window
    end

    local buf = cur_win.bufnr

    M.timetrap_display_write(buf)

    if isRefresh == false then
        M.set_timetrap_display_keymaps(buf)
    end
end

-- Close the timetrap display window
M.timetrap_display_close = function ()
    if cur_win ~= nil then
        cur_win:unmount()
        cur_win = nil
    end
end


-- Add keymaps to the display buffer
M.set_timetrap_display_keymaps = function (buf)
    -- Delete the record
    vim.api.nvim_buf_set_keymap(buf, "n", "d", "", {
        callback = function ()
            local record = utils.parseRecordLine(buf, vim.api.nvim_win_get_cursor(0))

            if record == nil then
                return
            end

            local id = record.Id

            utils.prompt("Deleting item with id " .. id .. ". Are you sure? (y/n)", configs.prompts,
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
            M.timetrap_display_close()
        end,
        noremap = true
    })

    -- Refresh the window
    vim.api.nvim_buf_set_keymap(buf, "n", "r", "", {
        callback = function ()
            M.timetrap_display_open()
        end,
        noremap = true
    })

    -- Change starting time
    vim.api.nvim_buf_set_keymap(buf, "n", "cs", "", {
        callback = function ()
            local record = utils.parseRecordLine(buf, vim.api.nvim_win_get_cursor(0))

            if record == nil then
                return
            end

            local id = record.Id

            utils.prompt("Insert new starting time for item #"..id..":", configs.prompts,
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
            local record = utils.parseRecordLine(buf, vim.api.nvim_win_get_cursor(0))

            if record == nil then
                return
            end

            local id = record.Id

            utils.prompt("Insert new ending time for item #"..id..":", configs.prompts,
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
            local record = utils.parseRecordLine(buf, vim.api.nvim_win_get_cursor(0))

            if record == nil then
                return
            end

            local id = record.Id

            utils.prompt("Insert new note for item #"..id..":", configs.prompts,
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

    vim.api.nvim_buf_set_keymap(buf, "n", "?", "", {
        callback = function ()
            M.display_help()
        end,
        noremap = true
    })
end

return M
