
" SECTION: variables {{{1
let s:selection_opt = ""
let s:selection_lst = []
let s:selection_dic = {}
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

" FUNCTION: popset#selection#SelectionDict() {{{
function! popset#selection#SelectionDict()
    return s:selection_dic
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
    let [s:selection_lst, s:selection_dic, s:selection_cmd] = popset#data#GetSelectionsAndCommand(a:psoption)
    if (empty(s:selection_lst) || s:selection_cmd == "")
        echo "'" . a:psoption "' is not surpported at present!"
        return
    endif
    call popset#pop#PopSelection()
endfunction
" }}}

" function! popset#selection#Content() {{{
" return buffer text and buffer text lines
function! popset#selection#Content()
    let l:size = len(s:selection_lst)
    let l:text = ""
    let l:winwid = &columns
    let l:maxkeywid = 0

    " get max key text width
    for t in s:selection_lst
        let l:keywid = strwidth(t)
        let l:maxkeywid = (l:keywid > l:maxkeywid) ? l:keywid : l:maxkeywid
    endfor
    " add 3 space width to maxkeywid
    let l:maxkeywid += 3

    " create and tabular buffer text
    for t in s:selection_lst
        let l:linetext = "   " . t
        if has_key(s:selection_dic, t)
            let l:linetext .= repeat(' ', l:maxkeywid - strwidth(l:linetext)) . " : "
            let l:linetext .= s:selection_dic[t]
        endif
        let l:linetext .= repeat(' ', l:winwid - strwidth(l:linetext) + 1)
        let l:text .= l:linetext . "\n"
    endfor
    return [l:text, l:size]
endfunction
" }}}

