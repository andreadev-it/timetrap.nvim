local utils = require("timetrap.utils")


local M = {}

M.set_timetrap_display_keymaps = function (buf, refresh_window)
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

                    refresh_window()
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

                    refresh_window()
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

                    refresh_window()
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

                    refresh_window()
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
