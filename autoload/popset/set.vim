
" popset layer.

" SECTION: variables {{{1
let s:popc = popc#popc#GetPopc()
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
let s:cpl = ''          " completion for input
let s:cmd = ''          " command function
let s:arg = []          " args of command
let s:get = ''          " function to get option value
let s:idx = 0           " current index of selection
let s:mapsData = [
    \ ['popset#set#Load'  , ['CR','Space'], 'Execute (Space: preview execution)'],
    \ ['popset#set#Input' , ['i','I'],      'Input selection value'],
    \ ['popset#set#Back'  , ['u','U'],      'Back to upper selection (U: back to the root-upper selection)'],
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
    let s:lyr = s:popc.addLayer('Popset', 0)

    for md in s:mapsData
        call s:lyr.addMaps(md[0], md[1], md[2])
    endfor
    unlet! s:mapsData

    call popset#data#Init()
endfunction
" }}}

" FUNCTION: s:createBuffer() {{{
function! s:createBuffer()
    let l:text = []
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
            if type(s:dic[lst]) == v:t_string
                let l:line .= repeat(' ', l:max - strwidth(l:line)) . ' : '
                let l:line .= s:dic[lst]
            elseif type(s:dic[lst]) == v:t_dict
                if has_key(s:dic[lst], 'dsr')
                    let l:line .= repeat(' ', l:max - strwidth(l:line)) . ' : '
                    let l:line .= s:dic[lst]['dsr']
                elseif has_key(s:dic[lst], 'get')
                    let l:line .= repeat(' ', l:max - strwidth(l:line)) . ' : '
                    let l:line .= function(s:dic[lst].get)(s:dic[lst].opt)
                endif
            endif
        endif
        call add(l:text, l:line)
    endfor

    call s:lyr.setBufs(v:t_list, l:text)
endfunction
" }}}

" FUNCTION: s:pop(keepIndex) {{{
function! s:pop()
    let l:text = 's' . string(s:sel.top) . '. ' . s:opt
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
"                   \ 'cpl' : '',
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
    let s:cpl = a:sel['cpl']
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

" FUNCTION: popset#set#Load(key, index) {{{
function! popset#set#Load(key, index)
    if empty(s:lst)
        return
    endif

    let s:idx = a:index
    let l:val = get(s:dic, s:lst[s:idx], v:none)
    if type(l:val) == v:t_dict
        let l:Fn = function('popset#set#SubPopSelection')
        let l:arg = l:val
    "elseif type(l:val) == v:t_list
        " TODO
    else
        let l:Fn = function(s:cmd)
        let l:arg = s:lst[s:idx]
    endif

    call popc#ui#Destroy()
    if exists('s:arg')
        call l:Fn(s:opt, l:arg, s:arg)
    else
        call l:Fn(s:opt, l:arg)
    endif
    if a:key ==# 'Space'
        if !empty(s:get)
            call s:createBuffer()
        endif
        call s:pop()
    endif
endfunction
" }}}

" FUNCTION: popset#set#Input(key, index) {{{
function! popset#set#Input(key, index)
    let l:text = ''
    if a:key ==# 'I'
        let s:idx = a:index
        let l:text = s:lst[s:idx]
    endif
    let l:sval = popc#ui#Input('Input: ', l:text, s:cpl)
    if empty(l:sval)
        return
    endif
    call popc#ui#Destroy()
    if exists('s:arg')
        call function(s:cmd)(s:opt, l:sval, s:arg)
    else
        call function(s:cmd)(s:opt, l:sval)
    endif
endfunction
" }}}

" FUNCTION: popset#set#Back(key, index) {{{
function! popset#set#Back(key, index)
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


" SECTION: api functions {{{1
" All popset start from popset#set#PopSet or popset#set#PopSelection, so clear s:sel here.
" All sub-popset start from popset#set#SubPopSelection, so push s:sel here.

" FUNCTION: popset#set#FuncLstCompletion(arglead, cmdline, cursorpos) {{{
" default completion for s:lst
function! popset#set#FuncLstCompletion(arglead, cmdline, cursorpos)
    let l:completekeys = []

    for l:key in s:lst
        if l:key =~ "^".a:arglead
            call add(l:completekeys, l:key)
        endif
    endfor

    return l:completekeys
endfunction
" }}}

" FUNCTION: s:funcCmd(sopt, arg) {{{
" default function for s:cmd
function! s:funcCmd(sopt, arg)
    call popc#ui#Msg('There''s nothing to execute')
endfunction
" }}}

" FUNCTION: popset#set#SubPopSelection(sopt, arg, ...) {{{
" @param arg: A dictionary in following format,
"               {
"                   \ 'opt' : [],
"                   \ 'lst' : [],
"                   \ 'dic' : {},
"                   \ 'sub' : {},
"                   \ 'cpl' : '',
"                   \ 'cmd' : '',
"                   \ 'arg' : [],
"                   \ 'get' : '',
"               }
"               opt, lst and cmd is necessary,
"               dic, sub, arg, cpl and get is not necessary,
"               arg MUST be NOT existed if no extra-args to cmd.
function! popset#set#SubPopSelection(sopt, arg, ...)
    let l:arg = (type(a:arg) == v:t_dict) ? a:arg : get(s:sub, a:arg, {})
    let l:sel = {
        \ 'opt' : '',
        \ 'lst' : [],
        \ 'dic' : {},
        \ 'sub' : {},
        \ 'cpl' : 'customlist,popset#set#FuncLstCompletion',
        \ 'cmd' : 's:funcCmd',
        \ 'get' : '',
        \ 'idx' : 0,
        \ }
    call extend(l:sel, l:arg, 'force')
    if type(l:sel.opt) == v:t_list
        let l:sel.opt = l:sel.opt[0]
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
    call popset#set#SubPopSelection('popset', popset#data#GetSel(a:opt))
endfunction
" }}}

" FUNCTION: popset#set#PopSelection(dict) {{{
" use for popset external data.
function! popset#set#PopSelection(dict)
    call s:sel.clear()
    call popset#set#SubPopSelection('popset', a:dict)
endfunction
" }}}
