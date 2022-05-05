# Timetrap integration for neovim

**This plugin is currently in alpha version, keep that in mind!**

This plugin is meant to be a simple integration for the [timetrap timetracker](https://github.com/samg/timetrap).
Most of the commands are currently just passed to it, but it includes improvements on the "t display" command, since it 
will allow you to edit your time sheets using vim-like keybindings.

## Installation

### Using Packer.nvim
```

use {
    "/home/andrea/Projects/timetrap.nvim",
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

This will show the output in a buffer. You can change the records by hovering
on the desired record and pressing one of the following key combinations (while in normal mode):

* `cs` - Change Start time
* `ce` - Change End time
* `cn` - Change Note (the record description)
* `d` - Delete the record
* `q` - Quit the timetrap buffer
