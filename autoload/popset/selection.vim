
" SECTION: variables {{{1

" what option to set
let s:selection_opt = ""
" what selections to choose for option
let s:selection_lst = []
" what information to show for selections
let s:selection_dic = {}
" what command to execute for selected selection
let s:selection_cmd = ""
" what message to show in status line
let s:selection_msg = ""


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

" FUNCTION: popset#selection#SelectionMessage() {{{
function! popset#selection#SelectionMessage()
    return s:selection_msg
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

    let l:value = popset#data#GetOptionValue(s:selection_opt, s:selection_cmd)
    let s:selection_msg = "Popset-" . s:selection_opt
    if !empty(l:value)
        let s:selection_msg .= " : " . l:value
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
    for lst in s:selection_lst
        let l:keywid = strwidth(lst)
        let l:maxkeywid = (l:keywid > l:maxkeywid) ? l:keywid : l:maxkeywid
    endfor
    " add 3 space width to maxkeywid
    let l:maxkeywid += 3

    " create and tabular buffer text
    for lst in s:selection_lst
        let l:linetext = "   " . lst
        if has_key(s:selection_dic, lst)
            " add description of selection if it exits
            let l:linetext .= repeat(' ', l:maxkeywid - strwidth(l:linetext)) . " : "
            let l:linetext .= s:selection_dic[lst]
        endif
        let l:linetext .= repeat(' ', l:winwid - strwidth(l:linetext) + 1)
        let l:text .= l:linetext . "\n"
    endfor

    return [l:text, l:size]
endfunction
" }}}

