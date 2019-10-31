" Popset: Pop selections for vim option settings.
" Maintainer: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
" Version: 2.0.2
"

" SETCION: vim-script {{{1
if exists("g:popset_loaded")
    finish
endif

let g:popset_loaded = 1
let g:Popc_layerInit    = {'Popset': 'popset#set#Init'}
"let g:Popc_layerComMaps = {'Popset' : ['popset#set#Pop', 'p']}

command! -nargs=+ -complete=customlist,popset#data#GetOptList PSet :call popset#set#PSet(<f-args>)

" FUNCTION: PopSelection(dict, ...) {{{
" @param 1 dict: A dictionary in followint format,
"               {
"                   \ "opt" : [],
"                   \ "lst" : [],
"                   \ "dic" : {},
"                   \ "cmd" : "",
"               }
"               where dic is not necessary.
" @param 2 preview: Is the command surpport preview or not.
" @param 3 args: The args list to cmd.
function! PopSelection(dict, ...)
    let l:preview = (a:0 >= 1) ? a:1 : 0
    if (a:0 >= 2)
        call popset#set#PopSelection(a:dict, l:preview, a:2)
    else
        call popset#set#PopSelection(a:dict, l:preview)
    endif
endfunction
" }}}
