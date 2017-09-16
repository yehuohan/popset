
" SECTION: functions {{{1
let s:config = popset#config#Configuration()


" FUNCTION: popset#init#Init() {{{
function! popset#init#Init()
    if s:config.CompleteAll
        command! -nargs=+ -complete=option PSet :call popset#selection#SetOption(<f-args>)
    else
        command! -nargs=+ -complete=customlist,popset#data#GetCompleteOptionList PSet :call popset#selection#SetOption(<f-args>)
    endif

    " highlight for popset
    highlight default link PopsetNormal   PMenu
    highlight default link PopsetSelected PMenuSel
    highlight PopsetSLInfos term=bold,reverse cterm=bold ctermfg=0 ctermbg=121 gui=bold guifg=bg guibg=LightGreen
    highlight PopsetSLValue term=standout cterm=bold ctermfg=223 ctermbg=243 gui=bold guifg=#ebdbb2 guibg=#7c6f64

    call popset#key#Init()
    call popset#data#Init()
endfunction
" }}}
