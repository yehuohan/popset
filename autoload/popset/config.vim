

" SECTION: variables {{{1
let s:configuration = {
    \ "PluginName"  : "Popset",
    \ "DataPath"    : "",
    \ "CompleteAll" : 0,
    \ }

if exists("g:Popset_CompleteAll")
    let s:configuration["CompleteAll"] = g:Popset_CompleteAll
endif


" SECTION: functions {{{1

" FUNCTION: popset#config#Configuration() {{{2
function! popset#config#Configuration()
    return s:configuration
endfunction
