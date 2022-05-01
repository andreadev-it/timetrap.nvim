local utils = require("timetrap_nvim.utils")
local display = require("timetrap_nvim.display")
local configs = require("timetrap_nvim.config")

local M = {}

local timetrap_exec = function (str)
    local output = vim.api.nvim_exec("!t " .. str, true)
    local out_lines = utils.splitLines(output)

    table.remove(out_lines,1)
    if #out_lines > 1 then
        table.concat(out_lines, "\n")
    else
        output = out_lines[1]
    end
    print(output)
end


local add_commands = function ()

    -- Add timetrap commands
    vim.api.nvim_create_user_command(
        "Timetrap",
        function (opts)
            if opts.fargs[1] == "d" then
                display.timetrap_display({ win_type = configs.display.win_type })
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
end

M.setup = function (opts)

    configs.display.win_type = opts.display.win_type or configs.display.win_type

    add_commands()
end

return M
