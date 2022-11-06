local utils = require("timetrap_nvim.utils")
local display = require("timetrap_nvim.commands.display")
local list = require("timetrap_nvim.commands.list")
local configs = require("timetrap_nvim.config")

local M = {}

local timetrap_exec = function (str)
    local output = vim.api.nvim_exec("!t " .. str, true)
    local out_lines = utils.split_lines(output)

    table.remove(out_lines,1)
    if #out_lines > 1 then
        table.concat(out_lines, "\n")
    else
        output = out_lines[1]
    end
    utils.print_silently(output)
end


local add_commands = function ()

    -- Add timetrap commands
    vim.api.nvim_create_user_command(
        "Timetrap",
        function (opts)
            if opts.fargs[1] == "d" then
                display.timetrap_display_open({ win_type = configs.display.win_type })
                return
            end

            timetrap_exec(opts.args)
        end,
        {
            nargs = "*",
            complete = function ()
                return {"d", "in", "out", "list"}
            end
        }
    )

    vim.api.nvim_create_user_command(
        "TimetrapClose",
        function ()
            display.timetrap_display_close()
            list.timetrap_list_close()
        end,
        {}
    )

    vim.api.nvim_create_user_command(
        "TimetrapDisplay",
        function ()
            display.timetrap_display_open()
        end,
        {}
    )

    vim.api.nvim_create_user_command(
        "TimetrapList",
        function ()
            list.timetrap_list_open()
        end,
        {}
    )
end

M.setup = function (opts)

    if opts.display == nil then
        opts.display = {}
    end
    configs.display.win_type = opts.display.win_type or configs.display.win_type
    configs.display.border = opts.display.border or configs.display.border
    configs.prompts = opts.prompts or configs.prompts

    add_commands()
end

return M
