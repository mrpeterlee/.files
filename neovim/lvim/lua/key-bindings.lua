--------------------==================== Key-Binding Syntax ====================--------------------
-- 1). Use nvim syntax:
--     vim.api.nvim_set_keymap('n', '<Leader><Space>', ':set hlsearch!<CR>', { noremap = true, silent = true })
--     -- Vim equivalent
--     -- :nnoremap <silent> <Leader><Space> :set hlsearch<CR>

--     vim.api.nvim_set_keymap('n', '<Leader>tegf',  [[<Cmd>lua require('telescope.builtin').git_files()<CR>]], { noremap = true, silent = true })
--     -- Vim equivalent
--     -- :nnoremap <silent> <Leader>tegf <Cmd>lua require('telescope.builtin').git_files()<CR>

--     vim.api.nvim_buf_set_keymap(0, '', 'cc', 'line(".") == 1 ? "cc" : "ggcc"', { noremap = true, expr = true })
--     -- Vim equivalent
--     -- :noremap <buffer> <expr> cc line('.') == 1 ? 'cc' : 'ggcc'

-- 2). Use Vim syle:
--     # Just take your vim keybindings and wrap them in vim.cmd
--     vim.cmd("nnoremap W :w<CR>")

--     # Multiline Statements
--     vim.cmd([[
--         map <Leader>bb :!bundle install<cr>
--         map <Leader>gdm :Git diff master<cr>
--         imap jj <esc>
--     ]])

--     # Calling lua functions
--     vim.cmd("nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>")

-- 3). Use lvim syntax:
--     To modify a single Lunarvim keymapping
--       -- X closes a buffer
--       lvim.keys.normal_mode["<S-x>"] = ":BufferClose<CR>"

--     To remove keymappings set by Lunarvim
--       -- use the default vim behavior for H and L
--       lvim.keys.normal_mode["<S-l>"] = false
--       lvim.keys.normal_mode["<S-h>"] = false
--       -- vim.opt.scrolloff = 0 -- Required so L moves to the last line

--     Erase Lunarvim bindings and replace them with your own mappings
--      lvim.keys.normal_mode = {
--        -- Page down/up
--        ["[d"] = "<PageUp>",
--        ["]d"] = "<PageDown>",
--        -- Navigate buffers
--        ["<Tab>"] = ":bnext<CR>",
--        ["<S-Tab>"] = ":bprevious<CR>",
--      }

-- TABLE OF CONTENT --
-- Please see lvim/README.md

--------------------==================== LVIM Key Bindings ====================--------------------
-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

-- Move window pane & integrate with Tmux
-- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["p"] = nil

-- SPC f:: FILES
lvim.builtin.which_key.mappings["f"] = {
  name = "+File",
    f = { require("lvim.core.telescope.custom-finders").find_project_files, "Find File" },
    p = { "<cmd>Telescope projects<CR>", "Project" },
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
    s = { "<cmd>Telescope live_grep<cr>", "Search String" },
  }

-- SPC u:: UPDATE
lvim.builtin.which_key.mappings["u"] = {
  name = "+Update",
    c = { "<cmd>PackerCompile<cr>", "Compile" },
    i = { "<cmd>PackerInstall<cr>", "Install" },
    r = { "<cmd>lua require('lvim.plugin-loader').recompile()<cr>", "Re-compile" },
    s = { "<cmd>PackerSync<cr>", "Sync" },
    l = { "<cmd>PackerStatus<cr>", "List Plugins" },
    u = { "<cmd>PackerUpdate<cr>", "Update" },
    x = { "<cmd>PackerClean<cr>", "Delete Unused" },
  }

-- SPC s:: SEARCH
-- lvim.builtin.which_key.mappings["ss"] = { "<cmd>lua require('spectre').open_file_search()<cr>", "Search" }
lvim.builtin.which_key.mappings["s"] = {
    name = "+Search",
        -- TODO: move to "git" --> b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        f = { "<cmd>Telescope find_files<cr>", "Find File" },
        h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
        M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
        R = { "<cmd>Telescope registers<cr>", "Registers" },
        k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
        C = { "<cmd>Telescope commands<cr>", "Commands" },
        a = { "<cmd>lua require('spectre').open()<CR>", "Replace in Folder" },
        s = { "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", "Replace in File" },
      }

-- SPC t:: TEST
lvim.builtin.which_key.mappings["t"] = {
  name = "+Test",
  r = { "<cmd>Trouble references<cr>", "References" },
  f = { "<cmd>Trouble definitions<cr>", "Definitions" },
  d = { "<cmd>Trouble workspace_diagnostics<cr>", "Diagnostics" },
  -- d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
  q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
  l = { "<cmd>Trouble loclist<cr>", "Location List" },
  w = { "<cmd>TodoQuickFix<cr>", "ToDos" },
}

-- SPC b:: Buffer
lvim.builtin.which_key.mappings["b"] = {
    name = "+Buffer",
    h = { "<cmd>BufferLineCloseLeft<cr>", "Close all to the left" },
    l = { "<cmd>BufferLineCloseRight<cr>", "Close all to the right", },
    q = { "<cmd>BufferLinePickClose<cr>", "Pick which buffer to close", },
    j = { "<cmd>BufferLinePick<cr>", "Select by letter" },
    d = { "<cmd>BufferLineSortByDirectory<cr>", "Sort by directory", },
    e = { "<cmd>BufferLineSortByExtension<cr>", "Sort by extension", },
    [","] = { "<cmd>BufferLineCyclePrev<cr>", "Previous" },
    ["."] = { "<cmd>BufferLineCycleNext<cr>", "Next" },
}

-- SPC d:: Debug
lvim.builtin.which_key.mappings["d"] = {
    name = "+Debug",
    t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
    b = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
    n = { "<cmd>lua require'dap'.continue()<cr>", "Next" },
    C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
    d = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
    g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
    i = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
    o = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
    u = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
    p = { "<cmd>lua require'dap'.pause.toggle()<cr>", "Pause" },
    r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
    s = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
    q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
    h = { "<cmd>lua require('dapui').toggle()<CR>", "DAP-UI" },
    e = { "<cmd>lua require('dapui').eval()<CR>", "Eval Expression" },
    m = { "<cmd>lua require('dap-python').test_method()<CR>", "Test Current Method" },
    c = { "<cmd>lua require('dap-python').test_class()<CR>", "Test Current Class" },
    v = { "<ESC>:lua require('dap-python').debug_selection()<CR>", "Debug Selection" },
}

vim.api.nvim_set_keymap("n", "tt", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "tb", "<cmd>lua require'dap'.step_back()<cr>",{ noremap = true })
vim.api.nvim_set_keymap("n", "tn", "<cmd>lua require'dap'.continue()<cr>",{ noremap = true })
vim.api.nvim_set_keymap("n", "tC", "<cmd>lua require'dap'.run_to_cursor()<cr>",{ noremap = true })
vim.api.nvim_set_keymap("n", "td", "<cmd>lua require'dap'.disconnect()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "tg", "<cmd>lua require'dap'.session()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "ti", "<cmd>lua require'dap'.step_into()<cr>",{ noremap = true })
vim.api.nvim_set_keymap("n", "to", "<cmd>lua require'dap'.step_over()<cr>",{ noremap = true })
vim.api.nvim_set_keymap("n", "tu", "<cmd>lua require'dap'.step_out()<cr>",{ noremap = true })
vim.api.nvim_set_keymap("n", "tp", "<cmd>lua require'dap'.pause.toggle()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "tr", "<cmd>lua require'dap'.repl.toggle()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "ts", "<cmd>lua require'dap'.continue()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "tq", "<cmd>lua require'dap'.close()<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "th", "<cmd>lua require('dapui').toggle()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "te", "<cmd>lua require('dapui').eval()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "tm", "<cmd>lua require('dap-python').test_method()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "tc", "<cmd>lua require('dap-python').test_class()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "tv", "<ESC>:lua require('dap-python').debug_selection()<CR>", { noremap = true })


-- SPC L:: LUNAR VIM
lvim.builtin.which_key.mappings["Lt"] = {
          "<cmd>lua require('telescope.builtin.internal').colorscheme({enable_preview = true})<cr>",
          "Colorscheme with Preview",
        }
lvim.builtin.which_key.mappings["lb"] = { "<cmd>let blank=''|put=blank|let debug_comment='# ----------  temporary debug code ---------- #'|put=debug_comment|let a='import sys'|put=a|let a='from pprint import pprint'|put=a|let a='print(" .. '"' .. "\\n" .. '"' .. "*2, " .. '"' .. "=" .. '"' .. "*40, " .. '"' .. " temporary debug code " .. '"' .. ", " .. '"' .. "=" .. '"' .. "*40, " .. '"' .. "\\n" .. '"' .. "*2)'|put=a|put=blank|put=a|let a='sys.exit(1)'|put=a|put=debug_comment|put=blank" .. "<CR>", "Debug Snippet" }
lvim.builtin.which_key.mappings["lm"] = { "<cmd>:0 | let blank=''|let t='\"\"\" {Module Name}'|put=t|put=blank|let t='id:            Peter Lee (peter.lee@finclab.com)'|put=t|let t='last_update:   ' . strftime('%Y-%m-%d %H:%M:%S %Z')|put=t|let t='type:          lib'|put=t|let t='sensitivity:   datalab@finclab.com'|put=t|let t='platform:      any'|put=t|let t='description:   {Description}'|put=t|let t='\"\"\"'|put=t<CR>", "Add Module Header" }


lvim.builtin.which_key.mappings[";"] = nil -- no need to access dashboard
lvim.builtin.which_key.mappings[" "] = { "<cmd>Telescope buffers<cr>", "Switch Buffer" }
lvim.builtin.which_key.mappings["c"] =  {"<cmd>BufferKill<CR>", "Close Buffer" }
-- lvim.builtin.which_key.mappings["q"] = { "<cmd>SmartClose<CR>", "Quit", noremap=true, silent=true }
lvim.builtin.which_key.mappings["q"] = { "<cmd>q!<CR>", "Close Window" }
lvim.builtin.which_key.mappings["Q"] = { "<cmd>qa!<CR>", "Exit NeoVim" }



-- " Save key strokes (now we do not need to press shift to enter command mode).
-- " Vim-sneak has also mapped `;`, so using the below mapping will break the map
-- " used by vim-sneak
-- nnoremap ; :
-- xnoremap ; :

-- " Quicker way to open command window
-- nnoremap q; q:

-- " Turn the word under cursor to upper case
-- inoremap <c-u> <Esc>viwUea

-- " Turn the current word into title case
-- inoremap <c-t> <Esc>b~lea

-- " Paste non-linewise text above or below current cursor,
-- " see https://stackoverflow.com/a/1346777/6064933
-- nnoremap <leader>p m`o<ESC>p``
-- nnoremap <leader>P m`O<ESC>p``

-- " Shortcut for faster save and quit
-- nnoremap <silent> <leader>w :<C-U>update<CR>
-- " Saves the file if modified and quit
-- nnoremap <silent> <leader>q :<C-U>x<CR>
-- " Quit all opened buffers
-- nnoremap <silent> <leader>Q :<C-U>qa!<CR>

-- " Navigation in the location and quickfix list
-- nnoremap <silent> [l :<C-U>lprevious<CR>zv
-- nnoremap <silent> ]l :<C-U>lnext<CR>zv
-- nnoremap <silent> [L :<C-U>lfirst<CR>zv
-- nnoremap <silent> ]L :<C-U>llast<CR>zv
-- nnoremap <silent> [q :<C-U>cprevious<CR>zv
-- nnoremap <silent> ]q :<C-U>cnext<CR>zv
-- nnoremap <silent> [Q :<C-U>cfirst<CR>zv
-- nnoremap <silent> ]Q :<C-U>clast<CR>zv

-- " Close location list or quickfix list if they are present,
-- " see https://superuser.com/q/355325/736190
-- nnoremap<silent> \x :<C-U>windo lclose <bar> cclose<CR>

-- " Close a buffer and switching to another buffer, do not close the
-- " window, see https://stackoverflow.com/q/4465095/6064933
-- nnoremap <silent> \d :<C-U>bprevious <bar> bdelete #<CR>

-- " Insert a blank line below or above current line (do not move the cursor),
-- " see https://stackoverflow.com/a/16136133/6064933
-- nnoremap <expr> <Space>o printf('m`%so<ESC>``', v:count1)
-- nnoremap <expr> <Space>O printf('m`%sO<ESC>``', v:count1)

-- " Insert a space after current character
-- nnoremap <Space><Space> a<Space><ESC>h

-- " Move the cursor based on physical lines, not the actual lines.
-- nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
-- nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
-- nnoremap ^ g^
-- nnoremap 0 g0

-- " Do not include white space characters when using $ in visual mode,
-- " see https://vi.stackexchange.com/q/12607/15292
-- xnoremap $ g_

-- " Jump to matching pairs easily in normal mode
-- nnoremap <Tab> %

-- " Go to start or end of line easier
-- nnoremap H ^
-- xnoremap H ^
-- nnoremap L g_
-- xnoremap L g_

-- " Continuous visual shifting (does not exit Visual mode), `gv` means
-- " to reselect previous visual area, see https://superuser.com/q/310417/736190
-- xnoremap < <gv
-- xnoremap > >gv

-- " When completion menu is shown, use <cr> to select an item and do not add an
-- " annoying newline. Otherwise, <enter> is what it is. For more info , see
-- " https://superuser.com/a/941082/736190 and
-- " https://unix.stackexchange.com/q/162528/221410
-- " inoremap <expr> <cr> ((pumvisible())?("\<C-Y>"):("\<cr>"))
-- " Use <esc> to close auto-completion menu
-- " inoremap <expr> <esc> ((pumvisible())?("\<C-e>"):("\<esc>"))

-- " Tab-complete, see https://vi.stackexchange.com/q/19675/15292.
-- inoremap <expr> <tab> pumvisible() ? "\<c-n>" : "\<tab>"
-- inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"

-- " Edit and reload init.vim quickly
-- nnoremap <silent> <leader>ev :<C-U>tabnew $MYVIMRC <bar> tcd %:h<cr>
-- nnoremap <silent> <leader>sv :<C-U>silent update $MYVIMRC <bar> source $MYVIMRC <bar>
--       \ call v:lua.vim.notify("Nvim config successfully reloaded!", 'info', {'title': 'nvim-config'})<cr>

-- " Reselect the text that has just been pasted, see also https://stackoverflow.com/a/4317090/6064933.
-- nnoremap <expr> <leader>v printf('`[%s`]', getregtype()[0])

-- " Search in selected region
-- xnoremap / :<C-U>call feedkeys('/\%>'.(line("'<")-1).'l\%<'.(line("'>")+1)."l")<CR>

-- " Find and replace (like Sublime Text 3)
-- nnoremap <C-H> :%s/
-- xnoremap <C-H> :s/

-- " Change current working directory locally and print cwd after that,
-- " see https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file
-- nnoremap <silent> <leader>cd :<C-U>lcd %:p:h<CR>:pwd<CR>

-- " Use Esc to quit builtin terminal
-- tnoremap <ESC>   <C-\><C-n>

-- " Toggle spell checking (autosave does not play well with z=, so we disable it
-- " when we are doing spell checking)
-- nnoremap <silent> <F11> :<C-U>set spell!<cr>
-- inoremap <silent> <F11> <C-O>:<C-U>set spell!<cr>

-- " Change text without putting it into the vim register,
-- " see https://stackoverflow.com/q/54255/6064933
-- nnoremap c "_c
-- nnoremap C "_C
-- nnoremap cc "_cc
-- xnoremap c "_c

-- " Remove trailing whitespace characters
-- nnoremap <silent> <leader><Space> :<C-U>StripTrailingWhitespace<CR>

-- " check the syntax group of current cursor position
-- nnoremap <silent> <leader>st :<C-U>call utils#SynGroup()<CR>

-- " " Clear highlighting
-- " if maparg('<C-L>', 'n') ==# ''
-- "   nnoremap <silent> <C-L> :<C-U>nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
-- " endif

-- " Copy entire buffer.
-- nnoremap <silent> <leader>y :<C-U>%y<CR>

-- " Toggle cursor column
-- nnoremap <silent> <leader>cl :<C-U>call utils#ToggleCursorCol()<CR>

-- " Move current line up and down
-- nnoremap <silent> <A-k> <Cmd>call utils#SwitchLine(line('.'), 'up')<CR>
-- nnoremap <silent> <A-j> <Cmd>call utils#SwitchLine(line('.'), 'down')<CR>

-- " Move current visual-line selection up and down
-- xnoremap <silent> <A-k> :<C-U>call utils#MoveSelection('up')<CR>
-- xnoremap <silent> <A-j> :<C-U>call utils#MoveSelection('down')<CR>

-- " Replace visual selection with text in register, but not contaminate the
-- " register, see also https://stackoverflow.com/q/10723700/6064933.
-- xnoremap p "_c<ESC>p

-- nnoremap <silent> gb :<C-U>call buf_utils#GoToBuffer(v:count, 'forward')<CR>
-- nnoremap <silent> gB :<C-U>call buf_utils#GoToBuffer(v:count, 'backward')<CR>

-- nnoremap <Left> <C-W>h
-- nnoremap <Right> <C-W>l
-- nnoremap <Up> <C-W>k
-- nnoremap <Down> <C-W>j

-- " Text objects for URL
-- xnoremap <silent> iu :<C-U>call text_obj#URL()<CR>
-- onoremap <silent> iu :<C-U>call text_obj#URL()<CR>

-- " Text objects for entire buffer
-- xnoremap <silent> iB :<C-U>call text_obj#Buffer()<CR>
-- onoremap <silent> iB :<C-U>call text_obj#Buffer()<CR>

-- " Do not move my cursor when joining lines.
-- nnoremap J mzJ`z

-- " Break inserted text into smaller undo units.
-- for ch in [',', '.', '!', '?', ';', ':']
--   execute printf('inoremap %s %s<C-g>u', ch, ch)
-- endfor

-- " insert semicolon in the end
-- inoremap <A-;> <ESC>miA;<ESC>`ii

-- " Keep cursor position after yanking
-- nnoremap y myy
-- xnoremap y myy

-- augroup restore_after_yank
--   autocmd!
--   autocmd TextYankPost *  call s:restore_cursor()
-- augroup END

-- function! s:restore_cursor() abort
--   silent! normal `y
--   silent! delmarks y
-- endfunction



--------------------==================== Combined Keys ====================--------------------
-- NORMAL MODE
lvim.keys.normal_mode = {
    -- Better window movement
    ["<A-h>"] = "<cmd>TmuxNavigateLeft<cr>",
    ["<A-j>"] = "<cmd>TmuxNavigateDown<cr>",
    ["<A-k>"] = "<cmd>TmuxNavigateUp<cr>",
    ["<A-l>"] = "<cmd>TmuxNavigateRight<cr>",

    -- Resize with shift
    ["<A-K>"] = ":resize -2<CR>",
    ["<A-J>"] = ":resize +2<CR>",
    ["<A-H>"] = ":vertical resize -2<CR>",
    ["<A-L>"] = ":vertical resize +2<CR>",

    -- Tab switch buffer
    ["<S-l>"] = ":BufferLineCycleNext<CR>",
    ["<S-h>"] = ":BufferLineCyclePrev<CR>",

    -- Move current line / block with Alt-j/k a la vscode.
    ["<C-j>"] = ":m .+1<CR>==",
    ["<C-k>"] = ":m .-2<CR>==",

    -- QuickFix
    ["]q"] = ":cnext<CR>",
    ["[q"] = ":cprev<CR>",
    ["<C-q>"] = ":call QuickFixToggle()<CR>",
}


-- INSERT MODE 
lvim.keys.insert_mode = {
    -- 'jk' for quitting insert mode
    ["jk"] = "<ESC>",
    -- 'kj' for quitting insert mode
    ["kj"] = "<ESC>",
    -- 'jj' for quitting insert mode
    ["jj"] = "<ESC>",
    -- Move current line / block with Alt-j/k ala vscode.
    ["<C-j>"] = "<Esc>:m .+1<CR>==gi",
    -- Move current line / block with Alt-j/k ala vscode.
    ["<C-k>"] = "<Esc>:m .-2<CR>==gi",
    -- navigation
    ["<A-Left>"] = "<C-\\><C-N><cmd>TmuxNavigateLeft<cr>",
    ["<A-Down>"] = "<C-\\><C-N><cmd>TmuxNavigateDown<cr>",
    ["<A-Up>"] = "<C-\\><C-N><cmd>TmuxNavigateUp<cr>",
    ["<A-Right>"] = "<C-\\><C-N><cmd>TmuxNavigateRight<cr>",
}

-- Terminal mode
lvim.keys.term_mode = {
    -- Terminal window navigation
    ["<A-h>"] = "<C-\\><C-N><cmd>TmuxNavigateLeft<cr>",
    ["<A-j>"] = "<C-\\><C-N><cmd>TmuxNavigateDown<cr>",
    ["<A-k>"] = "<C-\\><C-N><cmd>TmuxNavigateUp<cr>",
    ["<A-l>"] = "<C-\\><C-N><cmd>TmuxNavigateRight<cr>",
}

-- Visual mode
lvim.keys.visual_mode = {
    -- Better indenting
    ["<"] = "<gv",
    [">"] = ">gv",
    -- Spectre search & replace in file
    ["s"] = "<cmd>lua require('spectre').open_visual()<CR>",
}

--- Visual block mode
lvim.keys.visual_block_mode = {
  -- Move selected line / block of text in visual mode
  ["K"] = ":move '<-2<CR>gv-gv",
  ["J"] = ":move '>+1<CR>gv-gv",

  -- Move current line / block with Alt-j/k ala vscode.
  ["<C-j>"] = ":m '>+1<CR>gv-gv",
  ["<C-k>"] = ":m '<-2<CR>gv-gv",
}

 -- Command mode
lvim.keys.command_mode = {
   -- navigate tab completion with <c-j> and <c-k>
   -- runs conditionally
   ["<C-j>"] = { 'pumvisible() ? "\\<C-n>" : "\\<C-j>"', { expr = true, noremap = true } },
   ["<C-k>"] = { 'pumvisible() ? "\\<C-p>" : "\\<C-k>"', { expr = true, noremap = true } },
 }
