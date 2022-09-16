return {
    ["declancm/cinnamon.nvim"] = { disable = true },
    ["goolord/alpha-nvim"] = { disable = true },
    ["lukas-reineke/indent-blankline.nvim"] = { disable = true },

    ["aserowy/tmux.nvim"] = {
        config = function()
            require("user.plugins.tmux")()
        end,
    },
    ["andymass/vim-matchup"] = { event = { "BufRead", "BufNewFile" } },
    ["danymat/neogen"] = {
        module = "neogen",
        cmd = "Neogen",
        config = function()
            require("neogen").setup(require("user.plugins.neogen"))
        end,
        requires = "nvim-treesitter/nvim-treesitter",
    },
    ["dhruvasagar/vim-table-mode"] = {
        cmd = { "TableModeToggle", "TableModeEnable", "TableModeDisable" },
        setup = function()
            vim.g.table_mode_corner = "|"
        end,
    },
    ["ellisonleao/glow.nvim"] = {
        cmd = "Glow",
        module = "glow",
        setup = function()
            vim.g.glow_border = "rounded"
        end,
    },
    ["ethanholz/nvim-lastplace"] = {
        event = "BufRead",
        config = function()
            require("nvim-lastplace").setup(require("user.plugins.nvim-lastplace"))
        end,
    },
    ["folke/zen-mode.nvim"] = {
        cmd = "ZenMode",
        module = "zen-mode",
        config = function()
            require("zen-mode").setup(require("user.plugins.zen-mode"))
        end,
    },
    ["hrsh7th/cmp-calc"] = {
        after = "nvim-cmp",
        config = function()
            require("core.utils").add_user_cmp_source("calc")
        end,
    },
    ["hrsh7th/cmp-emoji"] = {
        after = "nvim-cmp",
        config = function()
            require("core.utils").add_user_cmp_source("emoji")
        end,
    },
    ["jbyuki/nabla.nvim"] = { module = "nabla" },
    ["jc-doyle/cmp-pandoc-references"] = {
        after = "nvim-cmp",
        config = function()
            require("core.utils").add_user_cmp_source("pandoc_references")
        end,
    },
    ["kdheepak/cmp-latex-symbols"] = {
        after = "nvim-cmp",
        config = function()
            require("core.utils").add_user_cmp_source("latex_symbols")
        end,
    },
    -- debugging
    -- ["mfussenegger/nvim-dap"] = { module = "dap", config = require("user.plugins.dap"), },
    -- This is the new setting
    ["mfussenegger/nvim-dap"] = {
        opt = true,
        event = "BufReadPre",
        module = { "dap" },
        wants = { "nvim-dap-virtual-text", "nvim-dap-ui", "nvim-dap-python", "which-key.nvim" },
        requires = {
            "theHamsta/nvim-dap-virtual-text",
            "rcarriga/nvim-dap-ui",
            "mfussenegger/nvim-dap-python",
            "nvim-telescope/telescope-dap.nvim",
            { "jbyuki/one-small-step-for-vimkind", module = "osv" },
        },
        config = function()
            require("user.dap").setup()
        end,
    },

    -- ["mfussenegger/nvim-dap-python"] = {
    -- 	after = "nvim-dap",
    -- 	config = require("user.plugins.dap-python"),
    -- },
    -- ["rcarriga/nvim-dap-ui"] = {
    -- 	after = "nvim-dap",
    -- 	config = function()
    -- 		local dap, dapui = require("dap"), require("dapui")
    -- 		dapui.setup(require("user.plugins.dapui"))
    -- 		-- add listeners to auto open DAP UI
    -- 		dap.listeners.after.event_initialized["dapui_config"] = function()
    -- 			dapui.open()
    -- 		end
    -- 		dap.listeners.before.event_terminated["dapui_config"] = function()
    -- 			dapui.close()
    -- 		end
    -- 		dap.listeners.before.event_exited["dapui_config"] = function()
    -- 			dapui.close()
    -- 		end
    -- 	end,
    -- },
    -- debugging
    -- ["theHamsta/nvim-dap-virtual-text"] = {
    -- 	after = "nvim-dap",
    -- 	config = function()
    -- 		require("nvim-dap-virtual-text").setup({
    -- 			enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
    -- 			highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
    -- 			highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
    -- 			show_stop_reason = true, -- show stop reason when stopped for exceptions
    -- 			commented = false, -- prefix virtual text with comment string
    -- 			only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
    -- 			all_references = false, -- show virtual text on all all references of the variable (not only definitions)
    -- 			filter_references_pattern = "<module", -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
    -- 			-- experimental features:
    -- 			virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
    -- 			all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    -- 			virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
    -- 			virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
    -- 			-- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
    -- 		})
    -- 	end,
    -- },

    ["mtikekar/nvim-send-to-term"] = {
        cmd = "SendHere",
        setup = function()
            vim.g.send_disable_mapping = true
        end,
    },
    ["nanotee/sqls.nvim"] = { after = "nvim-lspconfig" },
    ["phaazon/hop.nvim"] = {
        event = { "BufRead", "BufNewFile" },
        branch = "v1",
        config = function()
            require("hop").setup({
                case_insensitive = true,
                char2_fallback_key = "<CR>",
                quit_key = "<Esc>",
            })
        end,
    },
    ["skywind3000/asyncrun.vim"] = { cmd = "AsyncRun" },
    ["nvim-treesitter/nvim-treesitter-textobjects"] = { after = "nvim-treesitter" },
    ["nvim-telescope/telescope-bibtex.nvim"] = {
        after = "telescope.nvim",
        config = function()
            require("telescope").load_extension("bibtex")
        end,
    },
    ["nvim-telescope/telescope-hop.nvim"] = {
        after = "telescope.nvim",
        config = function()
            require("telescope").load_extension("hop")
        end,
    },
    ["nvim-telescope/telescope-media-files.nvim"] = {
        after = "telescope.nvim",
        config = function()
            require("telescope").load_extension("media_files")
        end,
    },
    ["nvim-telescope/telescope-project.nvim"] = {
        after = "telescope.nvim",
        config = function()
            require("telescope").load_extension("project")
        end,
    },
    ["nvim-telescope/telescope-file-browser.nvim"] = {
        after = "telescope.nvim",
        config = function()
            require("telescope").load_extension("file_browser")
        end,
    },
    -- ["nvim-telescope/telescope-dap.nvim"] = {
    -- 	after = "telescope.nvim",
    -- 	config = function()
    -- 		require("telescope").load_extension("dap")
    -- 	end,
    -- },

    -- display function context on top of the screen
    -- good plugin, but prompts a deprecation warning; disabled temporarily
    -- {
    -- 	"romgrk/nvim-treesitter-context",
    -- 	config = function()
    -- 		vim.defer_fn(function()
    -- 			require("treesitter-context.config").setup({ enable = true })
    -- 		end, 2000)
    -- 	end,
    -- },

    -- Select python functions
    ["mfussenegger/nvim-ts-hint-textobject"] = {},

    ["wakatime/vim-wakatime"] = { event = "BufRead" },

    -- Jump between windows by keyword
    -- ["https://gitlab.com/yorickpeterse/nvim-window.git"] = {},

    -- GitHub copilot
    ["github/copilot.vim"] = {},

    -- [disabled] Does not work with a blank buffer at start
    -- ["folke/todo-comments.nvim"] = {
    -- 	event = "BufRead",
    -- 	config = function()
    -- 		vim.defer_fn(function()
    -- 			require("todo-comments").setup()
    -- 		end, 2000)
    -- 	end,
    -- },

    -- navigate between old and new git commits for the current line and view the diffs easily.
    -- use { "rhysd/git-messenger.vim" }

    -- To speed up start-up time by 10ms
    ["nathom/filetype.nvim"] = {},

    -- makes default vim ui prompts nicer
    ["stevearc/dressing.nvim"] = {
        config = function()
            vim.defer_fn(function()
                require("dressing").setup({
                    -- Can be 'left', 'right', or 'center'
                    prompt_align = "left",
                })
            end, 2000)
        end,
    },

    -- hit ctrl-p to yield a palette similar to vsc command search
    ["mrjones2014/legendary.nvim"] = {
        keys = { [[<C-p>]] },
        config = function()
            require("user.plugins.legendary").setup()
        end,
        requires = { "stevearc/dressing.nvim" },
    },

    -- vimwiki:: for managing personal journal && todo
    ["vimwiki/vimwiki"] = { branch = "dev" },

    -- csv.vim:: Open csv files
    -- ["chrisbra/csv.vim"] = {},

    -- markdown-preview
    ["iamcco/markdown-preview.nvim"] = {
        run = function()
            vim.fn["mkdp#util#install"]()
        end,
    },

    -- jupyter_ascending
    ["untitled-ai/jupyter_ascending.vim"] = {},

    -- -- LSP symbols
    -- {
    -- 	"stevearc/aerial.nvim",
    -- 	opt = true,
    -- 	setup = function()
    -- 		require("core.utils").defer_plugin("aerial.nvim")
    -- 	end,
    -- 	config = function()
    -- 		require("user.plugins.aerial").config()
    -- 	end,
    -- },

    -- clipboard plugin
    ["ojroques/vim-oscyank"] = {},

    -- trouble
    ["folke/trouble.nvim"] = {
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup({
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            })
        end,
    },
}
