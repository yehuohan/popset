
" SECTION: variables {{{1
" s:popset_data format
" {opt1: [ [lst], {dic}, "cmd"],
"  opt2: [ [lst], {dic}, "cmd"],
"  ......
" }
let s:popset_data = {}


" SETCION: functions {{{1

" FUNCTION: popset#data#Init() {{{
function! popset#data#Init()
    for data in s:popset_selection_data
        call popset#data#AddSelectionsAndComand(data["opt"], data["lst"], data["dic"], data["cmd"])
    endfor
    if exists("g:Popset_SelectionData")
        for data in g:Popset_SelectionData
            call popset#data#AddSelectionsAndComand(data["opt"], data["lst"], data["dic"], data["cmd"])
        endfor
    endif
endfunction
" }}}

" FUNCTION: popset#data#OptionList(arglead, cmdline, cursorpos) {{{
" for PSet complete
function! popset#data#GetOptionList(arglead, cmdline, cursorpos)
    let l:completekeys = []

    " search fitable args
    for key in keys(s:popset_data)
        if key =~ "^".a:arglead
            let l:completekeys = add(l:completekeys, key)
        endif
    endfor

    return l:completekeys
endfunction
" }}}

" FUNCTION: popset#data#AddSelectionsAndComand(sopt, slist, sdict, scmd) {{{
function! popset#data#AddSelectionsAndComand(sopt, slist, sdict, scmd)
    for t in a:sopt
        let s:popset_data[t] = [a:slist, a:sdict, a:scmd]
    endfor
endfunction
" }}}

" FUNCTION: popset#data#GetSelectionsAndCommand(psoption) {{{
" return [list, dict, cmd]
function! popset#data#GetSelectionsAndCommand(psoption)
    if has_key(s:popset_data, a:psoption)
        return s:popset_data[a:psoption]
    else
        return [[], {}, ""]
    endif
endfunction
" }}}


" SECTION: popset data {{{1
let s:popset_selection_data = [
    \{
        \ "opt" : ["foldmethod", "fdm"],
        \ "lst" : ["manual", "indent", "expr", "marker", "syntax", "diff"],
        \ "dic" : {
                \ "manual" : "Folds are created manually.",
                \ "indent" : "Lines with equal indent form a fold.",
                \ "expr"   : "'foldexpr' gives the fold level of a line.",
                \ "marker" : "Markers are used to specify folds.",
                \ "syntax" : "Syntax highlighting items specify folds.",
                \ "diff"   : "Fold text that is not changed.",
                \},
        \ "cmd" : "popset#data#SetEqual",
    \},
    \]

function! popset#data#SetEqual(sopt, arg)
    execute "set " . a:sopt . "=" . a:arg
endfunction
