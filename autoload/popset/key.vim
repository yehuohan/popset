

" SECTION: variables {{{1
let s:key_names      = []
let s:key_maps       = {}



" SECTION: functions {{{1

" FUNCTION: popset#key#KeyNames() {{{ return s:key_names
function! popset#key#KeyNames()
    return s:key_names
endfunction
" }}}

" FUNCTION: popset#key#KeyMap() {{{ return s:key_maps
function! popset#key#KeyMaps()
    return s:key_maps
endfunction
" }}}

" FUNCTION: popset#key#Init() {{{
function! popset#key#Init()
    call s:initKeyNames()
    call s:initKeyMaps()
    call popset#pop#InitPopKeys()
endfunction
" }}}

" FUNCTION: popset#key#AddMaps(funcName, keys) {{{2
function! popset#key#AddMaps(funcName, keys, ...)
    let l:arg = []
    for a in a:000
        let l:arg = add(l:arg, '"' . a . '"')
    endfor
    for k in a:keys
        let s:key_maps[k] = a:funcName . "(" . join(l:arg, ",") . ")"
    endfor
endfunction
" }}}

" FUNCTION: s:initKeyMap() {{{
function! s:initKeyMaps()
    for k in s:key_names
        let l:key = k == '"' ? '\"' : k
        let s:key_maps[k] = "popset#key#Undefined(\"" . l:key . "\")"
    endfor
endfunction
" }}}

" FUNCTION: popset#key#Undefined(k) {{{
function! popset#key#Undefined(k)
    echo "Key '" . a:k . "' doesn't work in popset."
endfunction
" }}}

" FUNCTION: s:initKeyNames() {{{
function! s:initKeyNames()
    let lowercase = "q w e r t y u i o p a s d f g h j k l z x c v b n m"
    let uppercase = toupper(lowercase)

    let controlList = []
    for l in split(lowercase, " ")
        call add(controlList, "C-" . l)
    endfor
    call add(controlList, "C-^")
    call add(controlList, "C-]")

    let controls = join(controlList, " ")

    let numbers  = "1 2 3 4 5 6 7 8 9 0"
    let specials = "Space CR BS Tab S-Tab / ? ; : , . < > [ ] { } ( ) ' ` ~ + - _ = ! @ # $ % ^ & * C-f C-b C-u C-d C-h C-w " .
                \ "Bar BSlash MouseDown MouseUp LeftDrag LeftRelease 2-LeftMouse " .
                \ "Down Up Home End Left Right PageUp PageDown " .
                \ 'F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 "'

    let s:key_names = split(join([lowercase, uppercase, controls, numbers, specials], " "), " ")
endfunction
" }}}
