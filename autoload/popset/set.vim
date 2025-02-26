
" popset layer.

" SECTION: variables {{{1
let s:popc = popc#popc#GetPopc()
let s:conf = popc#init#GetConfig()
let s:lyr = {}          " this layer
let s:sel = {
    \ 'stack' : [],
    \ 'top' : -1,
    \ }
" {{{ s:cur format
" opt : string|string[]|fun():string|fun():string[]
"       option name of selection
" lst : string[]|fun(opt):string[]
"       the items to select
" dic : dict<string-string>|dict<string-dict>|fun(opt):dict<string-string>|fun(opt):dict<string-dict>
"       description or sub-selection of 'lst' item
" dsr : string|fun(opt):string
"       description for 'opt'
" cpl : string|fun(opt):string
"       'completion' used same to input()
" cmd : fun(opt, sel)
"       used to execute with the selected item from 'lst'
" get : fun(opt)
"       used to get the 'opt' value
" evt : fun(event:string, opt)
"       used to reponses to selection events
"   - 'onCR'   : called when <CR> is pressed (will be called after 'cmd' is executed)
"   - 'onQuit' : called after quit pop selection
" sub : dict<string-lst|dst|cpl|cmd|get|evt>|fun(opt):dict<string-lst|dst|cpl|cmd|get|evt>
"       shared 'lst', 'dsr', 'cpl', 'cmd', 'get', 'evt' for sub-selection
" bot : is bottom selection or not (means no sub-selection)
" idx : current index of selection
" }}}
let s:cur = {}
let s:default = {
    \ 'opt' : '',
    \ 'lst' : ['Nothing'],
    \ 'dic' : {},
    \ 'dsr' : v:null,
    \ 'cpl' : 'customlist,popset#set#FuncLstCompletion',
    \ 'cmd' : v:null,
    \ 'get' : v:null,
    \ 'evt' : v:null,
    \ 'sub' : {},
    \ 'bot' : v:false,
    \ 'idx' : 0,
    \ }
let s:cpllst = []     " set s:cpllst before popset#set#FuncLstCompletion for popc#ui#Input
let s:inited = 0
let s:showDsr = v:false
let s:mapsData = [
    \ ['popset#set#Load'   , ['CR','Space'],      'Execute cmd (Space: preview execution) or evt.onCR'],
    \ ['popset#set#Input'  , ['i','I', 'e', 'E'], 'Input or Edit value of current selection '],
    \ ['popset#set#Modify' , ['m','M'],           'Modify value of selection on current cursor'],
    \ ['popset#set#Toggle' , ['n','p'],           'Next or Previous value of selection on current cursor'],
    \ ['popset#set#ShowDsr', ['d'],               'Show description/values of selection'],
    \ ['popset#set#Back'   , ['u','U'],           'Back to upper selection (U: back to the root upper selection)'],
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
                \ 'func' : 'popset#set#PopSet',
                \ 'args' : ['popset'],
                \ 'events'  : {
                    \ 'onQuit' : function('popset#set#OnQuit'),
                    \ },
                \ })
    call popc#utils#Log('popset', 'popset layer was enabled')

    for md in s:mapsData
        call s:lyr.addMaps(md[0], md[1], md[2])
    endfor
    unlet! s:mapsData
endfunction
" }}}

" FUNCTION: popset#set#OnQuit() {{{
function! popset#set#OnQuit()
    if s:cur.evt != v:null
        call s:cur.evt('onQuit', s:cur.opt)
    endif
endfunction
" }}}

" FUNCTION: popset#set#FuncLstCompletion(arglead, cmdline, cursorpos) {{{
" default completion for s:cur.lst
function! popset#set#FuncLstCompletion(arglead, cmdline, cursorpos)
    let l:completekeys = []

    for l:key in s:cpllst
        if l:key =~ "^".a:arglead
            call add(l:completekeys, l:key)
        endif
    endfor

    return l:completekeys
endfunction
" }}}

" FUNCTION: s:funcCmd(sopt, ...) {{{
" default function for s:cur.cmd
function! s:funcCmd(sopt, ...)
    call popc#ui#Msg('There''s nothing to execute')
endfunction
" }}}

" FUNCTION: s:callable(item) {{{
" return a callable function from function-name or funcref or lambda item
function! s:callable(item)
    return type(a:item) == v:t_string ? function(a:item) : a:item
endfunction
" }}}

" FUNCTION: s:try_call(item) {{{
" try call item if item is callable
function! s:try_call(item, ...)
    return type(a:item) == v:t_func ? call(a:item, a:000) : a:item
endfunction
" }}}

" FUNCTION: s:unify(arg, ...) {{{
" get unified sub-selection (called l:sel, and s:cur is called upper-selection).
" before call s:unify, must have s:cur.idx set, or provide @param a:1 as l:sel.opt.
" @param arg: original sub-selection entry
" @param root: is a root selection or not
function! s:unify(arg, root, ...)
    let l:arg = (type(a:arg) == v:t_dict) ? a:arg : {}
    " 'opt' can be from s:cur.lst[s:cur.idx]
    " 'lst', 'dsr', 'cpl', 'cmd', 'get', 'evt' can be from s:cur.sub
    let l:sel = { 'dic' : {}, 'sub' : {}, 'bot' : v:false, 'idx' : 0 }
    call extend(l:sel, l:arg, 'force')

    " check opt
    if !has_key(l:sel, 'opt')
        " the upper-selection must has 'lst'
        let l:sel.opt = (a:0 >= 1) ? a:1 : s:cur.lst[s:cur.idx]
    endif
    let l:sel.opt = s:try_call(l:sel.opt)
    if type(l:sel.opt) == v:t_list
        let l:sel.opt = empty(l:sel.opt) ? '' : l:sel.opt[0]
    endif

    " check lst
    if !has_key(l:sel, 'lst')
        let l:sel.lst = get(s:cur.sub, 'lst', [])
    endif
    let l:sel.lst = s:try_call(l:sel.lst, l:sel.opt)

    " check dic
    let l:sel.dic = s:try_call(l:sel.dic, l:sel.opt)
    let l:cnt = 0
    for val in values(l:sel.dic)
        if type(val) != v:t_dict
            let l:cnt += 1
        endif
    endfor
    let l:sel.bot = l:cnt == len(l:sel.dic)

    " check dsr
    if !has_key(l:sel, 'dsr')
        let l:sel.dsr = get(s:cur.sub, 'dsr', v:null)
    endif
    let l:sel.dsr = s:try_call(l:sel.dsr, l:sel.opt)

    " check cpl
    if !has_key(l:sel, 'cpl')
        let l:sel.cpl = get(s:cur.sub, 'cpl', 'customlist,popset#set#FuncLstCompletion')
    endif
    let l:sel.cpl = s:try_call(l:sel.cpl, l:sel.opt)

    " check cmd
    let l:sel.cmd = has_key(l:sel, 'cmd')
                \ ? s:callable(l:sel.cmd)
                \ : s:callable(get(s:cur.sub, 'cmd', 's:funcCmd'))

    " check get
    let l:sel.get = has_key(l:sel, 'get')
                \ ? s:callable(l:sel.get)
                \ : s:callable(get(s:cur.sub, 'get', v:null))

    " check evt
    if a:root
        " only evt is shared recursive
        let l:sel.evt = has_key(l:sel, 'evt')
                    \ ? s:callable(l:sel.evt)
                    \ : has_key(s:cur.sub, 'evt')
                    \       ? s:callable(s:cur.sub.evt)
                    \       : s:callable(get(s:cur, 'evt', v:null))
    endif

    " check sub
    let l:sel.sub = s:try_call(l:sel.sub, l:sel.opt)

    return l:sel
endfunction
" }}}

" FUNCTION: s:createBuffer() {{{
function! s:createBuffer()
    " get max key text width
    let l:maxlst = 0
    for item in s:cur.lst
        let l:keywid = strwidth(item)
        let l:maxlst = (l:keywid > l:maxlst) ? l:keywid : l:maxlst
    endfor

    " fix l:maxlst
    let l:maxlst += 2
    if s:cur.get != v:null
        let l:val = s:cur.get(s:cur.opt)
    endif
    let l:needsym = v:false

    " create buffer text
    let l:blks = []
    let l:maxget = 0
    for item in s:cur.lst
        call add(l:blks, [])
        " show item block
        let l:txt = '  '
        if s:cur.get != v:null && type(get(s:cur.dic, item, '')) != v:t_dict
            " compare option value only when item is not a sub-selection
            let l:txt .= ((l:val ==# item) ? s:conf.symbols.CWin : ' ') . ' '
            let l:needsym = v:true
        endif
        " Do NOT use `.=` to avoid some auto string converting error case such
        " as `l:txt .= v:true`
        let l:txt = l:txt . item
        call add(l:blks[-1], l:txt)

        " show dic block
        if has_key(s:cur.dic, item)
            let l:dsr = ''
            if type(s:cur.dic[item]) == v:t_dict
                " use value of sub-selection from 'get'
                let l:ss = s:unify(s:cur.dic[item], v:false, item)
                if l:ss.get != v:null
                    let l:val = l:ss.get(l:ss.opt)
                    " dict and list is not well show as value block
                    if type(l:val) != v:t_dict && type(l:val) != v:t_list
                        let l:wid = strwidth(l:val)
                        let l:maxget = (l:wid > l:maxget) ? l:wid : l:maxget
                        " show 'dic' value block
                        call add(l:blks[-1], l:val)
                    endif
                endif

                " use dsr of sub-selection's
                if l:ss.dsr != v:null
                    if type(l:ss.dsr) == v:t_string
                        let l:dsr .= l:ss.dsr
                    elseif type(l:ss.dsr) == v:t_func
                        let l:dsr .= l:ss.dsr(l:ss.opt)
                    endif
                else
                    let l:dsr .= string(l:ss.lst)
                endif
            elseif type(s:cur.dic[item]) == v:t_string
                " use string-value of 'dic'
                let l:dsr = s:cur.dic[item]
            else
                " convert value of 'dic' to string
                let l:dsr = string(s:cur.dic[item])
            endif
            if !empty(l:dsr)
                " show dic description block
                call add(l:blks[-1], l:dsr)
            endif
        endif
    endfor

    if l:needsym
        let l:maxlst += 2
    endif

    " tabular buffer text
    let l:text = []
    for blk in l:blks
        let l:line = blk[0]
        if len(blk) >= 2
            let l:line .= repeat(' ', l:maxlst - strwidth(blk[0])) . ' : ' . blk[1]
        endif
        if len(blk) >= 3 && s:showDsr
            let l:line .= repeat(' ', l:maxget - strwidth(blk[1])) . ' # ' . blk[2]
        endif
        call add(l:text, l:line)
    endfor

    call s:lyr.setBufs(l:text)
endfunction
" }}}

" FUNCTION: s:pop(keepIndex) {{{
function! s:pop()
    let l:text = 's' . string(s:sel.top) . '. ' . s:cur.opt
    call s:lyr.setInfo('centerText', l:text)
    call s:lyr.setInfo('lastIndex', s:cur.idx)
    call popc#ui#Create(s:lyr.name)
endfunction
" }}}

" FUNCTION: s:done(index, input, keep) {{{
" @param index: The selection index
" @param input: The selection inputed by user if it's not v:null
" @param keep: Keep displaying selection after done
" @param ensub: Enable sub-selection or not
function! s:done(index, input, keep, ensub)
    if empty(s:cur.lst) && a:input == v:null
        return
    endif
    let s:cur.idx = a:index                 " save upper-selection's index
    if !empty(s:cur.lst)
        let l:item = get(s:cur.dic, s:cur.lst[s:cur.idx], v:null)
    endif
    if a:input != v:null
        let l:item = get(s:cur.dic, a:input, v:null)
    endif

    " done for sub-dict or string-list or input-string
    let l:keep = a:keep
    if type(l:item) == v:t_dict
        " popset#set#SubPopSelection will call s:createBuffer() and s:pop,
        " so let keep=0 to avoid duplicated calling s:createBuffer() and s:pop.
        let l:keep = 0
        let l:Fn = a:ensub ? function('popset#set#SubPopSelection') : v:null
        let l:arg = l:item
    else
        let l:Fn = s:cur.cmd
        let l:arg = (a:input != v:null) ? a:input : s:cur.lst[s:cur.idx]
    endif

    " callback with selection
    call popc#ui#Destroy()
    if l:Fn != v:null
        call l:Fn(s:cur.opt, l:arg)
    endif

    " keep displaying selection
    if l:keep
        if s:cur.get != v:null
            call s:createBuffer()
        endif
        call s:pop()
    endif
endfunction
" }}}

" FUNCTION: popset#set#Load(key, index) {{{
function! popset#set#Load(key, index)
    if a:key ==# 'CR' && s:cur.evt != v:null
        call s:done(a:index, v:null, v:false, v:false)
        call s:cur.evt('onCR', s:cur.opt)
    else
        call s:done(a:index, v:null, a:key ==# 'Space', v:true)
    endif
endfunction
" }}}

" FUNCTION: popset#set#Input(key, index) {{{
function! popset#set#Input(key, index)
    let l:item = s:cur.lst[a:index]
    let s:cpllst = s:cur.lst
    let l:text = (empty(s:cur.lst) || a:key ==? 'i') ? '' : l:item
    let l:prompt = (a:key ==? 'i') ? 'Input: ' : 'Edit: '
    let l:val = popc#ui#Input(l:prompt, l:text, s:cur.cpl)
    if l:val != v:null
        call s:done(a:index, l:val, a:key =~# '[ie]', v:true)
    endif
endfunction
" }}}

" FUNCTION: popset#set#Modify(key, index) {{{
function! popset#set#Modify(key, index)
    let s:cur.idx = a:index                 " save upper-selection's index
    let l:item = s:cur.lst[a:index]
    " only sub-selection can be modified
    if has_key(s:cur.dic, l:item) && type(s:cur.dic[l:item]) == v:t_dict
        let l:ss = s:unify(s:cur.dic[l:item], v:false)
        if !l:ss.bot
            call popc#ui#Msg('The current is a sub-selection and can''t be modified')
            return
        endif
        let s:cpllst = l:ss.lst
        let l:text = ''
        if a:key ==# 'M' && l:ss.get != v:null
            call popc#ui#Toggle(0)
            let l:text = l:ss.get(l:ss.opt)
            call popc#ui#Toggle(1)
        endif
        let l:val = popc#ui#Input('Modify: ', l:text, l:ss.cpl)

        if l:val != v:null
            call popc#ui#Destroy()
            call l:ss.cmd(l:ss.opt, l:val)
            call s:createBuffer()
            call popc#ui#Create(s:lyr.name)
        endif
    else
        call popc#ui#Msg('The current selection value can''t be modified')
    endif
endfunction
" }}}

" FUNCTION: popset#set#Toggle(key, index) {{{
function! popset#set#Toggle(key, index)
    let s:cur.idx = a:index                 " save upper-selection's index
    let l:item = s:cur.lst[a:index]
    " only sub-selection can be modified
    if has_key(s:cur.dic, l:item) && type(s:cur.dic[l:item]) == v:t_dict
        let l:ss = s:unify(s:cur.dic[l:item], v:false)
        if !l:ss.bot
            call popc#ui#Msg('The current is a sub-selection and can''t be modified')
            return
        endif
        let l:text = ''
        if l:ss.get != v:null
            call popc#ui#Toggle(0)
            let l:text = l:ss.get(l:ss.opt)
            call popc#ui#Toggle(1)
        endif
        let l:idx = index(l:ss.lst, l:text)
        call popc#utils#Log('popset', 'toggle origin index: %d', l:idx)
        let l:idx = (l:idx + ((a:key ==# 'n') ? 1 : -1)) % len(l:ss.lst)
        if !empty(l:ss.lst)
            let l:val = l:ss.lst[l:idx]
            call popc#ui#Destroy()
            call l:ss.cmd(l:ss.opt, l:val)
            call s:createBuffer()
            call popc#ui#Create(s:lyr.name)
        endif
    else
        call popc#ui#Msg('The current selection value can''t be modified')
    endif
endfunction
" }}}

" FUNCTION: popset#set#ShowDsr(key, index) {{{
function! popset#set#ShowDsr(key, index)
    let s:showDsr = !s:showDsr
    call s:createBuffer()
    call s:pop()
endfunction
" }}}

" FUNCTION: popset#set#Back(key, index) {{{
function! popset#set#Back(key, index)
    if s:sel.isEmpty()
        call popc#ui#Msg('No upper selection.')
    else
        if a:key ==# 'u'
            let s:cur = s:sel.pop()
        elseif a:key ==# 'U'
            let s:cur = s:sel.popToRoot()
        endif
        call s:createBuffer()
        call s:pop()
    endif
endfunction
" }}}


" SECTION: api functions {{{1
" All popset start from popset#set#PopSet or popset#set#PopSelection, so clear s:sel here.
" All sub-popset start from popset#set#SubPopSelection, so push s:sel here.

" FUNCTION: popset#set#SubPopSelection(sopt, arg) {{{
" @param arg: A dictionary same to s:cur format
function! popset#set#SubPopSelection(sopt, arg)
    let l:sel = s:unify(a:arg, v:true)      " s:cur.idx had been set at s:done
    call s:sel.setTop('idx', s:cur.idx)     " save upper-selection's index
    call s:sel.push(l:sel)

    let s:cur = l:sel
    call s:createBuffer()
    call s:pop()
endfunction
" }}}

" FUNCTION: popset#set#PopSet(opt) {{{
" use for popset internal data.
function! popset#set#PopSet(opt)
    if !s:inited
        let s:inited = 1
        call popset#data#Init()
    endif
    let s:cur = deepcopy(s:default)
    call s:sel.clear()
    call popset#set#SubPopSelection('popset', popset#data#GetSel(a:opt))
endfunction
" }}}

" FUNCTION: popset#set#PopSelection(dict) {{{
" use for popset external data.
function! popset#set#PopSelection(dict)
    let s:cur = deepcopy(s:default)
    call s:sel.clear()
    call popset#set#SubPopSelection('popset', a:dict)
endfunction
" }}}
