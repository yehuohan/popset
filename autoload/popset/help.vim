
" SECTION: variables {{{1
let s:help_text = [
    \ "q       : Quit pop selection",
    \ "j       : Move the selection bar down",
    \ "k       : Move the selection bar up",
    \ "<C-j>   : Move the selection bar one screen up",
    \ "<C-k>   : Move the selection bar one screen down",
    \ "<CR>    : Load the selection",
    \ "<Space> : Previous the selection",
    \ "?       : Show Help",
    \ ]


" SECTION: functions {{{1

" FUNCTION: popset#help#HelpText() {{{
function! popset#help#HelpText()
    let l:size = len(s:help_text)
    let l:text = ""
    let l:winwid = &columns
    for t in s:help_text
        let l:linetext = "   " . t
        let l:linetext .= repeat(' ', l:winwid - strwidth(l:linetext) + 1)
        let l:text .= l:linetext . "\n"
    endfor
    return [l:text, l:size]
endfunction
" }}}


