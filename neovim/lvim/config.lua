--
-- ██╗░░░░░██╗░░░██╗███╗░░██╗░█████╗░██████╗░██╗░░░██╗██╗███╗░░░███╗
-- ██║░░░░░██║░░░██║████╗░██║██╔══██╗██╔══██╗██║░░░██║██║████╗░████║
-- ██║░░░░░██║░░░██║██╔██╗██║███████║██████╔╝╚██╗░██╔╝██║██╔████╔██║
-- ██║░░░░░██║░░░██║██║╚████║██╔══██║██╔══██╗░╚████╔╝░██║██║╚██╔╝██║
-- ███████╗╚██████╔╝██║░╚███║██║░░██║██║░░██║░░╚██╔╝░░██║██║░╚═╝░██║
-- ╚══════╝░╚═════╝░╚═╝░░╚══╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝
--
--         @mrpeterlee

---------------------------------------- Plugins ----------------------------------------
lvim.plugins = {
  -- {"folke/tokyonight.nvim"},
  -- {"folke/trouble.nvim", cmd = "TroubleToggle",},
  -- Integrate all issues in the same panel
  {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  },

  -- rainbow parenthesis
  {"p00f/nvim-ts-rainbow"},

  -- [Not Working with NeoVim]-- Ctrol-Space for Project Management
  -- {"vim-ctrlspace/vim-ctrlspace",
  --   setup = function()
  --     vim.g.CtrlSpaceDefaultMappingKey = ";"
  --     vim.g.CtrlSpaceLoadLastWorkspaceOnStart = 1
  --     vim.g.CtrlSpaceSaveWorkspaceOnSwitch = 1
  --     vim.g.CtrlSpaceSaveWorkspaceOnExit = 1
  --     vim.g.CtrlSpaceProjectRootMarkers = ""
  --  end
  -- },

  -- Search & Replace
  {
  "windwp/nvim-spectre",
  event = "BufRead",
  config = function()
    require("spectre").setup({
         mapping={
          ['toggle_line'] = {
              map = "dd",
              cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
              desc = "toggle current item"
          },
        },
      })
  end,
  },

  -- Tmux integration
  {"christoomey/vim-tmux-navigator"},
  {"preservim/vimux"},

  -- to-do integration
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("todo-comments").setup()
    end,
  },

    -- session management - persistence
    {
      "folke/persistence.nvim",
        event = "BufReadPre", -- this will only start session saving when an actual file was opened
        module = "persistence",
        config = function()
          require("persistence").setup {
            dir = vim.fn.expand(vim.fn.stdpath "config" .. "/session/"),
            options = { "buffers", "curdir", "tabpages", "winsize" },
          }
      end,
    },

    -- SmartClose: martClose plugin distinguishes two kinds of windows (the regular windows you use to work) and the auxiliary ones (a preview window, a NERDTree panel, a quickfix window, etc)
    { "szw/vim-smartclose", },

    -- Python - AutoFlake to remove unused imports
    { "tell-k/vim-autoflake", },

}

---------------------------------------- LVIM - General Settings ----------------------------------------
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "onedarker"
lvim.transparent_window = true

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "startify"  -- "dashboard"; "startify"

lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true

lvim.builtin.bufferline.active = true
lvim.builtin.lualine.active = true
lvim.builtin.dap.active = true
lvim.builtin.terminal.active = true
lvim.builtin.bufferline.active = true -- this is actually using romgrk/barbar.nvim

-- Swap `;` with `:`
vim.api.nvim_set_keymap("n", ";", ":", { noremap = true })
vim.api.nvim_set_keymap("n", ":", ";", { noremap = true })
vim.api.nvim_set_keymap("v", ";", ":", { noremap = true })
vim.api.nvim_set_keymap("v", ":", ";", { noremap = true })

-- SmartClose
vim.api.nvim_set_keymap("n", "<F3>", ":SmartClose<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<F3>", ":SmartClose<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<F3>", "<C-[>:SmartClose<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-x>", ":SmartClose<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<S-x>", ":SmartClose<CR>", { noremap = true, silent = true })

-- lvim.keys.normal_mode["<S-x>"] = ":BufferClose<CR>"

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

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

---------------------------------------- LVIM - Key Bindings ----------------------------------------
-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- Move window pane & integrate with Tmux
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- The below is not working
-- lvim.keys.normal_mode["<A-h>"] = "<cmd>lua require("tmux").move_left()<cr>"
-- lvim.keys.normal_mode["<A-j>"] = "<cmd>lua require("tmux").move_bottom()<cr>"
-- lvim.keys.normal_mode["<A-k>"] = "<cmd>lua require("tmux").move_top()<cr>"
-- lvim.keys.normal_mode["<A-l>"] = "<cmd>lua require("tmux").move_right()<cr>"

-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = false
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"
-- when pressing left/right cursor keys, Vim will move to the previous/next line after reaching first/last character in the line
lvim.line_wrap_cursor_movement = true

-- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["p"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["q"] = {
  name = "Update",
    c = { "<cmd>PackerCompile<cr>", "Compile" },
    i = { "<cmd>PackerInstall<cr>", "Install" },
    r = { "<cmd>lua require('lvim.plugin-loader').recompile()<cr>", "Re-compile" },
    s = { "<cmd>PackerSync<cr>", "Sync" },
    S = { "<cmd>PackerStatus<cr>", "Status" },
    u = { "<cmd>PackerUpdate<cr>", "Update" },
    x = { "<cmd>PackerClean<cr>", "Clean" },
  }
lvim.builtin.which_key.mappings["ss"] = { "<cmd>lua require('spectre').open()<CR>", "Search All" }
-- lvim.builtin.which_key.mappings["ss"] = { "<cmd>lua require('spectre').open_file_search()<cr>", "Search" }
-- lvim.builtin.which_key.mappings["sw"] = { "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", "Search Current Word" }
-- lvim.builtin.which_key.mappings["sw"] = { "<cmd>lua require('spectre').open_file_search()<cr>", "Search Current Word" }

lvim.builtin.which_key.mappings["t"] = {
  name = "+Trouble",
  r = { "<cmd>Trouble references<cr>", "References" },
  f = { "<cmd>Trouble definitions<cr>", "Definitions" },
  d = { "<cmd>Trouble workspace_diagnostics<cr>", "Diagnostics" },
  -- d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
  q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
  l = { "<cmd>Trouble loclist<cr>", "LocationList" },
  w = { "<cmd>TodoQuickFix<cr>", "ToDos" },
}

-- vim.api.nvim_command('quit!')
-- vim.api.nvim_command('close!')
lvim.builtin.which_key.mappings["c"] = { "<cmd>SmartClose<CR>", "Close", noremap=true, silent=true }
-- lvim.builtin.which_key.mappings["q"] = { "<cmd>q!<CR>", "Quit" }

---------------------------------------- Search & Replace (nvim-spectre) ----------------------------------------
-- Add new feature to do search current word in current file
function OpenFileSearchCurrentWord()
    require'spectre'.open({
        path = vim.fn.expand("%"),
        search_text = vim.fn.expand('<cword>'),
    })
end
lvim.builtin.which_key.mappings["sw"] = { "<cmd>lua OpenFileSearchCurrentWord()<CR>", "Search Current Word" }


---------------------------------------- Session Management - persistence ----------------------------------------
lvim.builtin.which_key.mappings["m"]= {
  name = "Mgmt Session",
  c = { "<cmd>lua require('persistence').load()<cr>", "Restore last session for current dir" },
  l = { "<cmd>lua require('persistence').load({ last = true })<cr>", "Restore last session" },
  Q = { "<cmd>lua require('persistence').stop()<cr>", "Quit without saving session" },
}

---------------------------------------- StatusLine (LuaLine) Settings ----------------------------------------
lvim.builtin.lualine.style = "lvim" -- "lvim" or "default" or "none"
lvim.builtin.lualine.sections.lualine_c = { "diff", }
-- no need to set style = "lvim"
local components = require("lvim.core.lualine.components")
lvim.builtin.lualine.sections.lualine_a = { "mode", }
lvim.builtin.lualine.sections.lualine_y = {
  components.spaces,
  components.location,
}
-- lvim.builtin.lualine.options.theme = "gruvbox"
lvim.builtin.lualine.options.theme = "onedarker"

---------------------------------------- AutoCompletion - cmp ----------------------------------------
lvim.builtin.cmp.completion.keyword_length = 2



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
local nvim_tree = require'nvim-tree'
local nvim_tree_cb = require'nvim-tree.config'.nvim_tree_callback
nvim_tree.setup {
  view = {
    mappings = {
      custom_only = false,
      list = {
        { key = "u", action = "dir_up", action_cb = nvim_tree_cb("dir_up") },
        { key = "s", action = "horizontal_split", action_cb = nvim_tree_cb("split") },
      },
    },
  },
}

---------------------------------------- Project Management - project ----------------------------------------
-- Integrate with NvimTree
-- Required per repo guideline: https://github.com/ahmedkhalf/project.nvim
vim.g.nvim_tree_respect_buf_cwd = 1
require("nvim-tree").setup({
  update_cwd = true,
  update_focused_file = {
    enable = true,
    update_cwd = true
  },
})


---------------------------------------- LSP - Python ----------------------------------------
-- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black", filetypes = { "python" } },
  { command = "isort", filetypes = { "python" } },
  {
    -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
    command = "prettier",
    ---@usage arguments to pass to the formatter
    -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
    extra_args = { "--print-with", "100" },
    ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    filetypes = { "typescript", "typescriptreact" },
  },
}

-- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "pylint", filetypes = { "python" } },
  {
    -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
    command = "shellcheck",
    ---@usage arguments to pass to the formatter
    -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
    extra_args = { "--severity", "warning" },
  },
  {
    command = "codespell",
    ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
    filetypes = { "javascript", "python" },
  },
}

-- " =========== AutoFlake Settings ===========
-- " See https://github.com/tell-k/vim-autoflake
vim.g.autoflake_remove_all_unused_imports = 1
vim.g.autoflake_remove_all_unused_variables = 0
vim.g.autoflake_disable_show_diff = 1
lvim.builtin.which_key.mappings["lu"] = { "<cmd>call Autoflake()<CR><CR>", "Cleanse Imports" }

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

---------------------------------------- VIM - General Settings ----------------------------------------
vim.opt.backup = false -- creates a backup file
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.opt.cmdheight = 2 -- more space in the neovim command line for displaying messages
vim.opt.colorcolumn = "99999" -- fixes indentline for now
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.conceallevel = 0 -- so that `` is visible in markdown files
vim.opt.fileencoding = "utf-8" -- the encoding written to a file
vim.opt.foldmethod = "manual" -- folding set to "expr" for treesitter based folding
vim.opt.foldexpr = "" -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
vim.opt.guifont = "firamono:h17" -- the font used in graphical neovim applications
vim.opt.hidden = true -- required to keep multiple buffers and open multiple buffers
vim.opt.hlsearch = true -- highlight all matches on previous search pattern
vim.opt.ignorecase = true -- ignore case in search patterns
vim.opt.mouse = "a" -- allow the mouse to be used in neovim
vim.opt.pumheight = 10 -- pop up menu height
vim.opt.showmode = false -- we don't need to see things like -- INSERT -- anymore
vim.opt.showtabline = 2 -- always show tabs
vim.opt.smartcase = true -- smart case
vim.opt.smartindent = true -- make indenting smarter again
vim.opt.splitbelow = true -- force all horizontal splits to go below current window
vim.opt.splitright = true -- force all vertical splits to go to the right of current window
vim.opt.swapfile = false -- creates a swapfile
vim.opt.termguicolors = true -- set term gui colors (most terminals support this)
vim.opt.timeoutlen = 100 -- time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.title = true -- set the title of window to the value of the titlestring
vim.opt.titlestring = "%<%F%=%l/%L - nvim" -- what the title of the window will be set to
vim.opt.undodir = vim.fn.stdpath "cache" .. "/undo"
vim.opt.undofile = true -- enable persistent undo
vim.opt.updatetime = 300 -- faster completion
vim.opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program) it is not allowed to be edited
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.shiftwidth = 2 -- the number of spaces inserted for each indentation
vim.opt.tabstop = 2 -- insert 2 spaces for a tab
vim.opt.cursorline = true -- highlight the current line
vim.opt.number = true -- set numbered lines
vim.opt.relativenumber = false -- set relative numbered lines
vim.opt.numberwidth = 4 -- set number column width to 2 {default 4}
vim.opt.signcolumn = "yes" -- always show the sign column otherwise it would shift the text each time
vim.opt.wrap = false -- display lines as one long line
vim.opt.spell = false
vim.opt.spelllang = "en"
vim.opt.scrolloff = 8 -- is one of my fav
vim.opt.sidescrolloff = 8


