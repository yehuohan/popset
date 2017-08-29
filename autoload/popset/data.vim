
" SECTION: variables {{{1
" s:popset_data format
" {opt1: [ [lst], "cmd"],
"  opt2: [ [lst], "cmd"],
"  ......
" }
let s:popset_data = {}



" SETCION: functions {{{1

" FUNCTION: popset#data#Init() {{{
function! popset#data#Init()
    for data in s:popset_selection_data
        call popset#data#AddSelectionsAndComand(data["opt"], data["lst"], data["cmd"])
    endfor
    if exists("g:Popset_SelectionData")
        for data in g:Popset_SelectionData
            call popset#data#AddSelectionsAndComand(data["opt"], data["lst"], data["cmd"])
        endfor
    endif
endfunction
" }}}

" FUNCTION: popset#data#OptionList(A,L,P) {{{
" for PSet complete
function! popset#data#GetOptionList(A,L,P)
    return sort(keys(s:popset_data))
endfunction
" }}}

" FUNCTION: popset#data#AddSelectionsAndComand(sopt, slist, scmd) {{{
" add slist as selections and scmd function string
function! popset#data#AddSelectionsAndComand(sopt, slist, scmd)
    for t in a:sopt
        let s:popset_data[t] = [a:slist, a:scmd]
    endfor
endfunction
" }}}

" FUNCTION: popset#selection#GetSelectionsAndCommand(psoption) {{{
" return [dict, cmd]
function! popset#data#GetSelectionsAndCommand(psoption)
    if has_key(s:popset_data, a:psoption)
        return s:popset_data[a:psoption]
    else
        echo "'" . a:psoption "' is not surpported at present!"
        return [[], ""]
    endif
endfunction
" }}}



" SECTION: popset data {{{1
let s:popset_selection_data = [
    \{
        \ "opt" : ["foldmethod", "fdm"],
        \ "lst" : ["manual", "indent", "expr", "marker", "syntax", "diff"],
        \ "cmd" : "popset#data#SetEqual",
    \},
    \]

function! popset#data#SetEqual(sopt, arg)
    execute "set " . a:sopt . "=" . a:arg
endfunction
