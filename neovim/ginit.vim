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
let g:terminal_color0 = "#3b4252"
let g:terminal_color1 = "#BF616A "
let g:terminal_color2 = "#A3B38C"
let g:terminal_color3 = "#D08770"
let g:terminal_color4 = "#5E81AC"
let g:terminal_color5 = "#B48EAD"
let g:terminal_color6 = "#88C0D0"
let g:terminal_color7 = "#81A1C1"
" bright
let g:terminal_color8 = "#4C566A"
let g:terminal_color9 = "#BF616A"
let g:terminal_color10 = "#A3B38C"
let g:terminal_color11 = "#D08770"
let g:terminal_color12 = "#5E81AC"
let g:terminal_color13 = "#B48EAD"
let g:terminal_color14 = "#88C0D0"
let g:terminal_color15 = "#E5E9F0"

if exists('g:fvim_loaded')

  set termguicolors
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

