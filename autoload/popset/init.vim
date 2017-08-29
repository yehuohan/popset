
" SECTION: functions {{{1
let s:config = popset#config#Configuration()

" FUNCTION: popset#init#Init() {{{
function! popset#init#Init()
    if s:config.CompleteAll
        command! -nargs=+ -complete=option PSet :call popset#selection#SetOption(<f-args>)
    else
        command! -nargs=+ -complete=customlist,popset#data#GetOptionList PSet :call popset#selection#SetOption(<f-args>)
    endif

    " highlight for popset
    highlight default link PopsetNormal   PMenu
    highlight default link PopsetSelected PMenuSel

    call popset#key#Init()
    call popset#data#Init()
endfunction
" }}}
