

" SECTION: variables {{{1
let s:config = popset#config#Configuration()
let b:text = ""
let b:size = -1
let s:last_winnr = -1
let s:is_helptext = 0
let s:is_datalist = 0


" SETCION: functions {{{1

" FUNCTION: popset#pop#InitPopKeys() {{{
function! popset#pop#InitPopKeys()
    call popset#key#AddMaps("popset#pop#Quit"             , s:config["KeyQuit"])
    call popset#key#AddMaps("popset#pop#MoveCursor"       , s:config["KeyMoveCursorDown"]    , "down")
    call popset#key#AddMaps("popset#pop#MoveCursor"       , s:config["KeyMoveCursorUp"]      , "up")
    call popset#key#AddMaps("popset#pop#MoveCursor"       , s:config["KeyMoveCursorPgDown"]  , "pgdown")
    call popset#key#AddMaps("popset#pop#MoveCursor"       , s:config["KeyMoveCursorPgUp"]    , "pgup")
    call popset#key#AddMaps("popset#pop#ApplySelection"   , s:config["KeyApplySelection"])
    call popset#key#AddMaps("popset#pop#PreviewSelection" , s:config["KeyPreviewSelection"])
    call popset#key#AddMaps("popset#pop#ShowHelp"         , s:config["KeyShowHelp"])
endfunction
" }}}

" FUNCTION: popset#pop#PopSelection() {{{
function! popset#pop#PopSelection()
    " note the winnr for return when kill popset
    let s:last_winnr = winnr()
    " pop selection to preview window at bottom and ignore the auto-command event
    silent! execute "noautocmd botright pedit " . popset#selection#SelectionMessage()
    " Move focus to preview window
    silent! execute "noautocmd wincmd P"

    " set options and maps of preview window
    call s:setBuffer()

    " get the content and its line-size
    let [b:text, b:size] = popset#selection#Content()

    if "popset" == popset#selection#SelectionOption()
        let s:is_datalist = 1
    else
        let s:is_datalist = 0
    endif

    " display content on preview window
    call s:displayContent()
endfunction
" }}}

" FUNCTION: s:setBuffer() {{{
function! s:setBuffer()
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal nowrap
    setlocal nonumber
    if exists('+relativenumber')
        setlocal norelativenumber
    endif
    setlocal nocursorcolumn
    setlocal nocursorline
    setlocal nospell
    setlocal nolist
    setlocal cc=
    setlocal filetype=popset

    " save timeoutlen
    if &timeout
        let b:timeoutlenSave = &timeoutlen
        set timeoutlen=10
    endif
    
    " set up syntax highlighting
    if has("syntax")
        syntax clear
        syntax match PopsetNormal /   .*/
        syntax match PopsetSelected / > .*/hs=s+1
    endif
    
    " create maps
    let keymaps = popset#key#KeyMaps()
    for k in popset#key#KeyNames()
        let l:key = strlen(k) > 1 ? ("<" . k . ">") : k
        silent! execute "noremap <silent><buffer> " . l:key . " :call " . keymaps[k] . "<CR>"
    endfor
endfunction
" }}}

" FUNCTION: s:displayContent() {{{
function! s:displayContent()
    let l:maxsize = &lines / 3
    if b:size > l:maxsize
        silent! execute "resize" l:maxsize
    else
        silent! execute "resize" b:size
    endif

    setlocal modifiable
    normal! ggdG
    silent! put! = b:text
    normal! GkJgg
    call cursor(1, 1)
    " mark current line with ' >'
    call setline(line("."), " >" . strpart(getline(line(".")), 2))
    setlocal nomodifiable
endfunction
" }}}

" FUNCTION: popset#pop#ApplySelection() {{{
function! popset#pop#ApplySelection()
    if s:is_helptext == 1
        return 
    endif
    let l:opt = popset#selection#SelectionOption()
    let l:sel = popset#selection#SelectionList()[line(".") - 1]
    let l:Cmd = function(popset#selection#SelectionCommand())
    call popset#pop#Quit()
    call l:Cmd(l:opt,l:sel)
endfunction
" }}}

" FUNCTION: popset#pop#PreviewSelection() {{{
function! popset#pop#PreviewSelection()
    if s:is_helptext == 1 || s:is_datalist == 1
        return
    endif
    let s:last_line = line(".")
    call popset#pop#ApplySelection()
    call popset#pop#PopSelection()
    " move cursor to last line
    setlocal modifiable
    call setline(line("."), "  " . strpart(getline(line(".")), 2))
    call cursor(s:last_line, 1)
    call setline(line("."), " >" . strpart(getline(line(".")), 2))
    setlocal nomodifiable
endfunction
" }}}

" FUNCTION: popset#pop#Quit() {{{
function! popset#pop#Quit()
    if s:is_helptext == 1
        let s:is_helptext = 0
        let [b:text, b:size] = popset#selection#Content()
        call s:displayContent()
    else
        if (exists("s:killingNow") && s:killingNow)
            return
        endif
        let s:killingNow = 1

        " recover timeoutlen
        if exists("b:timeoutlenSave")
            silent! execute "set timeoutlen=" . b:timeoutlenSave
        endif

        " delete buffer and all thing about the preview buffer will be wiped out
        bwipeout
        " return the previous window
        silent! execute "noautocmd " . s:last_winnr . "wincmd w"
        unlet s:killingNow
    endif
endfunction
" }}}

" FUNCTION: popset#pop#MoveCursor(direction) {{{
function! popset#pop#MoveCursor(direction)
    setlocal modifiable

    " exchange the first 2 char (' >') with spaces
    call setline(line("."), "  " . strpart(getline(line(".")), 2))

    if a:direction == 'down'
        call s:goto(line(".") + 1)
    elseif a:direction == 'up'
        call s:goto(line(".") - 1)
    elseif a:direction == 'pgup'
        let newpos = line(".") - winheight(0)
        if newpos < 1
            let newpos = 1
        endif
        call s:goto(newpos)
    elseif a:direction == 'pgdown'
        let newpos = line(".") + winheight(0)
        if newpos > line("$")
            let newpos = line("$")
        endif
        call s:goto(newpos)
    endif

    " and mark current line with ' >'
    call setline(line("."), " >" . strpart(getline(line(".")), 2))

    setlocal nomodifiable
endfunction
" }}}

" FUNCTION: s:goto(line) {{{
" tries to set the cursor to a line of the selection list
function! s:goto(line)
    if b:size < 1
        return
    endif

    if a:line < 1
        call s:goto(b:size - a:line)
    elseif a:line > b:size
        call s:goto(a:line - b:size)
    else
        call cursor(a:line, 1)
    endif
endfunction
" }}}

" FUNCTION: popset#pop#ShowHelp() {{{
function! popset#pop#ShowHelp()
    if s:is_helptext == 1
        return 
    endif
    let s:is_helptext = 1
    let [b:text, b:size] = popset#help#HelpText()
    call s:displayContent()
endfunction
" }}}
