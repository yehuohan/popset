" Popset: Pop selections for vim option settings.
" Maintainer: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
" Version: 3.0.14
"

" SETCION: vim-script {{{1
if exists("g:popset_loaded")
    finish
endif

let g:popset_loaded = 1

if !exists("g:popc_loaded")
    echohl WarningMsg
    echomsg "[Popset] Popc is required!"
    echohl None
    finish
endif

command! -nargs=+ -complete=customlist,popset#data#GetSelList PopSet :call popset#set#PopSet(<f-args>)

" FUNCTION: PopSelection(dict) {{{
function! PopSelection(dict)
    call popset#set#PopSelection(a:dict)
endfunction
" }}}

call popset#set#Init()
