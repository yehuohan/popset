
" SECTION: variables {{{1
let s:config = popset#config#Configuration()
let s:help_item_key = ["KeyQuit",
            \ "KeyMoveCursorDown", 
            \ "KeyMoveCursorUp", 
            \ "KeyMoveCursorPgDown", 
            \ "KeyMoveCursorPgUp",
            \ "KeyApplySelection", 
            \ "KeyPreviewSelection", 
            \ "KeyShowHelp"]
let s:help_text = {
    \ s:help_item_key[0]  : "Quit pop selection",
    \ s:help_item_key[1]  : "Move the selection bar down",
    \ s:help_item_key[2]  : "Move the selection bar up",
    \ s:help_item_key[3]  : "Move the selection bar one screen down",
    \ s:help_item_key[4]  : "Move the selection bar one screen up",
    \ s:help_item_key[5]  : "Load the selection",
    \ s:help_item_key[6]  : "Previous the selection",
    \ s:help_item_key[7]  : "Show Help",
    \ }


" SECTION: functions {{{1

" FUNCTION: popset#help#HelpText() {{{
function! popset#help#HelpText()
    let l:size = len(s:help_text)
    let l:text = ""
    let l:winwid = &columns
    let l:maxkeywid = 0

    " get max key text width
    for item in s:help_item_key
        let l:keywid = strwidth(join(s:config[item], ","))
        let l:maxkeywid = (l:keywid > l:maxkeywid) ? l:keywid : l:maxkeywid
    endfor
    " add 3 space width to maxkeywid
    let l:maxkeywid += 3

    for item in s:help_item_key
        let l:linetext = "   " . join(s:config[item], ",")
        " add help text
        let l:linetext .= repeat(' ', l:maxkeywid - strwidth(l:linetext)) . " : "
        let l:linetext .= s:help_text[item]
        " fill space
        let l:linetext .= repeat(' ', l:winwid - strwidth(l:linetext) + 1)
        let l:text .= l:linetext . "\n"
    endfor
    return [l:text, l:size]
endfunction
" }}}


