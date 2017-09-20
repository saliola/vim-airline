" MIT License. Copyright (c) 2015 Franco Saliola

let s:filetypes = get(g:, 'airline#extensions#charcount#filetypes', '\vhelp|markdown|rst|org')

" adapted from wordcount.vim, which was adapted from
" http://stackoverflow.com/questions/114431/fast-word-count-function-in-vim
function! s:update()
  if &ft !~ s:filetypes
    unlet! b:airline_charcount
    return
  endif

  let s:countspaces = get(g:, 'airline#extensions#charcount#countspaces', 0)

  " save the current statusmsg, search register and position
  let current_status = v:statusmsg
  let current_searchregister = @/
  let current_position = getpos(".")

  " count (non-whitespace) characters (\S matches a non-whitespace character)
  " and read number of characters from v:statusmsg
  if s:countspaces
    try
      silent execute "%s/.//gn"
      let cnt = str2nr(split(v:statusmsg)[0])
    catch E486
      let cnt = 0
    endtry
  else
    try
      silent execute "%s/\\S//gn"
      let cnt = str2nr(split(v:statusmsg)[0])
    catch E486
      let cnt = 0
    endtry
  endif

  " restore the statusmsg, search register and position
  let v:statusmsg = current_status
  let @/ = current_searchregister
  call setpos('.', current_position)

  " set the status line message
  let spc = g:airline_symbols.space
  let b:airline_charcount = cnt . spc . 'chars' . spc . g:airline_right_alt_sep . spc
endfunction

function! airline#extensions#charcount#apply(...)
  if &ft =~ s:filetypes
    call airline#extensions#prepend_to_section('z', '%{get(b:, "airline_charcount", "")}')
  endif
endfunction

function! airline#extensions#charcount#init(ext)
  call a:ext.add_statusline_func('airline#extensions#charcount#apply')
  autocmd BufReadPost,BufWritePost,CursorMoved,CursorMovedI * call s:update()
endfunction

