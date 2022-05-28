local utils = require("timetrap_nvim.utils")
local configs = require("timetrap_nvim.config")
local common_cmd = require("timetrap_nvim.commands.common")

local cur_win = nil

local M = {}

-- Write the command output inside the buffer
M.timetrap_display_write = function (buf)
    local output = vim.api.nvim_exec("!t d --ids", true)

    local lines = utils.split_lines(output)
    table.remove(lines, 1)

    if #lines <= 1 then
        lines = {
            "No entries found in the current sheet."
        }
    end

    vim.api.nvim_buf_set_option(buf, "modifiable", true)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

M.show_help = function ()

    local lines = {
        "============== KEYBINDINGS =============",
        "",
        "cs - Change Start time for entry ",
        "",
        "ce - Change End time for entry",
        "",
        "cn - Change Notes for entry",
        "",
        "d  - Delete the entry",
        "",
        "q  - Quit the window",
        "",
        "?  - Show this help"
    }

    common_cmd.show_help_window(lines)
end

-- Display the "t display" output in a buffer
M.timetrap_display_open = function (opts)
    local is_refresh = true
    if cur_win == nil then
        is_refresh = false
        cur_win = common_cmd.create_command_window(opts)
    end

    local buf = cur_win.bufnr

    M.timetrap_display_write(buf)

    if is_refresh == false then
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

-- Delete entry keymap
local _keymap_delete_entry = function (buf)
    local entry = utils.parse_record_line(buf, vim.api.nvim_win_get_cursor(0))

    if entry == nil then
        return
    end

    local id = entry.Id

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
end

-- Change Start Time keymap
local _keymap_change_start_time = function (buf)
    local entry = utils.parse_record_line(buf, vim.api.nvim_win_get_cursor(0))

    if entry == nil then
        return
    end

    local id = entry.Id

    utils.prompt("Insert new starting time for item #"..id..":", configs.prompts,
        function (value)

            local output = vim.api.nvim_exec('!t edit --id ' .. id .. ' -s "'.. value .. '"', true)
            print(output)

            M.timetrap_display_open()
        end,
        function ()
            print("Aborted.")
        end
    )
end

-- Change End Time keymap
local _keymap_change_end_time = function (buf)
    local entry = utils.parse_record_line(buf, vim.api.nvim_win_get_cursor(0))

    if entry == nil then
        return
    end

    local id = entry.Id

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
end

-- Change a entry note keymap
local _keymap_change_note = function (buf)
    local entry = utils.parse_record_line(buf, vim.api.nvim_win_get_cursor(0))

    if entry == nil then
        return
    end

    local id = entry.Id

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

end


-- Add keymaps to the display buffer
M.set_timetrap_display_keymaps = function (buf)
    -- Delete the entry
    vim.api.nvim_buf_set_keymap(buf, "n", "d", "", {
        callback = function ()
            _keymap_delete_entry(buf)
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
            _keymap_change_start_time(buf)
        end,
        noremap = true
    })

    -- Change ending time
    vim.api.nvim_buf_set_keymap(buf, "n", "ce", "", {
        callback = function ()
            _keymap_change_end_time(buf)
        end,
        noremap = true
    })

    -- Change note
    vim.api.nvim_buf_set_keymap(buf, "n", "cn", "", {
        callback = function ()
            _keymap_change_note(buf)
        end,
        noremap = true
    })

    vim.api.nvim_buf_set_keymap(buf, "n", "?", "", {
        callback = function ()
            M.show_help()
        end,
        noremap = true
    })
end

return M
