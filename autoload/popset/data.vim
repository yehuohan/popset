
" SECTION: variables {{{1
" s:popset_data format
" {opt1: [ [lst], {dic}, 'cmd'],
"  opt2: [ [lst], {dic}, 'cmd'],
"  ......
" }
let s:popset_data = {}
" map shortname to fullname
let s:popset_opt_shortname = {}


" SETCION: functions {{{1

" FUNCTION: popset#data#Init() {{{
function! popset#data#Init()
    let s:popset_data = {}
    let s:popset_opt_shortname = {}

    " generate option data
    call s:getSurpportedOptionData()
    call s:createPopsetOption()
endfunction
" }}}

" FUNCTION: popset#data#GetSelectionsAndCommand(sopt) {{{
" return [list, dict, cmd]
function! popset#data#GetSelectionsAndCommand(sopt)
    " option is given in shortname
    if has_key(s:popset_opt_shortname, a:sopt)
        return s:popset_data[s:popset_opt_shortname[a:sopt]]
    endif
    " option is given in fullname
    if has_key(s:popset_data, a:sopt)
        return s:popset_data[a:sopt]
    else
        return [[], {}, '']
    endif
endfunction
" }}}

" FUNCTION: popset#data#GetCompleteOptionList(arglead, cmdline, cursorpos) {{{
" get customelist for PSet complete
function! popset#data#GetCompleteOptionList(arglead, cmdline, cursorpos)
    let l:completekeys = []

    " search shortname
    if has_key(s:popset_opt_shortname, a:arglead)
        call add(l:completekeys, s:popset_opt_shortname[a:arglead])
    endif

    " search fullname
    for l:key in s:popset_data['popset']['lst']
        if l:key =~ "^".a:arglead
            call add(l:completekeys, l:key)
        endif
    endfor

    return l:completekeys
endfunction
" }}}

" FUNCTION: s:addSelectionsAndCommand(sopt, slist, sdict, scmd) {{{
function! s:addSelectionsAndCommand(sopt, slist, sdict, scmd)
    " detect whether user's option is reduplicated
    if has_key(s:popset_data, a:sopt)
        call extend(s:popset_data[a:sopt][0], a:slist)
        call extend(s:popset_data[a:sopt][1], a:sdict, 'force')
    else
        let s:popset_data[a:sopt] = [a:slist, a:sdict, a:scmd]
    endif
endfunction
" }}}

" FUNCTION: s:getSurpportedOptionData() {{{
function! s:getSurpportedOptionData()
    " generate internal option data
    for l:item in s:popset_selection_data[1:-1]
        " add option to popset_data
        call s:addSelectionsAndCommand(l:item['opt'][0], l:item['lst'], l:item['dic'], l:item['cmd'])

        " append the opt[1:-1] as shortname
        if (len(l:item['opt']) > 1)
            for l:it in l:item['opt'][1:-1]
                let s:popset_opt_shortname[l:it] = l:item['opt'][0]
            endfor
        end
    endfor

    " generate user's option data
    if exists('g:Popset_SelectionData')
        for l:item in g:Popset_SelectionData
            " add option to popset_data
            call s:addSelectionsAndCommand(l:item['opt'][0], l:item['lst'], l:item['dic'], l:item['cmd'])

            " append the opt[1:-1] as shortname
            if (len(l:item['opt']) > 1)
                for l:it in l:item['opt'][1:-1]
                    let s:popset_opt_shortname[l:it] = l:item['opt'][0]
                endfor
            end
        endfor
    endif
endfunction
" }}}

" FUNCTION: s:createPopsetOption() {{{
function! s:createPopsetOption()
    "  create 'popset' option
    let l:opt = 'popset'
    let l:lst = keys(s:popset_data)
    let l:cmd = 'popset#data#SetPopsetOption'
    call sort(l:lst)
    call s:addSelectionsAndCommand(l:opt, l:lst, {}, l:cmd)
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
"     \ 'opt' : [],
"     \ 'lst' : [],
"     \ 'dic' : {},
"     \ 'cmd' : '',
" \},
" "opt[0]" should be fullname of the option, and opt[1:-1] is the shortname for opt[0].
" Think two options as same option when "opt[0]" is equal.
let s:popset_selection_data = [
    \{
        \ 'opt' : ['background', 'bg'],
        \ 'lst' : ['dark', 'light'],
        \ 'dic' : {'data': 'dark background color',
                 \ 'ligth': 'light background color'},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['colorscheme', 'colo'],
        \ 'lst' : popset#data#GetFileList($VIMRUNTIME.'/colors/*.vim'),
        \ 'dic' : {},
        \ 'cmd' : 'popset#data#SetExecute',
    \},
    \{
        \ 'opt' : ['completeopt', 'cot'],
        \ 'lst' : ['menu', 'menuone', 'longest',
                \ 'menu,preview', 'menuone,preview',
                \ 'menu,noinsert', 'menuone,noinsert',
                \ 'menu,noselect', 'menuone,noselect'],
        \ 'dic' : {
                \ 'menu'             : 'Use a popup menu to show the possible completions.',
                \ 'menuone'          : 'Use the popup menu also when there is only one match.',
                \ 'longest'          : 'Only insert the longest common text of the matches.',
                \ 'menu,preview'     : 'Show extra information about the currently selected completion in the preview window.',
                \ 'menuone,preview'  : 'Show extra information about the currently selected completion in the preview window.',
                \ 'menu,noinsert'    : 'Do not insert any text for a match until the user selects a match from the menu.',
                \ 'menuone,noinsert' : 'Do not insert any text for a match until the user selects a match from the menu.',
                \ 'menu,noselect'    : 'Do not select a match in the menu, force the user to select one from the menu.',
                \ 'menuone,noselect' : 'Do not select a match in the menu, force the user to select one from the menu.',
                \ },
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['conceallevel', 'cole'],
        \ 'lst' : ['0', '1', '2', '3'],
        \ 'dic' : {
                \ '0' : 'Text is shown normally',
                \ '1' : 'Each block of concealed text is replaced with one character.',
                \ '2' : 'Concealed text is completely hidden unless it has a custom replacement character defined.',
                \ '3' : 'Concealed text is completely hidden.',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['encoding', 'enc'],
        \ 'lst' : [ "latin1", 'utf-8', 'cp936', 'euc-cn', 'cp950',
                \ 'big5', 'euc-tw', 'cp932', 'euc-jp', 'sjis',
                \ 'cp949', 'euc-kr', 'koi8-r', 'koi8-u',
                \ 'ucs-2be', 'ucs-2le', 'utf-16', 'utf-16le',
                \],
        \ 'dic' : {
                \ 'latin1'  : 'Same as "ansi", 8-bit characters (ISO 8859-1, also used for cp1252).',
                \ 'utf-8'   : '32 bit UTF-8 encoded Unicode (ISO/IEC 10646-1)',
                \ 'cp936'   : 'simplified Chinese (Windows only)',
                \ 'euc-cn'  : 'simplified Chinese (Unix only)',
                \ 'cp950'   : 'traditional Chinese (on Unix alias for big5)',
                \ 'big5'    : 'traditional Chinese (on Windows alias for cp950)',
                \ 'euc-tw'  : 'traditional Chinese (Unix only)',
                \ 'cp932'   : 'Japanese (Windows only)',
                \ 'euc-jp'  : 'Japanese (Unix only)',
                \ 'sjis'    : 'Japanese (Unix only)',
                \ 'cp949'   : 'Korean (Unix and Windows)',
                \ 'euc-kr'  : 'Korean (Unix only)',
                \ 'koi8-r'  : 'Russian',
                \ 'koi8-u'  : 'Ukrainian',
                \ 'ucs-2be' : '16 bit UCS-2 encoded Unicode, big endian(ISO/IEC 10646-1)',
                \ 'ucs-2le' : 'like ucs-2, little endian',
                \ 'utf-16'	: 'ucs-2 extended with double-words for more characters',
                \ 'utf-16le': 'like utf-16, little endian',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['fileencoding', 'fenc'],
        \ 'lst' : [ 'latin1', 'utf-8', 'cp936', 'euc-cn', 'cp950',
                \ 'big5', 'euc-tw', 'cp932', 'euc-jp', 'sjis',
                \ 'cp949', 'euc-kr', 'koi8-r', 'koi8-u',
                \ 'ucs-2be', 'ucs-2le', 'utf-16', 'utf-16le',
                \],
        \ 'dic' : {
                \ 'latin1'  : 'Same as "ansi", 8-bit characters (ISO 8859-1, also used for cp1252).',
                \ 'utf-8'   : '32 bit UTF-8 encoded Unicode (ISO/IEC 10646-1)',
                \ 'cp936'   : 'simplified Chinese (Windows only)',
                \ 'euc-cn'  : 'simplified Chinese (Unix only)',
                \ 'cp950'   : 'traditional Chinese (on Unix alias for big5)',
                \ 'big5'    : 'traditional Chinese (on Windows alias for cp950)',
                \ 'euc-tw'  : 'traditional Chinese (Unix only)',
                \ 'cp932'   : 'Japanese (Windows only)',
                \ 'euc-jp'  : 'Japanese (Unix only)',
                \ 'sjis'    : 'Japanese (Unix only)',
                \ 'cp949'   : 'Korean (Unix and Windows)',
                \ 'euc-kr'  : 'Korean (Unix only)',
                \ 'koi8-r'  : 'Russian',
                \ 'koi8-u'  : 'Ukrainian',
                \ 'ucs-2be' : '16 bit UCS-2 encoded Unicode, big endian(ISO/IEC 10646-1)',
                \ 'ucs-2le' : 'like ucs-2, little endian',
                \ 'utf-16'	: 'ucs-2 extended with double-words for more characters',
                \ 'utf-16le': 'like utf-16, little endian',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['fileformat', 'ff'],
        \ 'lst' : ['dos', 'unix', 'mac'],
        \ 'dic' : {'dos' : 'set EOL to <CR><LF>',
                 \ 'unix' : 'set EOL to <LF>',
                 \ 'mac' : 'set EOL to <CR>'},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['foldcolumn', 'fdc'],
        \ 'lst' : ['0', '1', '2' , '3', '4' , '5', '6', '7', '8', '9', '10', '11', '12'],
        \ 'dic' : {},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['foldmethod', 'fdm'],
        \ 'lst' : ['manual', 'indent', 'expr', 'marker', 'syntax', 'diff'],
        \ 'dic' : {
                \ 'manual' : 'Folds are created manually.',
                \ 'indent' : 'Lines with equal indent form a fold.',
                \ 'expr'   : '"foldexpr" gives the fold level of a line.',
                \ 'marker' : 'Markers are used to specify folds.',
                \ 'syntax' : 'Syntax highlighting items specify folds.',
                \ 'diff'   : 'Fold text that is not changed.',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['laststatus', 'ls'],
        \ 'lst' : ['0', '1', '2'],
        \ 'dic' :{
                \ '0' : 'never',
                \ '1' : 'only if there are at least two windows',
                \ '2' : 'always',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['linespace', 'lsp'],
        \ 'lst' : ['-2', '-1', '0', '1', '2' , '3', '4' , '5', '6', '7', '8', '9', '10'],
        \ 'dic' :{},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['scrolloff', 'so'],
        \ 'lst' : ['0', '1', '2' , '3', '4' , '5', '6', '7', '8', '9', '10'],
        \ 'dic' :{},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['signcolumn', 'scl'],
        \ 'lst' : ['auto', 'yes', 'no'],
        \ 'dic' :{
                \ 'auto' : 'only when there is a sign to display',
                \ 'no'   : 'never',
                \ 'yes'  : 'always',},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['shiftwidth', 'sw'],
        \ 'lst' : ['2', '3', '4', '8'],
        \ 'dic' :{},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['tabstop', 'ts'],
        \ 'lst' : ['2', '3', '4', '8'],
        \ 'dic' :{},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \{
        \ 'opt' : ['virtualedit', 've'],
        \ 'lst' : ['""', 'block', 'insert', 'all', 'onemore'],
        \ 'dic' : {
                \ '""'      : 'Default value.',
                \ 'block'   : 'Allow virtual editing in Visual block mode.',
                \ 'insert'  : 'Allow virtual editing in Insert mode.',
                \ 'all'     : 'Allow virtual editing in all modes.',
                \ 'onemore' : 'Allow the cursor to move just past the end of the line.',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
    \},
    \]



