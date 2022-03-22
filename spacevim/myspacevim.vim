
func! myspacevim#before() abort
  " Map default leader from '\' to ','
  let g:mapleader = '.'

  set noswapfile

  " =========== CtrlSpace ===========
  set showtabline=0
  let g:CtrlSpaceSymbols = { "File": "◯", "CTab": "▣", "Tabs": "▢" }
  let g:CtrlSpaceLoadLastWorkspaceOnStart=1
  let g:CtrlSpaceSaveWorkspaceOnExit=1
  if executable('rg')
    let g:CtrlSpaceGlobCommand = 'rg --color=never --files'
  endif
  " Speed up file engine
  if has('win32')
    let s:vimfiles = '~/vimfiles'
    let s:os   = 'windows'
  else
    let s:vimfiles = '~/.vim'
    if has('mac') || has('gui_macvim')
      let s:os = 'darwin'
    else
      " elseif has('gui_gtk2') || has('gui_gtk3')
      let s:os = 'linux'
    endif
  endif
  let g:CtrlSpaceFileEngine = s:vimfiles . '/plugged/vim-ctrlspace' . '/bin/file_engine_' . s:os . '_amd64'


  " Change the default search tool to rg
  let profile = SpaceVim#mapping#search#getprofile('rg')
  let default_opt = profile.default_opts + ['--no-ignore-vcs']
  call SpaceVim#mapping#search#profile({'rg' : {'default_opts' : default_opt}})

  " =========== Custom SPC Hotkey ===========
  " If you want to add custom SPC prefix key bindings,
  " you can add them to bootstrap function, be sure the key bindings are not used in SpaceVim.
  " call SpaceVim#custom#SPCGroupName(['G'], '+TestGroup')
  " call SpaceVim#custom#SPC('nore', ['y'], 'echom 1', 'echomessage 1', 1)
  call SpaceVim#custom#SPCGroupName(['='], '+MyFeature')
  call SpaceVim#custom#SPC('nnoremap', ['=', "-"], ':CocList diagnostics<CR>', 'display-lint-error', 0)
  call SpaceVim#custom#SPC('nnoremap', ['=', "="], ":let blank=''|put=blank|let debug_comment='# ----------  temporary debug code ---------- #'|put=debug_comment|let a='import sys'|put=a|let a='from pprint import pprint'|put=a|let a='print(\"\\n\"*2, \"=\"*40, \" temporary debug code \", \"=\"*40, \"\\n\"*2)'\|put=a|put=blank|put=a|let a='sys.exit(1)'|put=a|put=debug_comment|put=blank<cr>", 'insert-debug-lines', 0)
  call SpaceVim#custom#SPC('nnoremap', ['=', "m"], ":let blank=''|let t='\"\"\" {Module Name}'|put=t|put=blank|let t='id:            Peter Lee (peter.lee@finclab.com)'|put=t|let t='last_update:   ' . strftime('%Y-%m-%d %H:%M:%S %Z')|put=t|let t='type:          lib'|put=t|let t='sensitivity:   datalab@finclab.com'|put=t|let t='platform:      any'|put=t|let t='description:   {Description}'|put=t|let t='\"\"\"'|put=t<cr>", 'insert-module-docstring', 0)
  " call SpaceVim#custom#SPCGroupName(['='], '+Formats')
  " call SpaceVim#custom#SPC('nnoremap', ['=', '='], 'gg=G``', 'format-the-buffer', 0)

  " Some trick to copy to ssh local clipboard
  "set clipboard=unnamed
  " Copy text into the remote clipboard
  " vnoremap <Leader>y "+y<Esc>
  vnoremap <Leader>y :'<,'>write! >> /tmp/vim_clipboard.tempfile <enter> <bar> : !transfer_tempfile_to_local_clipboard <enter> <bar> : !rm -f /tmp/vim_clipboard.tempfile <enter>
  nnoremap <Leader>p "+p

  " Redefine FZF to search from project root folder
  call SpaceVim#custom#SPC('nnoremap', ['f', "f"], ':FZF /lab/paper<CR>', 'find-files', 0)
  call SpaceVim#custom#SPC('nnoremap', ['f', "="], '<C-U>call spacevim#lang#python#autoflake()<CR>', 'find-files', 0)

  call SpaceVim#custom#SPC('nnoremap', ['f', "="], '<C-U>call spacevim#lang#python#autoflake()<CR>', 'find-files', 0)

  " " Swap `;` with `:`
  " nnoremap ; :
  " " nnoremap : ;
  " vnoremap ; :
  " " vnoremap : ;

  " test - map for jupyter ascending
  nmap <space><space>x <Plug>JupyterExecute
  nmap <space><space>X <Plug>JupyterExecuteAll

  " =tm -> Table Mode (see: https://github.com/dhruvasagar/vim-table-mode)
  call SpaceVim#custom#SPC('nnoremap', ['=', "t"], ':Tableize/\t<CR>', 'Format to Table', 0)

endf



func! myspacevim#after() abort
  " Script that dominates SpaceVim settings

  " =========== Python Linter ===========
  " when to activate neomake
  call neomake#configure#automake('nrw', 50)
  " which linter to enable for Python source file linting
  " let g:neomake_python_enabled_makers = ['pylint']

  " Temporary fix the SPC l i r
  let g:neoformat_python_autoflake = {
      \ 'exe': 'bash',
      \ 'args': ['-c', '"FN=\$(mktemp); cp \"%:p\" \$FN; autoflake --remove-all-unused-imports --remove-duplicate-keys --expand-star-imports --in-place \$FN; cat \$FN; rm \$FN"'],
      \ 'stdin': 0,
      \ }

  " =========== Python Layer ===========
  " Disable formatter as COC handles it
  "let g:neoformat_python_black = {
  "    \ 'exe': 'black',
  "    \ 'stdin': 1,
  "    \ 'args': ['-q', '-'],
  "    \ }
  "let g:neoformat_enabled_python = ['black']
  let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-pyright', 'coc-sh']
  let g:coc_config_home = '~/.SpaceVim.d/'

  " " =========== Vim-Rooter ===========
  " let g:rooter_patterns = ['=paper', '=prod', '=lib']
  " let g:rooter_cd_cmd = 'cd'
  " let g:rooter_resolve_links = 1

  " =========== File Types ===========
  " for this filet types, wrap the text
  augroup custom_autocmd
    au!
    " au FileType text,md,markdown setlocal textwidth=78
    " au FileType text,md,markdown setlocal wrap
    au BufRead,BufNewFile *.txt,*.tex,*.md set wrap linebreak nolist textwidth=0 wrapmargin=0
  augroup END

  " " alternative files
  " augroup myspacevim
  "   autocmd!
  "   autocmd BufNewFile,BufEnter *.py let b:alternate_file_config = {
  "       \ "src/*.py" : {
  "           \ "doc" : "docs/{}.md",
  "           \ "alternate" : "test/{}.py",
  "           \ }
  "       \ }
  "  augroup END

  " =========== SpaceVim General Settings ===========
  " Copy to remote clipboard
  set clipboard=unnamed
  vnoremap <Leader>y :'<,'>write! >> /tmp/vim_clipboard.tempfile <enter> <bar> : !transfer_tempfile_to_local_clipboard <enter> <bar> : !rm -f /temp/vim_clipboard.tempfile <enter>

  " =========== NerdTree ===========
  let g:NERDTreeQuitOnOpen = 1
  " Make all nerdtree instance to be the same
  function! ToggleNERDTree()
    NERDTreeToggle
    silent NERDTreeMirror
  endfunction
  " TODO - MAP the new functino to SPC

  " =========== PyDocString DOQ ===========
  let g:pydocstring_doq_path = '/opt/conda/bin/doq'
  let g:pydocstring_formatter = 'numpy'

  " =========== Tmux Navigator Settings ===========
  " " Preview docstring in fold text
  " let g:SimpylFold_docstring_preview = 0
  " " Fold docstrings
  " let g:SimpylFold_fold_docstring = 1
  " let g:SimpylFold_fold_import = 1
  " " old trailing blank lines
  " let g:SimpylFold_fold_blank = 0

  " =========== Python iSort Settings ===========
  let g:vim_isort_config_overrides = {
  \ 'include_trailing_comma': 1, 'multi_line_output': 3}
  let g:vim_isort_python_version = 'python3'
  let g:vim_isort_map = ''

  "" =========== Ultisnips Settings ===========
  "  "ultisnips
  "let g:snips_author = "Peter Lee"
  "let g:snips_email = "mr.peter.lee@finclab.com"
  "let g:snips_github = "https://github.com/mrpeterlee"

  "let g:UltiSnipsExpandTrigger               <c-7>
  "let g:UltiSnipsListSnippets                <c-8>
  "let g:UltiSnipsJumpForwardTrigger          <c-9>
  "let g:UltiSnipsJumpBackwardTrigger         <c-0>

  " =========== Vim-Tmux Navigator Settings ===========
  let g:tmux_navigator_no_mappings = 1
  " Move between Vim windows and Tmux panes
  " - It requires the corresponding configuration into Tmux.
  " - Check it at my .tmux.conf from my dotfiles repository.
  " - URL: https://github.com/gerardbm/dotfiles/blob/master/tmux/.tmux.conf
  " - Plugin required: https://github.com/christoomey/vim-tmux-navigator
  " nnoremap <silent> <M-h> :TmuxNavigateLeft<CR>
  " nnoremap <silent> <M-j> :TmuxNavigateDown<CR>
  " nnoremap <silent> <M-k> :TmuxNavigateUp<CR>
  " nnoremap <silent> <M-l> :TmuxNavigateRight<CR>


  " =========== ALE Linter ===========
  let g:ale_linters_explicit = 1
  let g:ale_linters = {
      \ 'python': ['pyright'],
      \ }

  " =========== Pydocstring ===========
  let g:pydocstring_doq_path = '/opt/conda/bin/doq'
  let g:pydocstring_formatter = 'numpy'

  " =========== Github Settings ===========
  " func! myspacevim#before() abort
  let g:github_dashboard = { 'username': 'mrpeterlee', 'password': $github_access_token }
  let g:gista#client#default_username = 'mrpeterlee'

  " =========== AutoFlake Settings ===========
  " See https://github.com/tell-k/vim-autoflake
  " Register hotkey F9
  autocmd FileType python map <buffer> <F9> :call Autoflake()<CR>
  " Remove all unused imports
  let g:autoflake_remove_all_unused_imports=1
  " Disable show diff window
  let g:autoflake_disable_show_diff=1


  " =========== My Settings ===========
  " Use rg instead of grep
  if executable("rg")
      set grepprg=rg\ --vimgrep
  endif

  let g:node_client_debug = 1

endf
