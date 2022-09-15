return function()
	local set = vim.opt
	local g = vim.g

	-- Options
	-- enable spelling check
	set.spell = false
	set.spelllang = { "en_us" }
	--  After adding a word to 'spellfile' with the above commands its associated
	--  '.spl' file will automatically be updated and reloaded. If you change
	--  'spellfile' manually you need to use the |:mkspell| command. This sequence of
	--  commands mostly works well:
	--
	--      :edit <spellfile; e.g. en.utf-8.add>
	--      (make changes to the spell file)
	--      :mkspell! %

	-- show whitespace characters
	set.list = true
	set.listchars = {
		tab = "│→",
		extends = "⟩",
		precedes = "⟨",
		trail = "·",
		nbsp = "␣",
	}
	set.showbreak = "↪ "
	-- enable conceal
	set.conceallevel = 2
	-- soft wrap lines
	set.wrap = true
	-- linebreak soft wrap at words
	set.linebreak = true

	-- set spell and thesaurus files
	-- set.spellfile = "~/.config/nvim/spell/en.utf-8.add"
	-- set.thesaurus = "~/.config/nvim/lua/user/spell/mthesaur.txt"
	-- set Treesitter based folding and disable auto-folding on open
	set.foldenable = false
	set.foldmethod = "expr"
	set.foldexpr = "nvim_treesitter#foldexpr()"

	g.load_black = false
	g.loaded_matchit = true

	-- set tab=4 spaces for python
	g.python_recommended_style = true
	g.shiftwidth = 4
	g.tabstop = 4

	-- copilot
	g.copilot_no_tab_map = true
	g.copilot_assume_mapped = true
	g.copilot_tab_fallback = ""
	vim.api.nvim_set_keymap("i", "<C-f>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

	-- toggle term on the side
	local Terminal = require("toggleterm.terminal").Terminal
	local side_term = Terminal:new({
		-- cmd = "lazygit",
		-- dir = "git_dir",
		direction = "vertical",
		-- float_opts = {
		-- border = "double",
		-- },
		-- function to run on opening the terminal
		on_open = function(term)
			vim.cmd("startinsert!")
			vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
		end,
		-- function to run on closing the terminal
		on_close = function(term)
			vim.cmd('echo "Closing terminal"')
		end,
	})
	function _side_term_toggle()
		side_term:toggle()
	end
	vim.api.nvim_set_keymap("n", "<C-t>", "<cmd>lua _side_term_toggle()<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "<A-.>", "<cmd>lua _side_term_toggle()<CR>", { noremap = true, silent = true })

	-- indent blankline
	vim.g.indent_blankline_filetype_exclude = {
		"lspinfo",
		"packer",
		"checkhealth",
		"help",
		"man",
		"markdown",
		"vimwiki",
		"csv",
	}

	-- Auto Commands
	require("user.autocmds").setup()

	-- Mappings
	-- require("user.mappings").setup()
	-- Move buffers
	-- select python method / class
	vim.cmd([[omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>]])
	vim.cmd([[vnoremap <silent> m :lua require('tsht').nodes()<CR>]])

	-- Send line to ToggleTerm
	vim.cmd([[ nnoremap <C-Enter> :silent write \|\| ToggleTermSendCurrentLine <ENTER> ]])
	vim.cmd([[ inoremap <C-Enter> <C-O>:silent write \|\| ToggleTermSendCurrentLine <ENTER> ]])
	vim.cmd([[ vnoremap <C-Enter> :ToggleTermSendVisualLines <ENTER> ]])
	vim.cmd([[ nnoremap <F12> :silent write \|\| ToggleTermSendCurrentLine <ENTER> ]])
	vim.cmd([[ inoremap <F12> <C-O>:silent write \|\| ToggleTermSendCurrentLine <ENTER> ]])
	vim.cmd([[ vnoremap <F12> :ToggleTermSendVisualLines <ENTER> ]])
	-- hop
	vim.cmd([[ hi HopNextKey cterm=bold ctermfg=198 gui=bold guifg=#ff007c]])
	vim.cmd([[ hi HopNextKey1 cterm=bold ctermfg=198 gui=bold guifg=#ff007c]])
	vim.cmd([[ hi HopNextKey2 cterm=bold ctermfg=198 gui=bold guifg=#ff007c]])

	-- move current line up and down
	-- map("n", "<C-k>", ":m .-2<CR>==", { desc = "Switch line up" })
	-- map("n", "<C-j>", ":m .+1<CR>==", { desc = "Switch line down" })
	-- map("i", "<C-k>", "<Esc>:m .-2<CR>==gi", { desc = "Switch line up" })
	-- map("i", "<C-j>", "<Esc>:m .+1<CR>==gi", { desc = "Switch line down" })

	-- Filetypes
	require("user.filetype").setup()

	-- Load vimscript
	-- vim.cmd("source " .. vim.fn.expand("$HOME") .. "/.config/nvim/lua/user/vimscript/utils.vim")
	vim.cmd("source " .. vim.fn.expand("$HOME") .. "/.config/nvim/lua/user/vimscript/autocmd.vim")
	vim.cmd("source " .. vim.fn.expand("$HOME") .. "/.config/nvim/lua/user/vimscript/init_last.vim")
end
