" Fix key mapping issues for GUI
inoremap <silent> <S-Insert>  <C-R>+
cnoremap <S-Insert> <C-R>+
nnoremap <silent> <C-6> <C-^>

set guifont=FiraMono\ Nerd\ Font:h16

" set to 1, nvim will open the preview window after entering the markdown buffer
let g:mkdp_auto_start = 1
" set to 1, the nvim will auto close current preview window when change
" from markdown buffer to another buffer
let g:mkdp_auto_close = 1

" " Better window navigation
imap <C-h> <Esc>:lua require('smart-splits').move_cursor_left()<CR>
imap <C-j> <Esc>:lua require('smart-splits').move_cursor_down()<CR>
imap <C-k> <Esc>:lua require('smart-splits').move_cursor_up()<CR>
imap <C-l> <Esc>:lua require('smart-splits').move_cursor_right()<CR>

" resizing splits
" nmap <C-Left> :lua require('smart-splits').resize_left()<CR>
" nmap <C-Down> :lua require('smart-splits').resize_down()<CR>
" nmap <C-Up> :lua require('smart-splits').resize_up()<CR>
" nmap <C-Right> :lua require('smart-splits').resize_right()<CR>

set termguicolors
let g:terminal_color_0 = '#7f7f8c'
let g:terminal_color_1 = '#cd5c5c'
let g:terminal_color_2 = '#9acd32'
let g:terminal_color_3 = '#bdb76b'
let g:terminal_color_4 = '#75a0ff'
let g:terminal_color_5 = '#eeee00'
let g:terminal_color_6 = '#cd853f'
let g:terminal_color_7 = '#666666'
let g:terminal_color_8 = '#8a7f7f'
let g:terminal_color_9 = '#ff0000'
let g:terminal_color_10 = '#89fb98'
let g:terminal_color_11 = '#f0e68c'
let g:terminal_color_12 = '#6dceeb'
let g:terminal_color_13 = '#ffde9b'
let g:terminal_color_14 = '#ffa0a0'
let g:terminal_color_15 = '#c2bfa5'




if exists('g:fvim_loaded')

  " colorscheme gruvbox8_hard

  " CTRL-Scroll Wheel for zooming in/out
  nnoremap <silent> <C-ScrollWheelUp> :set guifont=+<CR>
  nnoremap <silent> <C-ScrollWheelDown> :set guifont=-<CR>
  nnoremap <A-CR> :FVimToggleFullScreen<CR>

  " good old 'set guifont' compatibility with HiDPI hints...
  if g:fvim_os == 'windows' || g:fvim_render_scale > 1.0
    set guifont=FiraCode\ NF\ Retina:h16
  else
    set guifont=FiraCode\ NF\ Retina:h12
  endif
 
  " Cursor tweaks
  FVimCursorSmoothMove v:true
  FVimCursorSmoothBlink v:true

  " Background composition, can be 'none', 'blur' or 'acrylic'
  FVimBackgroundComposition 'blur'
  FVimBackgroundOpacity 0.95
  FVimBackgroundAltOpacity 0.95

  " Title bar tweaks (themed with colorscheme)
  FVimCustomTitleBar v:false

  " Debug UI overlay
  FVimDrawFPS v:false
  " Font debugging -- draw bounds around each glyph
  FVimFontDrawBounds v:false

  " Font tweaks
  FVimFontAntialias v:true
  FVimFontAutohint v:true
  FVimFontHintLevel 'full'
  FVimFontSubpixel v:true
  FVimFontLigature v:true
  " can be 'default', '14.0', '-1.0' etc.
  FVimFontLineHeight '0'

  " Try to snap the fonts to the pixels, reduces blur
  " in some situations (e.g. 100% DPI).
  FVimFontAutoSnap v:true

  " Font weight tuning, possible values are 100..900
  FVimFontNormalWeight 100
  FVimFontBoldWeight 700

  FVimUIPopupMenu v:false
endif

" Load last session
SessionManager! load_current_dir_session

autocmd VimLeave * SessionManager! save_current_session
