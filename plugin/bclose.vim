" From
" https://vim.fandom.com/wiki/Deleting_a_buffer_without_closing_the_window
" (alt url: http://vim.wikia.com/wiki/VimTip165)

" Command ':Bclose' executes ':bw' to delete the buffer in current window.
" All windows showing the current buffer will show the alternate buffer
" (Ctrl-^) if it exists, or the previous buffer (:bp), or a blank buffer if
" no previous.
function s:Bclose(kwbdStage)
  " This is a more exotic version of the original bclose script.  It
  " deletes the buffer, keeps windows, and creates a scratch buffer if no
  " buffers are left.
  if(a:kwbdStage == 2)
    if(bufnr("%") == s:kwbdBufNum)
      let prevbufvar = bufnr("#")
      if(prevbufvar > 0 && buflisted(prevbufvar) && prevbufvar != s:kwbdBufNum)
        b #
      else
        bn
      endif
    endif
    return
  endif

  if(&modified)
    let answer = confirm("This buffer has been modified.  Are you sure you want to delete it?", "&Yes\n&No", 2)
    if(answer != 1)
      return
    endif
  endif
  if(!buflisted(winbufnr(0)))
    bw!
    return
  endif
  let s:kwbdBufNum = bufnr("%")
  let s:kwbdWinNum = winnr()
  windo call s:Bclose(2)
  execute s:kwbdWinNum . 'wincmd w'
  let s:buflistedLeft = 0
  let s:bufFinalJump = 0
  let l:nBufs = bufnr("$")
  let l:i = 1
  while(l:i <= l:nBufs)
    if(l:i != s:kwbdBufNum)
      if(buflisted(l:i))
        let s:buflistedLeft = s:buflistedLeft + 1
      else
        if(bufexists(l:i) && !strlen(bufname(l:i)) && !s:bufFinalJump)
          let s:bufFinalJump = l:i
        endif
      endif
    endif
    let l:i = l:i + 1
  endwhile
  if(!s:buflistedLeft)
    if(s:bufFinalJump)
      windo if(buflisted(winbufnr(0))) | execute "b! " . s:bufFinalJump | endif
    else
      enew
      let l:newBuf = bufnr("%")
      windo if(buflisted(winbufnr(0))) | execute "b! " . l:newBuf | endif
    endif
    execute s:kwbdWinNum . 'wincmd w'
  endif
  if(buflisted(s:kwbdBufNum) || s:kwbdBufNum == bufnr("%"))
    execute "bw! " . s:kwbdBufNum
  endif
  if(!s:buflistedLeft)
    set buflisted
    set bufhidden=delete
    set buftype=
    setlocal noswapfile
  endif
endfunction

command! Bclose call s:Bclose(1)
nnoremap <silent> <Plug>Bclose :<C-u>Bclose<CR>

" Create a mapping (e.g. in your .vimrc) like this:
"nmap <C-W>! <Plug>Bclose
