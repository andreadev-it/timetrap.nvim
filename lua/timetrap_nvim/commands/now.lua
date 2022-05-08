local utils = require("timetrap_nvim.utils")

local M = {}

M.get_current_task = function ()
    local output = vim.api.nvim_exec("!t now")
    local lines = utils.split_lines(output)

    local task = nil
    local line = nil
    for _, line = ipairs(lines) do
        if string.sub(line, 1, 1) == "*" then
            task = line
            break
        end
    end

    local sheet = task:match("*(.*):%s")
    local elapsed = task:match(":%s([:%d]+)%s")
    local note = task:match("%((.*)%)")

    return {
        sheet = sheet,
        elapsed = elapsed,
        note = note,
    }
end

return M
