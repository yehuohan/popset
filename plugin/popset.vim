" Popset: Pop selections for vim option settings.
" Maintainer: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
" Version: 2.1.1
"

" SETCION: vim-script {{{1
if exists("g:popset_loaded")
    finish
endif

let g:popset_loaded = 1
let g:Popc_layerInit    = {'Popset': 'popset#set#Init'}
"let g:Popc_layerComMaps = {'Popset' : ['popset#set#Pop', 'p']}

command! -nargs=+ -complete=customlist,popset#data#GetOptList PopSet :call popset#set#PopSet(<f-args>)

" FUNCTION: PopSelection(dict) {{{
function! PopSelection(dict)
    call popset#set#PopSelection(a:dict)
endfunction
" }}}
