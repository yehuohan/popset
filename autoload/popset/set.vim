
" popset layer.

" SECTION: variables {{{1
let [s:popc, s:MODE] = popc#popc#GetPopc()
let s:conf = popc#init#GetConfig()
let s:lyr = {}          " this layer
let s:sel = {
    \ 'stack' : [],
    \ 'top' : -1,
    \ }
let s:opt = ''          " option name of selection
let s:lst = []          " list of selection
let s:dic = {}          " dictionary of description
let s:sub = {}          " sub selection
let s:cmd = ''          " command function
let s:arg = []          " args of command
let s:get = ''          " function to get option value
let s:idx = 0           " current index of selection
let s:mapsData = [
    \ ['popset#set#Pop'   , ['p'],          'Pop popset layer'],
    \ ['popset#set#Load'  , ['CR','Space'], 'Execute (Space: preview execution)'],
    \ ['popset#set#Back'  , ['u','U'],      'Back to upper selection (U: back to the root-upper selection)'],
    \ ['popset#set#Help'  , ['?'],          'Show help of popset layer'],
    \ ]


" SECTION: dictionary function {{{1

" FUNCTION: s:sel.isEmpty() dict {{{
function! s:sel.isEmpty() dict
    return (self.top <= 0)
endfunction
" }}}

" FUNCTION: s:sel.clear() dict {{{
function! s:sel.clear() dict
    let self.top = -1
endfunction
" }}}

" FUNCTION: s:sel.push(dict) dict {{{
function! s:sel.push(dict) dict
    let self.top += 1
    if self.top >= len(self.stack)
        call add(self.stack, {})
    endif
    let self.stack[self.top] = a:dict
endfunction
" }}}

" FUNCTION: s:sel.pop() dict {{{
function! s:sel.pop() dict
    let self.top -= 1
    return self.stack[self.top]
endfunction
" }}}

" FUNCTION: s:sel.popToRoot() dict {{{
function! s:sel.popToRoot() dict
    let self.top = 0
    return self.stack[self.top]
endfunction
" }}}

" FUNCTION: s:sel.setTop(key, val) dict {{{
function! s:sel.setTop(key, val) dict
    if self.top >= 0
        let self.stack[self.top][a:key] = a:val
    endif
endfunction
" }}}

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

    " create and tabular buffer text
    if !empty(s:get)
        let l:val = function(s:get)(s:opt)
        let l:max += 4
    else
        unlet! l:val
        let l:max += 2
    endif
    for lst in s:lst
        let l:line = '  '
        if !empty(s:get)
            let l:line .= ((l:val ==# lst) ? s:conf.symbols.WIn : ' ') . ' '
        endif
        let l:line .= lst
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
function! s:pop()
    let l:text = 's' . string(s:sel.top) . '. ' . s:opt
    call s:lyr.setMode(s:MODE.Normal)
    call s:lyr.setInfo('centerText', l:text)
    call s:lyr.setInfo('lastIndex', s:idx)
    call popc#ui#Create(s:lyr.name)
endfunction
" }}}

" FUNCTION: s:ps(sel) {{{
" @param dict: A dictionary in following format,
"               {
"                   \ 'opt' : '',
"                   \ 'lst' : [],
"                   \ 'dic' : {},
"                   \ 'sub' : {},
"                   \ 'cmd' : '',
"                   \ 'arg' : [],
"                   \ 'get' : '',
"                   \ 'idx' : 0,
"               }
"               idx is current selection index.
function! s:ps(sel)
    let s:opt = a:sel['opt']
    let s:lst = a:sel['lst']
    let s:dic = a:sel['dic']
    let s:sub = a:sel['sub']
    let s:cmd = a:sel['cmd']
    if has_key(a:sel, 'arg')
        let s:arg = a:sel.arg
    else
        unlet! s:arg
    endif
    let s:get = a:sel['get']
    let s:idx = a:sel['idx']            " recover selection's index

    call s:createBuffer()
    call s:pop()
endfunction
" }}}

" FUNCTION: popset#set#Pop(key) {{{
function! popset#set#Pop(key)
    call popset#set#PopSet('popset')
endfunction
" }}}

" FUNCTION: popset#set#Load(key) {{{
function! popset#set#Load(key)
    if empty(s:lst)
        return
    endif

    let s:idx = popc#ui#GetIndex()
    call popc#ui#Destroy()
    if exists('s:arg')
        call function(s:cmd)(s:opt, s:lst[s:idx], s:arg)
    else
        call function(s:cmd)(s:opt, s:lst[s:idx])
    endif
    if a:key == 'Space'
        if !empty(s:get)
            call s:createBuffer()
        endif
        call s:pop()
    endif
endfunction
" }}}

" FUNCTION: popset#set#Back(key) {{{
function! popset#set#Back(key)
    if s:sel.isEmpty()
        call popc#ui#Msg('No upper selection.')
    else
        if a:key ==# 'u'
            call s:ps(s:sel.pop())
        elseif a:key ==# 'U'
            call s:ps(s:sel.popToRoot())
        endif
    endif
endfunction
" }}}

" FUNCTION: popset#set#Help(key) {{{
function! popset#set#Help(key)
    call s:lyr.setMode(s:MODE.Help)
    call s:lyr.setBufs(v:t_string, len(s:mapsData), popc#utils#createHelpBuffer(s:mapsData))
    call popc#ui#Create(s:lyr.name)
endfunction
" }}}

" SECTION: api functions {{{1
" All popset start from popset#set#PopSet or popset#set#PopSelection, so clear s:sel here.
" All sub-popset start from popset#set#SubPopSet or popset#set#SubPopSelection, so push s:sel here.

" FUNCTION: popset#set#SubPopSet(sopt, arg) {{{
" @param arg: Internal popset data option name.
function! popset#set#SubPopSet(sopt, arg)
    call popset#data#Init()
    let l:sel = {
        \ 'opt' : a:arg,
        \ 'sub' : {},
        \ 'idx' : 0,
        \ }
    let [l:sel['lst'], l:sel['dic'], l:sel['cmd'], l:sel['get']] = popset#data#GetOpt(a:arg)
    call s:sel.setTop('idx', s:idx)     " save upper selection's index
    call s:sel.push(l:sel)
    call s:ps(l:sel)
endfunction
" }}}

" FUNCTION: popset#set#SubPopSelection(sopt, arg) {{{
" @param arg: A dictionary in following format,
"               {
"                   \ 'opt' : [],
"                   \ 'lst' : [],
"                   \ 'dic' : {},
"                   \ 'sub' : {},
"                   \ 'cmd' : '',
"                   \ 'arg' : [],
"                   \ 'get' : '',
"               }
"               opt can NOT be empty,
"               arg MUST be NOT existed if no extra-args to cmd,
"               dic, sub, arg and get is not necessary.
function! popset#set#SubPopSelection(sopt, arg)
    let l:arg = (type(a:arg) == v:t_dict) ? a:arg : s:sub[a:arg]
    let l:sel = {
        \ 'dic' : {},
        \ 'sub' : {},
        \ 'get' : '',
        \ 'idx' : 0,
        \ }
    call extend(l:sel, l:arg, 'force')
    let l:sel['opt'] = l:arg.opt[0]
    if l:sel['cmd'] ==# 'popset#set#SubPopSelection'
        if has_key(l:sel, 'arg')
            call remove(l:sel, 'arg')
        endif
    endif
    call s:sel.setTop('idx', s:idx)     " save upper selection's index
    call s:sel.push(l:sel)
    call s:ps(l:sel)
endfunction
" }}}

" FUNCTION: popset#set#PopSet(opt) {{{
" use for popset internal data.
function! popset#set#PopSet(opt)
    call s:sel.clear()
    call popset#set#SubPopSet('popset', a:opt)
endfunction
" }}}

" FUNCTION: popset#set#PopSelection(dict) {{{
" use for popset external data.
function! popset#set#PopSelection(dict)
    call s:sel.clear()
    call popset#set#SubPopSelection('popset', a:dict)
endfunction
" }}}
