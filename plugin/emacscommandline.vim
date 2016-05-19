" Make more like emacs
cnoremap <C-a> <Home>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <Esc>r <C-F>?
cmap <M-r> <Esc>r

" Maps to old shortcuts using Ctrl-O as a prefix
cnoremap <C-o><C-a>      <C-a>
cnoremap <C-o><C-e>      <C-e>
cnoremap <C-o><C-b>      <C-b>
cnoremap <C-o><C-f>      <C-f>
cnoremap <C-o><C-p>      <C-p>
cnoremap <C-o><C-d>      <C-d>
cnoremap <C-o><C-k>      <C-k>
cnoremap <C-o><C-u>      <C-u>
cnoremap <C-o><C-w>      <C-w>
cnoremap <C-o><C-y>      <C-y>
cnoremap <C-o><C-z>      <C-z>
cnoremap <C-o><C-_>      <C-_>
cnoremap <C-o><C-x><C-u> <C-x><C-u>
cnoremap <C-o><Del>      <Del>
cnoremap <C-o><BS>       <BS>

cnoremap <Esc>f <C-\>e<SID>ForwardWord()<CR>
cmap <M-f> <Esc>f
cnoremap <Esc>b <C-\>e<SID>BackwardWord()<CR>
cmap <M-b> <Esc>b
cnoremap <Del> <C-\>e<SID>DeleteChar()<CR>
cmap <C-d> <Del>
cnoremap <BS> <C-\>e<SID>BackwardDeleteChar()<CR>
cnoremap <C-k> <C-\>e<SID>KillLine()<CR>
cnoremap <C-u> <C-\>e<SID>BackwardKillLine()<CR>
cnoremap <Esc>d <C-\>e<SID>KillWord()<CR>
cmap <M-d> <Esc>d
cnoremap <C-w> <C-\>e<SID>DeleteBackwardsToWhiteSpace()<CR>
cnoremap <Esc><BS> <C-\>e<SID>BackwardKillWord()<CR>
cmap <M-BS> <Esc><BS>
cnoremap <C-y> <C-\>e<SID>Yank()<CR>
cnoremap <C-z> <C-\>e<SID>ToggleExternalCommand()<CR>
cnoremap <C-_> <C-\>e<SID>Undo()<CR>
cmap <C-x><C-u> <C-_>

function! <SID>ForwardWord()
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:roc =~ '\v^\s*\w')
        let l:rem = matchstr(l:roc, '\v^\s*\w+')
    elseif (l:roc =~ '\v^\s*[^[:alnum:]_[:blank:]]')
        let l:rem = matchstr(l:roc, '\v^\s*[^[:alnum:]_[:blank:]]+')
    else
        call setcmdpos(strlen(getcmdline()) + 1)
        return getcmdline()
    endif
    call setcmdpos(strlen(l:loc) + strlen(l:rem) + 1)
    return getcmdline()
endfunction

function! <SID>BackwardWord()
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:loc =~ '\v\w\s*$')
        let l:rem = matchstr(l:loc, '\v\w+\s*$')
    elseif (l:loc =~ '\v[^[:alnum:]_[:blank:]]\s*$')
        let l:rem = matchstr(l:loc, '\v[^[:alnum:]_[:blank:]]+\s*$')
    else
        call setcmdpos(1)
        return getcmdline()
    endif
    let @c = l:rem
    call setcmdpos(strlen(l:loc) - strlen(l:rem) + 1)
    return getcmdline()
endfunction

function! <SID>DeleteChar()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:cmd     = getcmdline()
    " Get length of character to be deleted (in bytes)
    let l:charlen = strlen(substitute(strpart(l:cmd, getcmdpos() - 1), '^\(.\).*', '\1', ''))
    let l:rem     = strpart(l:cmd, getcmdpos() - 1, l:charlen)
    if ('' != l:rem)
        let @c = l:rem
    endif
    let l:ret = strpart(l:cmd, 0, getcmdpos() - 1) . strpart(l:cmd, getcmdpos() + l:charlen - 1)
    call <SID>saveUndoHistory(l:ret, getcmdpos())
    return l:ret
endfunction

function! <SID>BackwardDeleteChar()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    if (getcmdpos() < 2)
        return getcmdline()
    endif
    let l:cmd     = getcmdline()
    " Get length of character to be deleted (in bytes)
    let l:charlen = strlen(substitute(strpart(l:cmd, 0, getcmdpos() - 1), '.*\(.\)$', '\1', ''))
    let l:pos     = getcmdpos() - l:charlen
    let l:rem     = strpart(l:cmd, getcmdpos() - l:charlen - 1, l:charlen)
    let @c        = l:rem
    let l:ret     = strpart(l:cmd, 0, l:pos - 1) . strpart(l:cmd, getcmdpos() - 1)
    call <SID>saveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

function! <SID>KillLine()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:cmd = getcmdline()
    let l:rem = strpart(l:cmd, getcmdpos() - 1)
    if ('' != l:rem)
        let @c = l:rem
    endif
    let l:ret = strpart(l:cmd, 0, getcmdpos() - 1)
    call <SID>saveUndoHistory(l:ret, getcmdpos())
    return l:ret
endfunction

function! <SID>BackwardKillLine()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:cmd = getcmdline()
    let l:rem = strpart(l:cmd, 0, getcmdpos() - 1)
    if ('' != l:rem)
        let @c = l:rem
    endif
    let l:ret = strpart(l:cmd, getcmdpos() - 1)
    call <SID>saveUndoHistory(l:ret, 1)
    call setcmdpos(1)
    return l:ret
endfunction

function! <SID>KillWord()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:roc =~ '\v^\s*\w')
        let l:rem = matchstr(l:roc, '\v^\s*\w+')
    elseif (l:roc =~ '\v^\s*[^[:alnum:]_[:blank:]]')
        let l:rem = matchstr(l:roc, '\v^\s*[^[:alnum:]_[:blank:]]+')
    elseif (l:roc =~ '\v^\s+$')
        let @c = l:roc
        return l:loc
    else
        return getcmdline()
    endif
    let @c = l:rem
    let l:ret = l:loc . strpart(l:roc, strlen(l:rem))
    call <SID>saveUndoHistory(l:ret, getcmdpos())
    return l:ret
endfunction

function! <SID>DeleteBackwardsToWhiteSpace()
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:loc =~ '\v\S\s*$')
        let l:rem = matchstr(l:loc, '\v\S+\s*$')
    elseif (l:loc =~ '\v^\s+$')
        let @c = l:loc
        call setcmdpos(1)
        return l:roc
    else
        return getcmdline()
    endif
    let @c = l:rem
    let l:pos = getcmdpos() - strlen(l:rem)
    let l:ret = strpart(l:loc, 0, strlen(l:loc) - strlen(l:rem)) . l:roc
    call <SID>saveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

function! <SID>BackwardKillWord()
    " Do same as in-built Ctrl-W, except assign deleted text to @c
    call <SID>saveUndoHistory(getcmdline(), getcmdpos())
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:loc =~ '\v\w\s*$')
        let l:rem = matchstr(l:loc, '\v\w+\s*$')
    elseif (l:loc =~ '\v[^[:alnum:]_[:blank:]]\s*$')
        let l:rem = matchstr(l:loc, '\v[^[:alnum:]_[:blank:]]+\s*$')
    elseif (l:loc =~ '\v^\s+$')
        let @c = l:loc
        call setcmdpos(1)
        return l:roc
    else
        return getcmdline()
    endif
    let @c = l:rem
    let l:pos = getcmdpos() - strlen(l:rem)
    let l:ret = strpart(l:loc, 0, strlen(l:loc) - strlen(l:rem)) . l:roc
    call <SID>saveUndoHistory(l:ret, l:pos)
    call setcmdpos(l:pos)
    return l:ret
endfunction

function! <SID>Yank()
    let l:cmd = getcmdline()
    call setcmdpos(getcmdpos() + strlen(@c))
    return strpart(l:cmd, 0, getcmdpos() - 1) . @c . strpart(l:cmd, getcmdpos() - 1)
endfunction

function! <SID>ToggleExternalCommand()
    let l:cmd = getcmdline()
    if ('!' == strpart(l:cmd, 0, 1))
        call setcmdpos(getcmdpos() - 1)
        return strpart(l:cmd, 1)
    else
        call setcmdpos(getcmdpos() + 1)
        return '!' . l:cmd
    endif
endfunction

let s:oldcmdline = [ ]
function! <SID>saveUndoHistory(cmdline, cmdpos)
    if len(s:oldcmdline) == 0 || a:cmdline != s:oldcmdline[0][0]
        call insert(s:oldcmdline, [ a:cmdline, a:cmdpos ], 0)
    else
        let s:oldcmdline[0][1] = a:cmdpos
    endif
    if len(s:oldcmdline) > 100
        call remove(s:oldcmdline, 100)
    endif
endfunction

function! <SID>Undo()
    if len(s:oldcmdline) == 0
        return getcmdline()
    endif
    if getcmdline() == s:oldcmdline[0][0]
        call remove(s:oldcmdline, 0)
        if len(s:oldcmdline) == 0
            return getcmdline()
        endif
    endif
    let l:ret = s:oldcmdline[0][0]
    call setcmdpos(s:oldcmdline[0][1])
    call remove(s:oldcmdline, 0)
    return l:ret
endfunction

