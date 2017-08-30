

" SECTION: variables {{{1
let s:configuration = {
    \ "DataPath"            : "",
    \ "CompleteAll"         : 0,
    \ "KeyQuit"             : ["q", "Esc"],
    \ "KeyMoveCursorDown"   : ["j"],
    \ "KeyMoveCursorUp"     : ["k"],
    \ "KeyMoveCursorPgDown" : ["C-j"],
    \ "KeyMoveCursorPgUp"   : ["C-k"],
    \ "KeyApplySelection"   : ["CR"],
    \ "KeyPreviewSelection" : ["Space"],
    \ "KeyShowHelp"         : ["?"],
    \ }


" SECTION: functions {{{1

" FUNCTION: s:initConfiguration() {{{
function! s:initConfiguration()
    " set confiuration with user's settings
    for k in keys(s:configuration)
        if exists("g:Popset_" . k)
            let s:configuration[k] = g:{"Popset_" . k} 
        endif
    endfor
endfunction
" }}}

" FUNCTION: popset#config#Configuration() {{{
function! popset#config#Configuration()
    return s:configuration
endfunction
" }}}


" SECTION: init code {{{1
call s:initConfiguration()
