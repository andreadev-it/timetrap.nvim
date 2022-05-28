local utils = require("timetrap_nvim.utils")
local configs = require("timetrap_nvim.config")
local common_cmd = require("timetrap_nvim.commands.common")

local cur_win = nil

local M = {}

M.timetrap_list_write = function (buf)
    local output = vim.api.nvim_exec("!t list", true)

    local lines = utils.split_lines(output)
    table.remove(lines, 1)

    if #lines <= 1 then
        lines = {
            "No timesheets found."
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
        "a - Add a new timesheet",
        "",
        "d - Delete a timesheet",
        "",
        "?  - Show this help"
    }

    common_cmd.show_help_window(lines)
end

M.timetrap_list_open = function (opts)

    local is_refresh = true
    if cur_win == nil then
        is_refresh = false
        cur_win = common_cmd.create_command_window(opts)
    end

    local buf = cur_win.bufnr

    M.timetrap_list_write(buf)

    if is_refresh == false then
        M.set_timetrap_list_keymaps(buf)
    end
end

-- Close the timetrap display window
M.timetrap_list_close = function ()
    if cur_win ~= nil then
        cur_win:unmount()
        cur_win = nil
    end
end

local _keymap_activate_sheet = function (buf)
    local sheet = utils.parse_sheet_line(buf, vim.api.nvim_win_get_cursor(0))
    if sheet == nil then
        return
    end

    local output = vim.api.nvim_exec("!t sheet " .. sheet.name, true)
    print(output)
    M.timetrap_list_open()
end

local _keymap_add_timesheet = function ()
    utils.prompt("Insert new timesheet name:", configs.prompts,
        function (value)
            local output = vim.api.nvim_exec("!t sheet " .. value, true)
            print(output)
            M.timetrap_list_open()
        end
    )
end

local _keymap_delete_timesheet = function (buf)
    local sheet = utils.parse_sheet_line(buf, vim.api.nvim_win_get_cursor(0))
    utils.prompt("Are you sure you want to delete '".. sheet.name .."'? [y/n]", configs.prompts,
        function (value)
            if value == "y" or value == "Y" then
                local output = vim.api.nvim_exec("!t kill " .. sheet.name .. " -y", true)
                print(output)
                M.timetrap_list_open()
            end
        end,
        function ()
            print("Aborting.")
        end
    )
end

-- Add keymaps to the display buffer
M.set_timetrap_list_keymaps = function (buf)
    -- Switch to a different timesheet
    vim.api.nvim_buf_set_keymap(buf, "n", "<cr>", "", {
        callback = function ()
            _keymap_activate_sheet(buf)
        end,
        noremap = true
    })
    -- Add a new timesheet
    vim.api.nvim_buf_set_keymap(buf, "n", "a", "", {
        callback = function ()
            _keymap_add_timesheet()
        end,
        noremap = true
    })

    -- Delete the entry
    vim.api.nvim_buf_set_keymap(buf, "n", "d", "", {
        callback = function ()
            _keymap_delete_timesheet(buf)
        end,
        noremap = true
    })

    -- Close the window
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        callback = function ()
            M.timetrap_list_close()
        end,
        noremap = true
    })

    -- Refresh the window
    vim.api.nvim_buf_set_keymap(buf, "n", "r", "", {
        callback = function ()
            M.timetrap_list_open()
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
