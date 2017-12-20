
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

            " For the same option but different name (eg. ["colorscheme", "colo"]),
            " because they have the same "lst", "dic" and "cmd", the key will
            " point to the same data address, that means s:popset_data["colorscheme"]
            " and s:popset_data["colo"] pointed to same data address.
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
            call add(l:completekeys, key)
        endif
    endfor

    return l:completekeys
endfunction
" }}}

" FUNCTION: popset#data#GetSurpportedOptionList() {{{
" get all options surpported by popset
function! popset#data#GetSurpportedOptionList()
    let l:lst = []
    let l:lst_final = []
    let l:dic_final = {}

    " get internal option list
    for item in s:popset_selection_data[1:-1]
        call extend(l:lst, item["opt"])

        " append the fisrt item of opt-list to selection list of popset option
        call add(l:lst_final, item["opt"][0])

        " append the reset item of opt-list as description dictory
        if len(item["opt"]) > 1
            let l:dic_final[item["opt"][0]] =
                \ "Also equals to '" . join(item["opt"][1:-1], "','") . "'"
        endif
    endfor

    " convert internal option list to string for search with matchstr
    "let l:lst_string = '|' . join(l:lst, '|') . '|'

    if exists("g:Popset_SelectionData")
        " add the non-reduplicated user's option to list
        for item in g:Popset_SelectionData
            " detect whether user's option in 'item' is reduplicated
            let l:flg = 0
            let l:dsr = []
            let l:key = ""
            for str in item["opt"]
                " if internal list had not include user's option yet
                "if "" == matchstr(l:lst_string, '\C|' . str . '|')
                if -1 == match(l:lst, '\C^' . str . '$')
                    " note the non-reduplicated option
                    call add(l:dsr, str)
                else
                    " note the reduplicate option
                    let l:flg = 1
                    if -1 != match(l:lst_final, '\C^' . str . '$')
                        let l:key = str
                    endif
                endif
            endfor

            if 0 == l:flg
                " no reduplicated option in 'item' compared to internal option
                call add(l:lst_final, item["opt"][0])
                if len(item["opt"]) > 1
                    let l:dic_final[item["opt"][0]] =
                        \ "Also equals to '" . join(item["opt"][1:-1], "','") . "'"
                endif
            else
                " the option 'item' is reduplicated
                if !empty(l:dsr) && l:key != ""
                    let l:dic_final[l:key] .= ",'" . join(l:dsr, "','") . "'"
                endif
            endif
        endfor
    endif
    let s:popset_selection_data[0]["lst"] = l:lst_final
    let s:popset_selection_data[0]["dic"] = l:dic_final
endfunction
" }}}

" FUNCTION: popset#data#GetOptionValue(sopt, scmd) {{{
function! popset#data#GetOptionValue(sopt, scmd)
    if a:scmd ==# "popset#data#SetEqual"
        return eval("&".a:sopt)
    elseif a:scmd ==# "popset#data#SetExecute"
        if a:sopt ==# "colorscheme" || a:sopt ==# "colo"
            return g:colors_name
        endif
    endif

    return ""
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

" FUNCTION: popset#data#GetFileList(pat) {{{
function! popset#data#GetFileList(pat)
    let l:scheme_path = split(glob(a:pat), "\n")
    let l:scheme_list = []

    for item in l:scheme_path
        call add(l:scheme_list, fnamemodify(item, ":t:r"))
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
        \ "lst" : popset#data#GetFileList($VIMRUNTIME.'/colors/*.vim'),
        \ "dic" : {},
        \ "cmd" : "popset#data#SetExecute",
    \},
    \{
        \ "opt" : ["completeopt", "cot"],
        \ "lst" : ["menu", "menuone", "longest",
                \ "menu,preview", "menuone,preview",
                \ "menu,noinsert", "menuone,noinsert",
                \ "menu,noselect", "menuone,noselect"],
        \ "dic" : {
                \ "menu"             : "Use a popup menu to show the possible completions.",
                \ "menuone"          : "Use the popup menu also when there is only one match.",
                \ "longest"          : "Only insert the longest common text of the matches.",
                \ "menu,preview"     : "Show extra information about the currently selected completion in the preview window.",
                \ "menuone,preview"  : "Show extra information about the currently selected completion in the preview window.",
                \ "menu,noinsert"    : "Do not insert any text for a match until the user selects a match from the menu.",
                \ "menuone,noinsert" : "Do not insert any text for a match until the user selects a match from the menu.",
                \ "menu,noselect"    : "Do not select a match in the menu, force the user to select one from the menu.",
                \ "menuone,noselect" : "Do not select a match in the menu, force the user to select one from the menu.",
                \ },
        \ "cmd" : "popset#data#SetEqual",
    \},
    \{
        \ "opt" : ["conceallevel", "cole"],
        \ "lst" : ["0", "1", "2", "3"],
        \ "dic" : {
                \ "0" : "Text is shown normally",
                \ "1" : "Each block of concealed text is replaced with one character.",
                \ "2" : "Concealed text is completely hidden unless it has a custom replacement character defined.",
                \ "3" : "Concealed text is completely hidden.",
                \},
        \ "cmd" : "popset#data#SetEqual",
    \},
    \{
        \ "opt" : ["encoding", "enc"],
        \ "lst" : [ "latin1", "utf-8", "cp936", "euc-cn", "cp950",
                \ "big5", "euc-tw", "cp932", "euc-jp", "sjis",
                \ "cp949", "euc-kr", "koi8-r", "koi8-u",
                \ "ucs-2be", "ucs-2le", "utf-16", "utf-16le",
                \],
        \ "dic" : {
                \ "latin1"  : "Same as 'ansi', 8-bit characters (ISO 8859-1, also used for cp1252).",
                \ "utf-8"   : "32 bit UTF-8 encoded Unicode (ISO/IEC 10646-1)",
                \ "cp936"   : "simplified Chinese (Windows only)",
                \ "euc-cn"  : "simplified Chinese (Unix only)",
                \ "cp950"   : "traditional Chinese (on Unix alias for big5)",
                \ "big5"    : "traditional Chinese (on Windows alias for cp950)",
                \ "euc-tw"  : "traditional Chinese (Unix only)",
                \ "cp932"   : "Japanese (Windows only)",
                \ "euc-jp"  : "Japanese (Unix only)",
                \ "sjis"    : "Japanese (Unix only)",
                \ "cp949"   : "Korean (Unix and Windows)",
                \ "euc-kr"  : "Korean (Unix only)",
                \ "koi8-r"  : "Russian",
                \ "koi8-u"  : "Ukrainian",
                \ "ucs-2be" : "16 bit UCS-2 encoded Unicode, big endian(ISO/IEC 10646-1)",
                \ "ucs-2le" : "like ucs-2, little endian",
                \ "utf-16"	: "ucs-2 extended with double-words for more characters",
                \ "utf-16le": "like utf-16, little endian",
                \},
        \ "cmd" : "popset#data#SetEqual",
    \},
    \{
        \ "opt" : ["fileencoding", "fenc"],
        \ "lst" : [ "latin1", "utf-8", "cp936", "euc-cn", "cp950",
                \ "big5", "euc-tw", "cp932", "euc-jp", "sjis",
                \ "cp949", "euc-kr", "koi8-r", "koi8-u",
                \ "ucs-2be", "ucs-2le", "utf-16", "utf-16le",
                \],
        \ "dic" : {
                \ "latin1"  : "Same as 'ansi', 8-bit characters (ISO 8859-1, also used for cp1252).",
                \ "utf-8"   : "32 bit UTF-8 encoded Unicode (ISO/IEC 10646-1)",
                \ "cp936"   : "simplified Chinese (Windows only)",
                \ "euc-cn"  : "simplified Chinese (Unix only)",
                \ "cp950"   : "traditional Chinese (on Unix alias for big5)",
                \ "big5"    : "traditional Chinese (on Windows alias for cp950)",
                \ "euc-tw"  : "traditional Chinese (Unix only)",
                \ "cp932"   : "Japanese (Windows only)",
                \ "euc-jp"  : "Japanese (Unix only)",
                \ "sjis"    : "Japanese (Unix only)",
                \ "cp949"   : "Korean (Unix and Windows)",
                \ "euc-kr"  : "Korean (Unix only)",
                \ "koi8-r"  : "Russian",
                \ "koi8-u"  : "Ukrainian",
                \ "ucs-2be" : "16 bit UCS-2 encoded Unicode, big endian(ISO/IEC 10646-1)",
                \ "ucs-2le" : "like ucs-2, little endian",
                \ "utf-16"	: "ucs-2 extended with double-words for more characters",
                \ "utf-16le": "like utf-16, little endian",
                \},
        \ "cmd" : "popset#data#SetEqual",
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
        \ "opt" : ["foldcolumn", "fdc"],
        \ "lst" : ["0", "1", "2" , "3", "4" , "5", "6", "7", "8", "9", "10", "11", "12"],
        \ "dic" : {},
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
    \{
        \ "opt" : ["laststatus", "ls"],
        \ "lst" : ["0", "1", "2"],
        \ "dic" :{
                \ "0" : "never",
                \ "1" : "only if there are at least two windows",
                \ "2" : "always",
                \},
        \ "cmd" : "popset#data#SetEqual",
    \},
    \{
        \ "opt" : ["linespace", "lsp"],
        \ "lst" : ["-2", "-1", "0", "1", "2" , "3", "4" , "5", "6", "7", "8", "9", "10"],
        \ "dic" :{},
        \ "cmd" : "popset#data#SetEqual",
    \},
    \{
        \ "opt" : ["scrolloff", "so"],
        \ "lst" : ["0", "1", "2" , "3", "4" , "5", "6", "7", "8", "9", "10"],
        \ "dic" :{},
        \ "cmd" : "popset#data#SetEqual",
    \},
    \{
        \ "opt" : ["signcolumn", "scl"],
        \ "lst" : ["auto", "yes", "no"],
        \ "dic" :{
                \ "auto" : "only when there is a sign to display",
                \ "no"   : "never",
                \ "yes"  : "always",},
        \ "cmd" : "popset#data#SetEqual",
    \},
    \{
        \ "opt" : ["virtualedit", "ve"],
        \ "lst" : ["\"\"", "block", "insert", "all", "onemore"],
        \ "dic" : {
                \ "\"\""    : "Default value.",
                \ "block"   : "Allow virtual editing in Visual block mode.",
                \ "insert"  : "Allow virtual editing in Insert mode.",
                \ "all"     : "Allow virtual editing in all modes.",
                \ "onemore" : "Allow the cursor to move just past the end of the line.",
                \},
        \ "cmd" : "popset#data#SetEqual",
    \},
    \]



