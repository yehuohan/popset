
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
    " generate surpported option list to s:popset_selection_data[0]
    call popset#data#GetSurpportedOptionList()

    " add popset-selection-data to popset-data
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

" FUNCTION: popset#data#AddSelectionsAndComand(sopt, slist, sdict, scmd) {{{
function! popset#data#AddSelectionsAndComand(sopt, slist, sdict, scmd)
    for item in a:sopt
        if has_key(s:popset_data, item)
            call extend(s:popset_data[item][0], a:slist)
            call extend(s:popset_data[item][1], a:sdict, "force")
            " For the same option but different name (eg. ["foldmethod", "fdm"]),
            " because they have the same "lst", "dic" and "cmd", the key will
            " point to the same data address, that means s:popset_data["foldmethod"] 
            " and s:popset_data["fdm"] pointed to same data address.
            " So, appending a:sdcit and s:scmd to only just one item of a:sopt 
            " is ok.
            return
        else
            let s:popset_data[item] = [a:slist, a:sdict, a:scmd]
        endif
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

" FUNCTION: popset#data#GetCompleteOptionList(arglead, cmdline, cursorpos) {{{
" get customelist for PSet complete 
function! popset#data#GetCompleteOptionList(arglead, cmdline, cursorpos)
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

" FUNCTION: popset#data#GetSurpportedOptionList() {{{
" get all options surpported by popset
function! popset#data#GetSurpportedOptionList()
    " get internal option list
    let l:lst = []
    for item in range(1, len(s:popset_selection_data)-1)
        call extend(l:lst, s:popset_selection_data[item]["opt"])
    endfor

    " convert internal option list to string for search with matchstr
    "let l:lst_string = '|' . join(l:lst, '|') . '|'

    if exists("g:Popset_SelectionData")
        " add no-reduplicated user's option to list
        for item in g:Popset_SelectionData
            for str in item["opt"]
                " if internal list had not include user's option yet
                if -1 == match(l:lst, '^' . str . '$')
                "if "" == matchstr(l:lst_string, '|' . str . '|')
                    let l:lst = add(l:lst, str)
                endif
            endfor
        endfor
    endif
    let s:popset_selection_data[0]["lst"] = l:lst
endfunction
" }}}

" SECTION: popset selection functions {{{1

" FUNCTION: popset#data#SetEqual(sopt, arg) {{{
function! popset#data#SetEqual(sopt, arg)
    execute "set " . a:sopt . "=" . a:arg
endfunction
" }}}

" FUNCTION: popset#data#SetExecute(sopt, arg) {{{
function! popset#data#SetExecute(sopt, arg)
    execute a:sopt . " " . a:arg
endfunction
" }}}

" FUNCTION: popset#data#SetPopsetOption(sopt, arg) {{{
" set the option selected by popset 
function! popset#data#SetPopsetOption(sopt, arg)
    call popset#selection#SetOption(a:arg)
endfunction
" }}}

" FUNCTION: s:getColorSchemeList() {{{
function! s:getColorSchemeList()
    let l:scheme_path = split(glob($VIMRUNTIME.'/colors/*.vim'), "\n")
    let l:scheme_list = []

    let l:sep = '\'
    if has('unix') || has('macunix') || has('win32unix')
        let l:sep = '/'
    endif

    for item in l:scheme_path
        let l:scheme_list = add(l:scheme_list, split(split(item, l:sep)[-1], '\.')[0])
    endfor
    return l:scheme_list
endfunction
" }}}

" SECTION: popset selection data {{{1
" s:popset_selection_data item format
" \{
"     \ "opt" : [],
"     \ "lst" : [],
"     \ "dic" : {},
"     \ "cmd" : "",
" \},
" attention!!!: "popset" must be in s:popset_selection_data[0]
let s:popset_selection_data = [
    \{
        \ "opt" : ["popset"],
        \ "lst" : [],
        \ "dic" : {},
        \ "cmd" : "popset#data#SetPopsetOption"
    \},
    \{
        \ "opt" : ["background", "bg"],
        \ "lst" : ["dark", "light"],
        \ "dic" : {"data": "dark background color", 
                 \ "ligth": "light background color"},
        \ "cmd" : "popset#data#SetEqual",
    \},
    \{
        \ "opt" : ["colorscheme", "colo"],
        \ "lst" : s:getColorSchemeList(),
        \ "dic" : {},
        \ "cmd" : "popset#data#SetExecute",
    \},
    \{
        \ "opt" : ["fileformat", "ff"],
        \ "lst" : ["dos", "unix", "mac"],
        \ "dic" : {"dos" : "set EOL to <CR><LF>",
                 \ "unix" : "set EOL to <LF>",
                 \ "mac" : "set EOL to <CR>"},
        \ "cmd" : "popset#data#SetEqual",
    \},
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



