
" SECTION: variables {{{1
let s:popset_sel_shortname = {}         " map shortname to fullname
let s:popset_sel = {
    \ 'opt' : ['popset'],
    \ 'lst' : [],
    \ 'dic' : {},
    \ 'cpl' : 'customlist,popset#data#GetSelList',
    \ 'get' : v:null,
    \ 'sub' : {},
    \ }


" SETCION: functions {{{1

" FUNCTION: popset#data#Init() {{{
function! popset#data#Init()
    " generate internal option data
    for l:item in s:popset_selection_data
        let l:sopt = l:item['opt'][0]
        call add(s:popset_sel.lst, l:sopt)
        let s:popset_sel.dic[l:sopt] = l:item

        " append the opt[1:-1] as shortname
        if (len(l:item['opt']) > 1)
            for l:it in l:item['opt'][1:-1]
                let s:popset_sel_shortname[l:it] = l:sopt
            endfor
        end
    endfor

    " generate user's option data
    if exists('g:Popset_SelectionData')
        for l:item in g:Popset_SelectionData
            let l:sopt = l:item['opt'][0]
            if has_key(s:popset_sel.dic, l:sopt)
                call extend(s:popset_sel.dic[l:sopt].lst, l:item.lst)
                call extend(s:popset_sel.dic[l:sopt].dic, get(l:item, 'dic', {}), 'force')
            else
                call add(s:popset_sel.lst, l:sopt)
                let s:popset_sel.dic[l:sopt] = l:item
            endif

            " append the opt[1:-1] as shortname
            if (len(l:item['opt']) > 1)
                for l:it in l:item['opt'][1:-1]
                    let s:popset_sel_shortname[l:it] = l:sopt
                endfor
            end
        endfor
    endif

    call sort(s:popset_sel.lst)
endfunction
" }}}

" FUNCTION: popset#data#GetSel(sopt) {{{
function! popset#data#GetSel(sopt)
    if a:sopt ==# 'popset'
        return s:popset_sel
    else
        " option is given in shortname
        if has_key(s:popset_sel_shortname, a:sopt)
            return s:popset_sel.dic[s:popset_sel_shortname[a:sopt]]
        endif
        " option is given in fullname
        if has_key(s:popset_sel.dic, a:sopt)
            return s:popset_sel.dic[a:sopt]
        endif
    endif
    return {}
endfunction
" }}}

" FUNCTION: popset#data#GetSelList(arglead, cmdline, cursorpos) {{{
" get customelist for PopSet complete
function! popset#data#GetSelList(arglead, cmdline, cursorpos)
    let l:completekeys = []

    " search shortname
    for l:key in keys(s:popset_sel_shortname)
        if l:key =~ "^".a:arglead
            call add(l:completekeys, s:popset_sel_shortname[l:key])
        endif
    endfor

    " search fullname
    for l:key in s:popset_sel.lst
        if l:key =~ "^".a:arglead
            call add(l:completekeys, l:key)
        endif
    endfor

    if "popset" =~ "^".a:arglead
        call add(l:completekeys, "popset")
    endif

    return l:completekeys
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

" FUNCTION: s:getColorscheme(pat) {{{
function! s:getColorscheme(pat)
    let l:scheme_path = split(glob(a:pat), "\n")
    let l:scheme_list = []

    for item in l:scheme_path
        call add(l:scheme_list, fnamemodify(item, ":t:r"))
    endfor

    return l:scheme_list
endfunction
" }}}

" FUNCTION: popset#data#GetOptValue(sopt) {{{
function! popset#data#GetOptValue(sopt)
    if has_key(s:popset_sel.dic, a:sopt) || has_key(s:popset_sel_shortname, a:sopt)
        if a:sopt ==# "colorscheme" || a:sopt ==# "colo"
            return g:colors_name
        else
            return eval("&".a:sopt)
        endif
    else
        return ""
    endif
endfunction
" }}}


" SECTION: popset selection data {{{1
" s:popset_selection_data item format
" \{
"     \ 'opt' : [],
"     \ 'dsr' : '',
"     \ 'lst' : [],
"     \ 'dic' : {},
"     \ 'cmd' : '',
"     \ 'get' : '',
" \},
" "opt[0]" should be fullname of the option, and opt[1:-1] is the shortname for opt[0].
" Think two options as same option when "opt[0]" is equal.
let s:popset_selection_data = [
    \{
        \ 'opt' : ['background', 'bg'],
        \ 'dsr' : 'Use color for the background.',
        \ 'lst' : ['dark', 'light'],
        \ 'dic' : {'data': 'dark background color',
                 \ 'ligth': 'light background color'},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['cmdheight', 'ch'],
        \ 'dsr' : 'Number of screen lines to use for the command-line.',
        \ 'lst' : [1, 2, 3, 4, 5],
        \ 'dic' : {},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['colorscheme', 'colo'],
        \ 'dsr' : 'Load color scheme.',
        \ 'lst' : s:getColorscheme($VIMRUNTIME.'/colors/*.vim'),
        \ 'dic' : {},
        \ 'cmd' : 'popset#data#SetExecute',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['completeopt', 'cot'],
        \ 'dsr' : 'A comma separated list of options for Insert mode completion.',
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
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['conceallevel', 'cole'],
        \ 'dsr' : 'Determine how text shown.',
        \ 'lst' : ['0', '1', '2', '3'],
        \ 'dic' : {
                \ '0' : 'Text is shown normally',
                \ '1' : 'Each block of concealed text is replaced with one character.',
                \ '2' : 'Concealed text is completely hidden unless it has a custom replacement character defined.',
                \ '3' : 'Concealed text is completely hidden.',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['encoding', 'enc'],
        \ 'dsr' : 'Sets the character encoding used inside Vim.',
        \ 'lst' : [ 'latin1', 'utf-8', 'cp936', 'euc-cn', 'cp950',
                \ 'big5', 'euc-tw', 'cp932', 'euc-jp', 'sjis',
                \ 'cp949', 'euc-kr', 'koi8-r', 'koi8-u',
                \ 'ucs-2be', 'ucs-2le', 'utf-16', 'utf-16le',
                \],
        \ 'dic' : {
                \ 'latin1'  : 'Same as "ansi", 8-bit characters (ISO 8859-1, also used for cp1252).',
                \ 'utf-8'   : '32 bit UTF-8 encoded Unicode (ISO/IEC 10646-1)',
                \ 'cp936'   : 'simplified Chinese (Windows only, GBK)',
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
                \ 'utf-16'  : 'ucs-2 extended with double-words for more characters',
                \ 'utf-16le': 'like utf-16, little endian',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['fileencoding', 'fenc'],
        \ 'dsr' : 'Sets the character encoding for the file of this buffer.',
        \ 'lst' : [ 'latin1', 'utf-8', 'cp936', 'euc-cn', 'cp950',
                \ 'big5', 'euc-tw', 'cp932', 'euc-jp', 'sjis',
                \ 'cp949', 'euc-kr', 'koi8-r', 'koi8-u',
                \ 'ucs-2be', 'ucs-2le', 'utf-16', 'utf-16le',
                \],
        \ 'dic' : {
                \ 'latin1'  : 'Same as "ansi", 8-bit characters (ISO 8859-1, also used for cp1252).',
                \ 'utf-8'   : '32 bit UTF-8 encoded Unicode (ISO/IEC 10646-1)',
                \ 'cp936'   : 'simplified Chinese (Windows only, GBK)',
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
                \ 'utf-16'  : 'ucs-2 extended with double-words for more characters',
                \ 'utf-16le': 'like utf-16, little endian',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['fileformat', 'ff'],
        \ 'dsr' : 'Give the <EOL> of the current buffer.',
        \ 'lst' : ['dos', 'unix', 'mac'],
        \ 'dic' : {'dos' : 'set EOL to <CR><LF>',
                 \ 'unix' : 'set EOL to <LF>',
                 \ 'mac' : 'set EOL to <CR>'},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['foldcolumn', 'fdc'],
        \ 'dsr' : 'Column indicates open and closed folds.',
        \ 'lst' : ['0', '1', '2' , '3', '4' , '5', '6', '7', '8', '9', '10', '11', '12'],
        \ 'dic' : {},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['foldmethod', 'fdm'],
        \ 'dsr' : 'The kind of folding used for the current window.',
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
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['laststatus', 'ls'],
        \ 'dsr' : 'Determine when the last window will have a status line.',
        \ 'lst' : ['0', '1', '2'],
        \ 'dic' :{
                \ '0' : 'never',
                \ '1' : 'only if there are at least two windows',
                \ '2' : 'always',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['linespace', 'lsp'],
        \ 'dsr' : 'Number of pixel lines inserted between characters.',
        \ 'lst' : ['-2', '-1', '0', '1', '2' , '3', '4' , '5', '6', '7', '8', '9', '10'],
        \ 'dic' :{},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['scrolloff', 'so'],
        \ 'dsr' : 'Minimal number of screen lines to keep above and below the cursor.',
        \ 'lst' : ['0', '1', '2' , '3', '4' , '5', '6', '7', '8', '9', '10'],
        \ 'dic' :{},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['signcolumn', 'scl'],
        \ 'dsr' : 'Whether or not to draw the signcolumn.',
        \ 'lst' : ['auto', 'yes', 'no'],
        \ 'dic' :{
                \ 'auto' : 'only when there is a sign to display',
                \ 'no'   : 'never',
                \ 'yes'  : 'always',},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['shiftwidth', 'sw'],
        \ 'dsr' : 'Number of spaces to use for each step of (auto)indent.',
        \ 'lst' : ['2', '3', '4', '8', '16'],
        \ 'dic' :{},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['softtabstop', 'sts'],
        \ 'dsr' : 'Number of spaces that a <Tab> counts for while performing editing operations',
        \ 'lst' : ['2', '3', '4', '8', '16'],
        \ 'dic' :{},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['tabstop', 'ts'],
        \ 'dsr' : 'Number of spaces that a <Tab> in the file counts for.',
        \ 'lst' : ['2', '3', '4', '8', '16'],
        \ 'dic' :{},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \{
        \ 'opt' : ['virtualedit', 've'],
        \ 'dsr' : 'Determine whether cursor can be positioned where there is no actual character.',
        \ 'lst' : ['""', 'block', 'insert', 'all', 'onemore'],
        \ 'dic' : {
                \ '""'      : 'Default value.',
                \ 'block'   : 'Allow virtual editing in Visual block mode.',
                \ 'insert'  : 'Allow virtual editing in Insert mode.',
                \ 'all'     : 'Allow virtual editing in all modes.',
                \ 'onemore' : 'Allow the cursor to move just past the end of the line.',
                \},
        \ 'cmd' : 'popset#data#SetEqual',
        \ 'get' : 'popset#data#GetOptValue'
    \},
    \]

