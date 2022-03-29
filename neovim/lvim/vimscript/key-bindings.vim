" Insert a blank line below or above current line (do not move the cursor),
" see https://stackoverflow.com/a/16136133/6064933
nnoremap <expr> <Space>o printf('m`%so<ESC>``', v:count1)
nnoremap <expr> <Space>O printf('m`%sO<ESC>``', v:count1)

" Move the cursor based on physical lines, not the actual lines.
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')

" Tab-complete, see https://vi.stackexchange.com/q/19675/15292.
inoremap <expr> <tab> pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"

" Reselect the text that has just been pasted, see also https://stackoverflow.com/a/4317090/6064933.
" nnoremap <expr> <leader>v printf('`[%s`]', getregtype()[0])

" Search in selected region
" xnoremap / :<C-U>call feedkeys('/\%>'.(line("'<")-1).'l\%<'.(line("'>")+1)."l")

" Use Esc to quit builtin terminal
tnoremap <ESC>   <C-\><C-n>

" " Break inserted text into smaller undo units.
" for ch in [',', '.', '!', '?', ';', ':']
"   execute printf('inoremap %s %s<C-g>u', ch, ch)
" endfor

augroup restore_after_yank
  autocmd!
  autocmd TextYankPost *  call s:restore_cursor()
augroup END

function! s:restore_cursor() abort
  silent! normal `y
  silent! delmarks y
endfunction
