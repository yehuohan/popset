
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
let s:cpl = ''          " completion for input
let s:Cmd = ''          " command function
let s:Get = ''          " function to get option value
let s:idx = 0           " current index of selection
let s:mapsData = [
    \ ['popset#set#Load'  , ['CR','Space'],      'Execute (Space: preview execution)'],
    \ ['popset#set#Input' , ['i','I', 'e', 'E'], 'Input or Edit selection value'],
    \ ['popset#set#Back'  , ['u','U'],           'Back to upper selection (U: back to the root-upper selection)'],
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
    let s:lyr = s:popc.addLayer('Popset', {
                \ 'bindCom' : 0,
                \ 'fnPop' : function('popset#set#PopSet', ['popset']),
                \ })

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
    if s:Get != v:null
        let l:val = s:Get(s:opt)
        let l:max += 4
    else
        unlet! l:val
        let l:max += 2
    endif
    for lst in s:lst
        " show lst
        let l:line = '  '
        if s:Get != v:null
            let l:line .= ((l:val ==# lst) ? s:conf.symbols.WIn : ' ') . ' '
        endif
        let l:line .= lst

        " show dic
        if has_key(s:dic, lst)
            let l:dsr = ''
            if type(s:dic[lst]) == v:t_dict
                " use dsr or get value of sub selection's opt
                if has_key(s:dic[lst], 'dsr')
                    let l:dsr = s:dic[lst]['dsr']
                elseif has_key(s:dic[lst], 'get')
                    let l:dsr = function(s:dic[lst].get)(s:dic[lst].opt)
                endif
            elseif type(s:dic[lst]) == v:t_string
                " use string-value of dic
                let l:dsr = s:dic[lst]
            else
                " convert value of dic to string
                let l:dsr = string(s:dic[lst])
            endif
            if !empty(l:dsr)
                let l:line .= repeat(' ', l:max - strwidth(l:line)) . ' : '
                let l:line .= l:dsr
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
" idx is current selection index.
function! s:ps(sel)
    let s:opt = a:sel['opt']
    let s:lst = a:sel['lst']
    let s:dic = a:sel['dic']
    let s:sub = a:sel['sub']
    let s:cpl = a:sel['cpl']
    let s:Cmd = a:sel['cmd']
    let s:Get = a:sel['get']
    if has_key(a:sel, 'arg')
        let s:arg = a:sel.arg
    else
        unlet! s:arg
    endif
    let s:idx = a:sel['idx']            " recover selection's index

    call s:createBuffer()
    call s:pop()
endfunction
" }}}

" FUNCTION: s:done(index, input, kepp) {{{
" @param index: The selection index
" @param input: The selection inputed by user if it's not v:null
" @param keep: Keep displaying selection after done
function! s:done(index, input, keep)
    if empty(s:lst) && a:input == v:null
        return
    endif
    let s:idx = a:index
    if !empty(s:lst)
        let l:cur = get(s:dic, s:lst[s:idx], v:null)
    endif
    if a:input != v:null
        let l:cur = get(s:dic, a:input, v:null)
    endif

    " done for sub-dict or string-list or input-string
    if type(l:cur) == v:t_dict
        let l:Fn = function('popset#set#SubPopSelection')
        let l:arg = l:cur
    else
        let l:Fn = s:Cmd
        let l:arg = (a:input != v:null) ? a:input : s:lst[s:idx]
    endif

    " callback with selection
    call popc#ui#Destroy()
    if exists('s:arg')
        call l:Fn(s:opt, l:arg, s:arg)
    else
        call l:Fn(s:opt, l:arg)
    endif

    " keep displaying selection
    if a:keep
        if s:Get != v:null
            call s:createBuffer()
        endif
        call s:pop()
    endif
endfunction
" }}}

" FUNCTION: popset#set#Load(key, index) {{{
function! popset#set#Load(key, index)
    call s:done(a:index, v:null, a:key ==# 'Space')
endfunction
" }}}

" FUNCTION: popset#set#Input(key, index) {{{
function! popset#set#Input(key, index)
    let l:text = (empty(s:lst) || a:key ==? 'i') ? '' : s:lst[a:index]
    let l:sval = popc#ui#Input('Input: ', l:text, s:cpl)
    call s:done(a:index, l:sval, a:key =~# '[ie]')
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
" default function for s:Cmd
function! s:funcCmd(sopt, arg)
    call popc#ui#Msg('There''s nothing to execute')
endfunction
" }}}

" FUNCTION: popset#set#SubPopSelection(sopt, arg, ...) {{{
" @param arg: A dictionary in following format,
"   {
"       \ 'opt' : string-list or string
"       \ 'dsr' : string
"       \ 'lst' : string-list
"       \ 'dic' : string-dict or sub-dict
"       \ 'cpl' : 'completion' used same to input()
"       \ 'cmd' : function-name or funcref or lambda
"       \ 'get' : function-name or funcref or lambda
"       \ 'arg' : any type
"   }
" 'arg' MUST be NOT existed if no extra-args to cmd.
" 'sub' is keeped for compatibility.
" @param ...: avoid calling 'popset#set#SubPopSelection' with 's:arg'
function! popset#set#SubPopSelection(sopt, arg, ...)
    let l:arg = (type(a:arg) == v:t_dict) ? a:arg : get(s:sub, a:arg, {})
    let l:sel = {
        \ 'opt' : '',
        \ 'lst' : [],
        \ 'dic' : {},
        \ 'sub' : {},
        \ 'cpl' : 'customlist,popset#set#FuncLstCompletion',
        \ 'cmd' : v:null,
        \ 'get' : v:null,
        \ 'idx' : 0,
        \ }
    call extend(l:sel, l:arg, 'force')
    " check opt
    if type(l:sel.opt) == v:t_list
        if empty(l:sel.opt)
            let l:sel.opt = ''
        else
            let l:sel.opt = l:sel.opt[0]
        endif
    endif
    " check cmd
    if type(l:sel.cmd) == v:t_func
        "
    elseif type(l:sel.cmd) == v:t_string && !empty(l:sel.cmd)
        let l:sel.cmd = function(l:sel.cmd)
    else
        let l:sel.cmd = function('s:funcCmd')
    endif
    " check get
    if type(l:sel.get) == v:t_func
        "
    elseif type(l:sel.get) == v:t_string && !empty(l:sel.get)
        let l:sel.get = function(l:sel.get)
    else
        let l:sel.get = v:null
    endif
    " handle selection
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
