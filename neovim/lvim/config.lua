--
-- ██╗░░░░░██╗░░░██╗███╗░░██╗░█████╗░██████╗░██╗░░░██╗██╗███╗░░░███╗
-- ██║░░░░░██║░░░██║████╗░██║██╔══██╗██╔══██╗██║░░░██║██║████╗░████║
-- ██║░░░░░██║░░░██║██╔██╗██║███████║██████╔╝╚██╗░██╔╝██║██╔████╔██║
-- ██║░░░░░██║░░░██║██║╚████║██╔══██║██╔══██╗░╚████╔╝░██║██║╚██╔╝██║
-- ███████╗╚██████╔╝██║░╚███║██║░░██║██║░░██║░░╚██╔╝░░██║██║░╚═╝░██║
-- ╚══════╝░╚═════╝░╚═╝░░╚══╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝
--
--         @mrpeterlee

--------------------==================== Plugins ====================--------------------
lvim.plugins = {

    --------------------==================== UI / Workflow ====================--------------------
    -- Consolidate all issues in a single panel
    {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup {}
        end,
    },

    -- NOTE: Learn --> Navigation plugin: Hop
    {
        "phaazon/hop.nvim",
        event = "BufRead",
        config = function()
            vim.defer_fn(function()
                require("hop").setup {
                    case_insensitive = true,
                    char2_fallback_key = "",
                    quit_key = "<Esc>",
                }
            end, 2000)
        end,
    },

    -- NOTE: Learn to use this plugin -- add to OneNote!
    { "machakann/vim-sandwich" },

    -- Repeat vim motions
    { "tpope/vim-repeat", event = "VimEnter" },

    -- vim-yoink: keep a history of yanks
    { "svermeulen/vim-yoink", event = "VimEnter" },

    -- Displaying thin vertical lines at each indentation level for code indented with spaces.
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufRead",
        setup = function()
            vim.g.indentLine_enabled = 1
            vim.g.indent_blankine_char = "▏"
            vim.g.indent_blankline_buftype_exclude = { "terminal" }
            vim.g.indent_blankline_filetype_exclude = {
                "help",
                "terminal",
                "dashboard",
                "git",
                "markdown",
                "snippets",
                "text",
                "gitconfig",
                "alpha",
            }
            vim.g.indent_blankline_show_trailing_blankline_indent = false
            vim.g.indent_blankline_show_first_indent_level = false
        end,
        -- config = function()
        -- vim.defer_fn(function()
        --     require("indent_blankline").setup({
        --         -- U+2502 may also be a good choice, it will be on the middle of cursor.
        --         -- U+250A is also a good choice
        --         char = "▏",
        --         show_end_of_line = false,
        --         disable_with_nolist = true,
        --         buftype_exclude = { "terminal" },
        --         filetype_exclude = { "help", "git", "markdown", "snippets", "text", "gitconfig", "alpha" },
        --     })
        -- end, 2000)
        -- end,
    },

    -- Search & Replace
    {
        "windwp/nvim-spectre",
        event = "BufRead",
        config = function()
            require("spectre").setup {
                mapping = {
                    ["toggle_line"] = {
                        map = "dd",
                        cmd = "lua require('spectre').toggle_line()",
                        desc = "toggle current item",
                    },
                },
            }
        end,
    },

    -- To-do integration
    {
        "folke/todo-comments.nvim",
        event = "BufRead",
        config = function()
            vim.defer_fn(function()
                require("todo-comments").setup()
            end, 2000)
        end,
    },

    -- Smoothie scrolling
    {
        "karb94/neoscroll.nvim",
        event = "VimEnter",
        config = function()
            vim.defer_fn(function()
                require("neoscroll").setup {
                    easing_function = "quadratic",
                }
            end, 2000)
        end,
    },

    -- Resume last cursor position when opening file
    {
        "ethanholz/nvim-lastplace",
        event = "BufRead",
        config = function()
            require("nvim-lastplace").setup {
                lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
                lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
                lastplace_open_folds = true,
            }
        end,
    },

    -- SmartClose: martClose plugin distinguishes two kinds of windows (the regular windows you use to work) and the auxiliary ones (a preview window, a NERDTree panel, a quickfix window, etc)
    { "szw/vim-smartclose" },

    -- Wilder - hinting when typing CMD
    {
        "gelguy/wilder.nvim",
        -- event = { "CursorHold", "CmdlineEnter" },
        -- rocks = { "luarocks-fetch-gitrec",  }, -- "pcre2" linux install: apt install pcre2-utils
        requires = { "romgrk/fzy-lua-native" },
        -- config = function()
        --   vim.cmd(string.format("source %s", "~/.config/lvim/vimscript/wilder.vim"))
        -- end,
        run = ":UpdateRemotePlugins",
    },

    --------------------==================== Git ====================--------------------

    -- NOTE: Learn this - Better git log display
    { "rbong/vim-flog", requires = "tpope/vim-fugitive", cmd = { "Flog" } },

    -- NOTE: Learn this - git conflict merge
    { "christoomey/vim-conflicted", requires = "tpope/vim-fugitive", cmd = { "Conflicted" } },

    -- Git - Display signs / number on the left bar for any git differences
    { "mhinz/vim-signify", event = "BufEnter" },

    --------------------==================== Python IDE ====================--------------------

    -- -- NOTE: To learn - Add indent object for vim (useful for languages like Python)
    -- { "michaeljsmith/vim-indent-object", event = "VimEnter" },

    -- -- Omni completion - the text before the cursor is inspected to guess what might follow
    -- { "hrsh7th/cmp-omni", after = "nvim-cmp" },

    -- Python - AutoFlake to remove unused imports
    { "tell-k/vim-autoflake" },

    -- Python indent (follows the PEP8 style)
    { "Vimjas/vim-python-pep8-indent", filetypes = { "python" } },
    -- { "sheerun/vim-polyglot" },

    -- -- NOTE: Learn this plugin -- Python motion control around class / methods
    -- { "jeetsukumaran/vim-pythonsense", ft = { "python" } },

    -- -- NOTE: Learn this plugin -- Swap parameters inside function
    -- { "machakann/vim-swap", event = "VimEnter" },

    -- -- Python - Provides code signature when adding a function
    -- {
    --     "ray-x/lsp_signature.nvim",
    --     config = function()
    --         require("config/lsp_signature").config()
    --     end,
    --     event = { "BufRead", "BufNew" },
    -- },

    --------------------==================== Tmux ====================--------------------
    -- Tmux integration
    { "christoomey/vim-tmux-navigator" },
    { "preservim/vimux" },

    -- syntax highlightnig for tmux file
    { "tmux-plugins/vim-tmux", ft = { "tmux" } },

    --------------------==================== MISC ====================--------------------

    -- Grammer Check; TODO: add hotkey to :GrammarousCheck
    { "rhysd/vim-grammarous" },

    -- use jk to ESC from insert mode faster
    { "jdhao/better-escape.vim", event = { "InsertEnter" } },

    -- Rainbow parenthesis
    {
        "p00f/nvim-ts-rainbow",
        config = function()
            vim.defer_fn(function()
                require("nvim-treesitter.configs").setup {
                    rainbow = {
                        enable = true,
                        extended_mode = true,
                    },
                }
            end, 2000)
        end,
    },

    -- Copy to system clipboard using ANSI OSC52 sequence - iTerm2/Windoes Terminal/Kitty
    { "ojroques/vim-oscyank", cmd = { "OSCYank", "OSCYankReg" } },

    -- =========== Python - Debugger ===========
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            -- require("dap-python").setup('/opt/conda/bin/python')
            require("dap-python").setup("python", {})
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        requires = { "mfussenegger/nvim-dap" },
        config = function()
            require("dapui").setup()
        end,
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        config = function()
            require("nvim-dap-virtual-text").setup()
        end,
    },
    { "nvim-telescope/telescope-dap.nvim" },

    -- =========== Lua - Debugger ===========
    { "jbyuki/one-small-step-for-vimkind", module = "osv" },

    -- =========== Markdown Table Mode ===========
    -- TODO: Learn!
    { "dhruvasagar/vim-table-mode" },

    -- Glow - view markdown in terminal
    { "ellisonleao/glow.nvim" },

    -- =========== Themes ===========
    { "lifepillar/vim-gruvbox8" },
    { "navarasu/onedark.nvim" },
    { "sainnhe/edge" },
    { "sainnhe/sonokai" },
    { "sainnhe/gruvbox-material" },
    { "shaunsingh/nord.nvim" },
    { "NTBBloodbath/doom-one.nvim" },
    { "sainnhe/everforest" },
    { "EdenEast/nightfox.nvim" },
    { "rebelot/kanagawa.nvim" },
}

-- indent line
vim.defer_fn(function()
    require "config.indent-blankline"
end, 3000)

-- Neoscrol
vim.defer_fn(function()
    require "config.neoscroll"
end, 3000)

-- List of candidates

-- Clever f search to free up key ; and ,
-- {"rhysd/clever-f.vim"},

-- Show undo history visually:: not sure why i need it
-- {"simnalamburt/vim-mundo", cmd = {"MundoToggle", "MundoShow"}},

-- Highlight URLs inside vim
-- {"itchyny/vim-highlighturl", event = "VimEnter"},

---------------------------------------- LSP - Python ----------------------------------------
-- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    { command = "stylua", filetypes = { "lua" } },
    { command = "black", filetypes = { "python" } },
    { command = "isort", filetypes = { "python" } },
    {
        -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
        command = "prettier",
        ---@usage arguments to pass to the formatter
        -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
        extra_args = { "--print-with", "100", "--no-semi", "--single-quote", "--jsx-single-quote" },
        ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
        filetypes = { "typescript", "typescriptreact" },
    },
}

-- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    { command = "pylint", filetypes = { "python" } },
    { command = "shellcheck", extra_args = { "--severity", "warning" } },
    {
        command = "codespell",
        ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
        filetypes = { "python" },
    },
}

--------------------==================== NeoVim - VimScripts ====================--------------------
-- source core vim configs
vim.cmd("source " .. vim.fn.expand "$HOME" .. "/.config/lvim/vimscript/globals.vim")
vim.cmd("source " .. vim.fn.expand "$HOME" .. "/.config/lvim/vimscript/options.vim")
vim.cmd("source " .. vim.fn.expand "$HOME" .. "/.config/lvim/vimscript/autocommands.vim")
vim.cmd("source " .. vim.fn.expand "$HOME" .. "/.config/lvim/vimscript/key-bindings.vim")
vim.cmd("source " .. vim.fn.expand "$HOME" .. "/.config/lvim/vimscript/plugins.vim")

--------------------==================== Load LUA Modules ====================--------------------
require "utils" -- Load LUA Utilities
require "plugins" -- Load LUA Plugins
require "key-bindings" -- Set Key-bindings

--------------------==================== LVIM Settings ====================--------------------
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile

lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "onedarker"
lvim.transparent_window = true

-- when pressing left/right cursor keys, Vim will move to the previous/next line after reaching first/last character in the line
lvim.line_wrap_cursor_movement = true

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "startify" -- "dashboard"; "startify"

lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true

lvim.builtin.bufferline.active = true
lvim.builtin.lualine.active = true

lvim.builtin.dap.active = true

lvim.builtin.terminal.active = true

-- Swap `;` with `:`
vim.api.nvim_set_keymap("n", ";", ":", { noremap = true })
vim.api.nvim_set_keymap("n", ":", ";", { noremap = true })
vim.api.nvim_set_keymap("v", ";", ":", { noremap = true })
vim.api.nvim_set_keymap("v", ":", ";", { noremap = true })

-- SmartClose
vim.api.nvim_set_keymap("n", "<F4>", ":SmartClose", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<F4>", ":SmartClose", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<F4>", "<C-[>:SmartClose", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-x>", ":SmartClose", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<S-x>", ":SmartClose", { noremap = true, silent = true })

-- lvim.keys.normal_mode["<S-x>"] = ":BufferClose"

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
    "bash",
    "c",
    "javascript",
    "json",
    "lua",
    "python",
    "typescript",
    "tsx",
    "css",
    "rust",
    "java",
    "yaml",
}

-- lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- require("user.neovim").config()

--------------------==================== Support for Chinese Typing ====================--------------------
-- if vim.g.is_mac then
--   use({ "lyokha/vim-xkbswitch", event = { "InsertEnter" } })
-- elseif vim.g.is_win then
--   use({ "Neur1n/neuims", event = { "InsertEnter" } })
-- end

---------------------------------------- RainbowParens ----------------------------------------
-- require("nvim-treesitter.configs").setup {
--   rainbow = {
--     enable = true,
--     -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
--     extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
--     max_file_lines = nil, -- Do not enable for files with more than n lines, int
--     -- colors = {}, -- table of hex strings
--     -- termcolors = {} -- table of colour name strings
--   },
-- }

-- Remove mapping
lvim.builtin.which_key.mappings["T"] = nil
lvim.builtin.which_key.mappings["o"] = nil
lvim.builtin.which_key.mappings["O"] = nil

---------------------------------------- Search & Replace (nvim-spectre) ----------------------------------------
-- Add new feature to do search current word in current file
function OpenFileSearchCurrentWord()
    require("spectre").open {
        path = vim.fn.expand "%",
        search_text = vim.fn.expand "<cword>",
    }
end
lvim.builtin.which_key.mappings["sw"] = { "lua OpenFileSearchCurrentWord()", "Search Current Word" }

---------------------------------------- Session Management - persistence ----------------------------------------
lvim.builtin.which_key.mappings["m"] = {
    name = "Mgmt Session",
    c = { "lua require('persistence').load()", "Restore last session for current dir" },
    l = { "lua require('persistence').load({ last = true })", "Restore last session" },
    Q = { "lua require('persistence').stop()", "Quit without saving session" },
}

---------------------------------------- StatusLine (LuaLine) Settings ----------------------------------------
lvim.builtin.lualine.style = "lvim" -- "lvim" or "default" or "none"
lvim.builtin.lualine.sections.lualine_c = { "diff" }
-- no need to set style = "lvim"
local components = require "lvim.core.lualine.components"
lvim.builtin.lualine.sections.lualine_a = { "mode" }
lvim.builtin.lualine.sections.lualine_y = {
    components.spaces,
    components.location,
}
-- lvim.builtin.lualine.options.theme = "gruvbox"
lvim.builtin.lualine.options.theme = "edge"

---------------------------------------- AutoCompletion - cmp ----------------------------------------
lvim.builtin.cmp.completion.keyword_length = 2

---------------------------------------- Tmux Navigation ----------------------------------------
vim.g.tmux_navigator_no_mappings = 1

---------------------------------------- Fuzzy Search - TeleScope ----------------------------------------
lvim.builtin.telescope.defaults.layout_config.width = 0.95
lvim.builtin.telescope.defaults.layout_config.preview_cutoff = 75

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
    -- for input mode
    i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,
    },
    -- for normal mode
    n = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
    },
}

---------------------------------------- FileTree - NvimTree ----------------------------------------
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.nvimtree.show_icons.git = 1
lvim.builtin.nvimtree.setup.actions.open_file.quit_on_open = true
-- Redefine some key mapping
local nvim_tree = require "nvim-tree"
local nvim_tree_cb = require("nvim-tree.config").nvim_tree_callback
nvim_tree.setup {
    view = {
        mappings = {
            custom_only = false,
            list = {
                { key = "u", action = "dir_up", action_cb = nvim_tree_cb "dir_up" },
                { key = "s", action = "horizontal_split", action_cb = nvim_tree_cb "split" },
            },
        },
    },
}

---------------------------------------- Project Management - project ----------------------------------------
-- Integrate with NvimTree
-- Required per repo guideline: https://github.com/ahmedkhalf/project.nvim
vim.g.nvim_tree_respect_buf_cwd = 1
require("nvim-tree").setup {
    update_cwd = true,
    update_focused_file = {
        enable = true,
        update_cwd = true,
    },
}

-- =========== LSP-Signature ===========
vim.defer_fn(function()
    require("lsp_signature").on_attach()
end, 2000)

-- =========== AutoFlake Settings ===========
-- " See https://github.com/tell-k/vim-autoflake
vim.g.autoflake_remove_all_unused_imports = 1
vim.g.autoflake_remove_all_unused_variables = 0
vim.g.autoflake_disable_show_diff = 1
lvim.builtin.which_key.mappings["lu"] = { "call Autoflake()", "Cleanse Imports" }

-- =========== Debugger - DAP ===========
local dap = require "dap"
dap.adapters.python = {
    type = "executable",
    command = "/opt/conda/envs/paper/bin/python", -- if $HOME: command = os.getenv('HOME') .. '/.virtualenvs/tools/bin/python',
    args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
    {
        -- The first three options are required by nvim-dap
        type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = "launch",
        name = "Launch file locally",

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
        program = "${file}", -- This configuration will launch the current file if used.
        pythonPath = function()
            -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
            -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
            -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
            local cwd = vim.fn.getcwd()
            if vim.fn.executable "/opt/conda/envs/prod/bin/python" == 1 then
                return "/opt/conda/envs/prod/bin/python"
            elseif vim.fn.executable "/opt/conda/envs/paper/bin/python" == 1 then
                return "/opt/conda/envs/paper/bin/python"
            elseif vim.fn.executable "/opt/conda/bin/python" == 1 then
                return "/opt/conda/bin/python"
            elseif vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                return cwd .. "/.venv/bin/python"
            else
                return "/usr/bin/python"
            end
        end,
    },
}

dap.configurations.lua = {
    {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim instance",
        host = function()
            local value = vim.fn.input "Host [127.0.0.1]: "
            if value ~= "" then
                return value
            end
            return "127.0.0.1"
        end,
        port = function()
            local val = tonumber(vim.fn.input("Port: ", "54321"))
            assert(val, "Please provide a port number")
            return val
        end,
    },
}

dap.adapters.nlua = function(callback, config)
    callback { type = "server", host = config.host, port = config.port }
end

-- vim.api.nvim_set_keymap("v", "<S-t>", "<ESC>:lua require('dap-python').debug_selection()", { noremap = true })
lvim.builtin.which_key.mappings["dm"] = { "lua require('dap-python').test_method()", "Test Current Method" }
lvim.builtin.which_key.mappings["dn"] = { "lua require('dap-python').test_class()", "Test Current Class" }
lvim.builtin.which_key.mappings["dv"] = { "<ESC>:lua require('dap-python').debug_selection()", "Debug Selection" }
vim.api.nvim_set_keymap("v", "<M-e>", "<ESC>:lua require('dap-python').eval()", { noremap = true })
vim.api.nvim_set_keymap("n", "<M-e>", "lua require('dap-python').eval()", { noremap = true })

-- =========== Debugger - DAP-UI ===========
-- Disabled as it seems buggy
-- Launch DAP-UI automatically on events
local dapui = require "dapui"
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

---------------------------------------- Other - Misc ----------------------------------------

-- generic LSP settings

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---@usage Select which servers should be configured manually. Requires `:LvimCacheReset` to take effect.
-- See the full default list `:lua print(vim.inspect(lvim.lsp.override))`
-- vim.list_extend(lvim.lsp.override, { "pyright" })

-- ---@usage setup a server -- see: https://www.lunarvim.org/languages/#overriding-the-default-configuration
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pylsp", opts)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
lvim.autocommands.custom_groups = {
    -- On entering a lua file, set the tab spacing and shift width to 8
    { "BufWinEnter", "*.lua", "setlocal ts=4 sw=4" },
    -- -- On entering insert mode in any file, scroll the window so the cursor line is centered
    -- {"InsertEnter", "*", ":normal zz"},
}
