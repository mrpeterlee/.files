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
    -- { "Vimjas/vim-python-pep8-indent" },
    { "sheerun/vim-polyglot" },

    -- -- NOTE: Learn this plugin -- Python motion control around class / methods
    -- { "jeetsukumaran/vim-pythonsense", ft = { "python" } },

    -- -- NOTE: Learn this plugin -- Swap parameters inside function
    -- { "machakann/vim-swap", event = "VimEnter" },

    -- Python - Provides code signature when adding a function
    {
        "ray-x/lsp_signature.nvim",
        config = function()
            require("config/lsp_signature").config()
        end,
        event = { "BufRead", "BufNew" },
    },

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
