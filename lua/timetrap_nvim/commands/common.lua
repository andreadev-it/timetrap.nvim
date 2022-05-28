local configs = require("timetrap_nvim.config")
local Popup = require("nui.popup")
local Split = require("nui.split")
local event = require("nui.utils.autocmd").event

local M = {}

M.show_help_window = function (help_lines)
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

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)

    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        callback = function ()
            help_window:unmount()
        end,
        noremap = true
    })

    help_window:on(event.BufLeave, function ()
        help_window:unmount()
    end)
end

-- Create a window based on the user settings
M.create_command_window = function (opts)

    opts = opts or {}

    local win_type = opts.win_type or configs.display.win_type

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
        if window ~= nil then
            window:unmount()
            window = nil
        end
    end)

    return window
end


return M
