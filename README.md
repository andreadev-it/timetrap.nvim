# Timetrap integration for neovim

**This plugin is currently in alpha version, keep that in mind!**

This plugin is meant to be a simple integration for the [timetrap timetracker](https://github.com/samg/timetrap).
Most of the commands are currently just passed to it, but it includes improvements on the "t display" command, since it 
will allow you to edit your time sheets using vim-like keybindings. It also prevents the other commands output to block
the workflow with the annoying "Press ENTER or command" prompt.

## Prerequisites

* neovim v. 0.7+
* timetrap available on the system (using the shorthand `t [command]`)

## Installation

### Using Packer.nvim
Paste the following code along with your other plugins in the "packer.startup" function:
```
use {
    "andreadev-it/timetrap.nvim",
    requires = {
        "MunifTanjim/nui.nvim"
    },
    config = function ()
        require("timetrap_nvim").setup({})
    end
}
```
## Usage

You can use all classic timetrap commands by running:
```:Timetrap [command]```

The useful part comes when you're launching the display command:
```:Timetrap d```

This will show the output in a buffer. You can change the entries by hovering
on the desired entry and pressing one of the following key combinations (while in normal mode):

* `cs` - Change Start time
* `ce` - Change End time
* `cn` - Change Note (the entry description)
* `d` - Delete the entry
* `q` - Quit the timetrap buffer

## Configuration

Here it is a list of options that can be passed to the "setup" function:
* `display.win_type` - The type of window that should be launched when you type `:Timetrap d`. Available options: horizontal, vertical, float.
* `display.border` - The border to be used for the floating windows. Options: single, rounded, double, none, solid, shadow.
* `prompts` - What kind of prompts should be used to get user input. Options: input (classic vim input) or float.

Example configuration:
```
require("timetrap_nvim").setup({
    display = {
        win_type = "float",
        border = "rounded",
    },
    prompts = "float"
})
```
