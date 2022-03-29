NeoVim Configuration
--------------------

Author: Peter Lee (peter.lee@finclab.com)
Last Update: 2022-Mar

The setup of NeoVim is based on (LunarVim) plus customized LUA/Vimscripts. Customization heavily takes place for Python IDE coding, alongside with support for Markdown and LUA.

# To-dos

- TODO: Set up keybindings for vim-table-mode

# Key-bindings


## Combined keys

| Mode   | Keys          | Description             | Plugin        | CMD                 |
|--------|---------------|-------------------------|---------------|---------------------|
| normal | <A-h/j/k/l>   | Window navigation       | TmuxNavigator |                     |
| normal | <A-S-h/j/k/l> | Window resize           | TmuxNavigator |                     |
| normal | <S-l/h>       | Switch buffer           | BufferLine    | BufferLineCycleNext |
| normal | <C-j/k>       | Move line/block up/down |               |                     |
| normal | <C-q>         | Toggle `QuickFix`       |               |                     |



## Sequential Keys
| Leader | 1 | 2 | Description       | Plugin    | CMD                                                              |
|--------|---|---|-------------------|-----------|------------------------------------------------------------------|
| SPC    | f |   | Files             |           |                                                                  |
| SPC    | f | f | Find File         | Telescope | require("lvim.core.telescope.custom-finders").find_project_files |
| SPC    | f | r | Recent File       | Telescope | Telescope oldfiles                                               |
| SPC    | f | s | Search Text       | Telescope | Telescope live_grep                                              |
| SPC    | f | p | Project           | Telescope | Telescope projects                                               |
|--------|---|---|-------------------|-----------|------------------------------------------------------------------|
| SPC    | u |   | Update            |           |                                                                  |
| SPC    | u | i | Install           | Packer    | PackerInstall                                                    |
| SPC    | u | c | Compile           | Packer    | PackerCompile                                                    |
| SPC    | u | s | Sync              | Packer    | PackerSync                                                       |
| SPC    | u | u | Update            | Packer    | PackerUpdate                                                     |
| SPC    | u | l | List Plugins      | Packer    | PackerStatus                                                     |
| SPC    | u | x | Delete Unused     | Packer    | PackerClean                                                      |
| SPC    | u | r | Re-Compile        | Packer    | require('lvim.plugin-loader').recompile()                        |
|--------|---|---|-------------------|-----------|------------------------------------------------------------------|
| SPC    | s |   | Search            |           |                                                                  |
| SPC    | s | a | Search            | Spectre   | require('spectre').open()                                        |
| SPC    | s | b | Search Word       | Spectre   | require('spectre').open_visual({select_word=true})               |
| SPC    | s | c | Search Git Branch | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | f | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |
| SPC    | s | s | Search            | Telescope | require('spectre').open_visual({select_word=true})               |


## Special Keys

| Mode   | Key 1 | Key 2 | Description   | Plugin | CMD   |
|--------|-------|-------|---------------|--------|-------|
| Normal | ]     | q     | Next QuickFix |        | cnext |
| Normal | [     | q     | Prev QuickFix |        | cprev |
