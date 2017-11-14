" Popset: Pop selections for vim option settings.
" Maintainer: yehuohan, <yehuohan@qq.com>, <yehuohan@gmail.com>
" Version: 1.0.0
"

" SETCION: vim-script {{{1
if exists("g:popset_loaded")
    finish
endif

let g:popset_loaded = 1

call popset#init#Init()


" SETCION: functions {{{1
" FUNCTION: PopSelection(dict, preview) {{{
" @param 1 dict: A dictionary in followint format,
"               {
"                   \ "opt" : [],
"                   \ "lst" : [],
"                   \ "dic" : {},
"                   \ "cmd" : "",
"               }
" @param 2 preview: Is the command surpport preview.
function! PopSelection(...)
    if a:0 == 0
        return
    endif
    let l:dict = a:1
    let l:preview = (a:0 >= 2) ? a:2 : 0
    call popset#selection#SetOptionDict(l:dict, l:preview)
endfunction
" }}}
