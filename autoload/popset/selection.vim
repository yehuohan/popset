
" SECTION: variables {{{1

" Set all the following selection_* variables before call function of pop.vim
let s:selection_opt = ""            " what option to set
let s:selection_lst = []            " what selections to choose for option
let s:selection_dic = {}            " what information to show for selections
let s:selection_cmd = ""            " what command to execute for selected selection
let s:selection_cmd_args = []       " the command extra args
let s:selection_cmd_args_flag = 0   " the command extra args flag
let s:selection_msg = ""            " what message to show in status line
let s:selection_pre = 1             " whether allow preview


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

" FUNCTION: popset#selection#SeletionCommandArgsFlag() {{{
function! popset#selection#SeletionCommandArgsFlag()
    return s:selection_cmd_args_flag
endfunction
"}}}

" FUNCTION: popset#selection#SeletionCommandArgs() {{{
function! popset#selection#SeletionCommandArgs()
    return s:selection_cmd_args
endfunction
"}}}

" FUNCTION: popset#selection#SelectionMessage() {{{
function! popset#selection#SelectionMessage()
    return s:selection_msg
endfunction
" }}}

" FUNCTION: popset#selection#SelectionPreviewAllowed() {{{
function! popset#selection#SelectionPreviewAllowed()
    return s:selection_pre
endfunction
" }}}

" FUNCTION: popset#selection#SetOption() {{{
" psoption: the option in data.vim
function! popset#selection#SetOption(psoption)
    let s:selection_opt = a:psoption
    let [s:selection_lst, s:selection_dic, s:selection_cmd] = popset#data#GetSelectionsAndCommand(a:psoption)
    let s:selection_cmd_args_flag = 0
    let s:selection_pre = ("popset" == s:selection_opt) ? 0 : 1

    if (empty(s:selection_lst) || s:selection_cmd == "")
        echo "'" . a:psoption "' is not surpported at present!"
        return
    endif

    let l:value = popset#data#GetOptionValue(s:selection_opt, s:selection_cmd)
    let s:selection_msg = s:selection_opt
    if !empty(l:value)
        let s:selection_msg .= " = " . l:value
    endif

    call popset#pop#PopSelection()
endfunction
" }}}

" FUNCTION: popset#selection#SetOptionDict(dict) {{{
" @param dict: A dictionary in followint format,
"               {
"                   \ "opt" : [],
"                   \ "lst" : [],
"                   \ "dic" : {},
"                   \ "cmd" : "",
"               }
"               where dic is not necessary.
" @param preview: Is the command surpport preview or not.
" @param flag: Have extra args or not.
" @param args: The args list to cmd.
function! popset#selection#SetOptionDict(dict, preview, flg, args) 
    let s:selection_opt = a:dict['opt'][0]
    let s:selection_lst = a:dict['lst']
    let s:selection_dic = has_key(a:dict, 'dic') ? a:dict['dic'] : {}
    let s:selection_cmd = a:dict['cmd']
    let s:selection_cmd_args_flag = a:flg
    let s:selection_cmd_args = a:args
    let s:selection_msg = s:selection_opt
    let s:selection_pre = a:preview

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

