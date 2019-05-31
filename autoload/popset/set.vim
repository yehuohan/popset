
" popset layer.

" SECTION: variables {{{1
let [s:popc, s:MODE] = popc#popc#GetPopc()
let s:lyr = {}          " this layer
let s:opt = ''          " option
let s:lst = []          " list
let s:dic = {}          " dictionary
let s:cmd = ''          " command function
let s:arg = []          " args of command
let s:pre = 1           " preview
let s:mapsData = [
    \ ['popset#set#Pop'   , ['p'],          'Pop popset layer'],
    \ ['popset#set#Load'  , ['CR','Space'], 'Execute (CR-Execute, Space-Preview execute)'],
    \ ['popset#set#Help'  , ['?'],          'Show help of popset layer'],
    \ ]


" SECTION: functions {{{1

" FUNCTION: popset#set#Init() {{{
function! popset#set#Init()
    let s:lyr = s:popc.addLayer('Popset')

    for md in s:mapsData
        call s:lyr.addMaps(md[0], md[1])
    endfor
endfunction
" }}}

" FUNCTION: s:createBuffer() {{{
function! s:createBuffer()
    let l:text = ''
    let l:max = 0

    " get max key text width
    for lst in s:lst
        let l:keywid = strwidth(lst)
        let l:max = (l:keywid > l:max) ? l:keywid : l:max
    endfor
    let l:max += 2

    " create and tabular buffer text
    for lst in s:lst
        let l:line = '  ' . lst
        if has_key(s:dic, lst)
            " add description of selection if it exits
            let l:line .= repeat(' ', l:max - strwidth(l:line)) . ' : '
            let l:line .= s:dic[lst]
        endif
        let l:line .= repeat(' ', &columns - strwidth(l:line) + 1)
        let l:text .= l:line . "\n"
    endfor

    call s:lyr.setBufs(v:t_string, len(s:lst), l:text)
endfunction
" }}}

" FUNCTION: s:pop(keepIndex) {{{
function! s:pop(keepIndex)
    let l:value = popset#data#GetOptValue(s:opt, s:cmd)
    let l:text = s:opt . (empty(l:value) ? '' : ' = ' . l:value)

    call s:lyr.setMode(s:MODE.Normal)
    call s:lyr.setInfo('centerText', l:text)
    if !a:keepIndex
        call s:lyr.setInfo('lastIndex', 0)
    endif
    call popc#ui#Create(s:lyr.name)
endfunction
" }}}

" FUNCTION: popset#set#PSet(opt) {{{
function! popset#set#PSet(opt)
    call popset#data#Init()

    let s:opt = a:opt
    let [s:lst, s:dic, s:cmd] = popset#data#GetOpt(a:opt)
    unlet! s:arg
    let s:pre = 1

    call s:createBuffer()
    call s:pop(0)
endfunction
" }}}

" FUNCTION: popset#set#PopSelection(dict, preview, ...) {{{
" @param dict: A dictionary in followint format,
"               {
"                   \ "opt" : [],
"                   \ "lst" : [],
"                   \ "dic" : {},
"                   \ "cmd" : "",
"               }
"               where dic is not necessary.
" @param preview: Is the command surpport preview or not.
" @param 1 args: The args list to cmd.
function! popset#set#PopSelection(dict, preview, ...)
    let s:opt = a:dict['opt'][0]
    let s:lst = a:dict['lst']
    let s:dic = has_key(a:dict, 'dic') ? a:dict['dic'] : {}
    let s:cmd = a:dict['cmd']
    if a:0 >= 1
        let s:arg = a:1
    else
        unlet! s:arg
    endif
    let s:pre = a:preview

    call s:createBuffer()
    call s:pop(0)
endfunction
" }}}

" FUNCTION: popset#set#Pop(key) {{{
function! popset#set#Pop(key)
    call popset#set#PSet('popset')
endfunction
" }}}

" FUNCTION: popset#set#Load(key) {{{
function! popset#set#Load(key)
    if empty(s:lst)
        return
    endif

    let l:index = popc#ui#GetIndex()
    call popc#ui#Destroy()
    if (a:key ==# 'CR') || (a:key ==# 'Space' && s:pre)
        if s:opt ==# 'popset'
            call popset#set#PSet(s:lst[l:index])
        else
            if exists('s:arg')
                call function(s:cmd)(s:opt, s:lst[l:index], s:arg)
            else
                call function(s:cmd)(s:opt, s:lst[l:index])
            endif
            if a:key == 'Space'
                call s:pop(1)
            endif
        endif
    endif
endfunction
" }}}

" FUNCTION: popset#set#Help(key) {{{
function! popset#set#Help(key)
    call s:lyr.setMode(s:MODE.Help)
    call s:lyr.setBufs(v:t_string, len(s:mapsData), popc#layer#com#createHelpBuffer(s:mapsData))
    call popc#ui#Create(s:lyr.name)
endfunction
" }}}
