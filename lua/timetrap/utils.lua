local Input = require("nui.input")
local event = require("nui.utils.autocmd").event


local showInputPrompt = function (display_text, on_submit, _)
    local value = vim.fn.input(display_text)
    on_submit(value)
end


local showFloatingPrompt = function (display_text, on_submit, on_close)
    local prompt = Input({
        position = "50%",
        size = {
            width = 60,
            height = 2,
        },
        relative = "editor",
        border = {
            style = "rounded",
            text = {
                top = display_text,
                top_align = "center"
            }
        },
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal"
        },
    }, {
        prompt = "> ",
        on_submit = on_submit,
        on_close = on_close,
    })

    prompt:mount()

    prompt:on(event.BufLeave, function ()
        prompt:unmount()
    end)
end

local M = {}

M.prompt = function (display_text, type, on_submit, on_close)
    if type == "input" then
        return showInputPrompt(display_text, on_submit, on_close)
    end
    if type == "float" then
        return showFloatingPrompt(display_text, on_submit, on_close)
    end
end

return M
