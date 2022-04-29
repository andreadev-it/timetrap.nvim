local timetrap_exec = function (str)
    local output = vim.api.nvim_exec("!t " .. str, true)
    print(output)
end


local add_commands = function ()
    
    -- Add timetrap commands
    vim.api.nvim_create_user_command(
        "Timetrap",
        function (opts)
            vim.pretty_print(opts.args)
            vim.pretty_print(opts.fargs)

            timetrap_exec(opts.args)
        end,
        {
            nargs = "*"
        }
    )
end

local M = {}

M.setup = function (opts)
    add_commands()
end

return M
