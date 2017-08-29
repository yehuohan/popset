
" SECTION: variables {{{1
let s:selection_opt = ""
let s:selection_lst = []
let s:selection_cmd = ""

" SETCION: functions {{{1

" FUNCTION: popset#selection#SelectionOption() {{{
function! popset#selection#SelectionOption()
    return s:selection_opt
endfunction
" }}}

" FUNCTION: popset#selection#SelectionList() {{{
function! popset#selection#SelectionList()
    return s:selection_lst
endfunction
" }}}

" FUNCTION: popset#selection#SelectionCommand() {{{
function! popset#selection#SelectionCommand()
    return s:selection_cmd
endfunction
" }}}

" FUNCTION: popset#selection#SetOption() {{{
function! popset#selection#SetOption(psoption) 
    let s:selection_opt = a:psoption
    let [s:selection_lst, s:selection_cmd] = popset#data#GetSelectionsAndCommand(a:psoption)
    if (empty(s:selection_lst) || s:selection_cmd == "")
        return
    endif
    call popset#pop#PopSelection()
endfunction
" }}}

" function! popset#selection#Content() {{{
function! popset#selection#Content()
    let l:size = len(s:selection_lst)
    let l:text = ""
    let l:wid = &columns
    for t in s:selection_lst
        let l:linetext = "   " . t
        let l:linetext .= repeat(' ', l:wid - strwidth(l:linetext) + 1)
        let l:text .= l:linetext . "\n"
    endfor
    return [l:text, l:size]
endfunction
" }}}

