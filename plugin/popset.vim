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
"               where dic is not necessary.
" @param 2 preview: Is the command surpport preview or not.
" @param 3 args: The args list to cmd.
function! PopSelection(dict, ...)
    let l:preview = (a:0 >= 1) ? a:1 : 0
    if (a:0 >= 2)
        call popset#selection#SetOptionDict(a:dict, l:preview, 1, a:2)
    else
        call popset#selection#SetOptionDict(a:dict, l:preview, 0, [])
    endif
endfunction
" }}}
