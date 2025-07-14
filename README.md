
 - [Command](#3)
    - [PopSet](#3.1)
 - [Function](#4)
    - [PopSelection](#4.1)
 - [Help doc](#5)

---

**Popset** is a vim plugin to `Pop selections for operation`, which will be convinient for setting vim options, executing function with args and so on. **Popset** is implementated with [popc](https://github.com/yehuohan/popc).

For vim-plug, add to your `.vimrc`:

```vim
Plug 'yehuohan/popc'        " Must add before popset
Plug 'yehuohan/popset'
```

---
<h2 id="3">Command Usage</h2>

<h3 id="3.1">PopSet</h3>

There is only one command `PopSet`, which is similar to `set` command, in popset. What can be set by `PopSet` is all in `popset internal data`.

<div align="center">
<img alt="Popset" src="popset.gif" style="width:75%; height:auto;" />
</div>

 - Add selections to `g:Popset_SelectionData` as `popset internal data`:

```vim
"   {
"       opt : string|string[]|fun():string|fun():string[]
"             option name of selection
"       lst : string[]|fun(opt):string[]
"             the items to select
"       dic : dict<string-string>|dict<string-dict>|fun(opt):dict<string-string>|fun(opt):dict<string-dict>
"             description or sub-selection of 'lst' item
"       dsr : string|fun(opt):string
"             description for 'opt'
"       cpl : string|fun(opt):string
"             'completion' used same to input()
"       cmd : fun(opt, sel)
"             used to execute with the selected item from 'lst'
"       get : fun(opt)
"             used to get the 'opt' value
"       evt : fun(event:string, opt)
"             used to reponses to selection events
"         - 'onCR'   : called when <CR> is pressed (will be called after 'cmd' is executed)
"         - 'onQuit' : called after quit pop selection
"       sub : dict<string-lst|dst|cpl|cmd|get|evt>|fun(opt):dict<string-lst|dst|cpl|cmd|get|evt>
"             shared 'lst', 'dsr', 'cpl', 'cmd', 'get', 'evt' for sub-selection
"   }

let g:Popset_SelectionData = [
    \{
        \ "opt" : ["filetype", "ft"],
        \ "lst" : ["cpp", "c", "python", "vim", "markdown", "text"],
        \ "dic" : {
                \ "python" : "python script file",
                \ "vim": "Vim script file",
                \ },
        \ "dsr" : 'When this option is set, the FileType autocommand event is triggered.',
        \ "cpl" : 'filetype',
        \ "cmd" : "SetEqual",
        \ "get" : "GetValue"
    \}
    \]
function! SetEqual(sopt, arg)
    execute "set " . a:sopt . "=" . a:arg
endfunction
function! GetValue(sopt)
    return eval("&".a:sopt)
endfunction
```

*`opt`:* `opt[0]` should be fullname of the option, and `opt[1:-1]` can be the shortname for opt[0] if existed. Popset will take two options as the same option when "opt[0]" is equal. If the `opt` your add had been existed in popset, popset would only append the `lst` and `dic` but not override the existed one.

*`cmd`:* `cmd` is a callback which execute with args of `opt` and the selected item of `lst`. In the example code, the `SetEqual` will function as `set filtype=cpp` if you choose the selenction `cpp` from `lst`. Function signature is 'func(opt, sel)'.

 - Show all the surpported options of popset:

```vim
:PopSet popset
```
All the surpported options is according to vim-help-doc.


---
<h2 id="4">Function Usage</h2>

<h3 id="4.1">PopSelection</h3>

`PopSelection(dict)` is used to pop selections with given `dict`. The `dict` is similar to `g:Popset_SelectionData`, but **NOT** belong to `popset internal data`.

*`opt`:* Descriptiong of selection which is **NOT** requeried be different from each other. When it's list, `opt[0]` is used.

*`lst`*, *`dic`*, *`dsr`*, *`cpl`*, *`cmd`*, *`get`*, *`sub`*, *`evt`:* Similar to used in `popset internal data`.

> Note that `evt` is also a common response for sub-selection. And it can be override with `evt` of `sub`.

- A example with sub-selection:

```vim
let s:menu = {
    \ "opt" : ["Which action to execute?"],
    \ "lst" : ["new file", "open file"],
    \ "dic" : {
            \ "new file" : {
                \ "opt" : ["menu new file"],
                \ "lst" : ["a.py", "b.vim"],
                \ "dsr" : "create new file",
                \ "cmd" : {sopt, arg -> execute(":e " . arg)}
                \ },
            \ "open file" : {
                \ "opt" : ["menu open file"],
                \ "lst" : ["c.py", "d.vim"],
                \ "dsr" : "open existed file",
                \ "cmd" : {sopt, arg -> execute(":e " . arg)}
                \ }
            \ },
    \ }
" show selection
call PopSelection(s:menu)
```

- A example of selection for setttings from [use.vim](https://github.com/yehuohan/dotconfigs/blob/master/vim/.vim/viml/use.vim):

<div align="center">
<img alt="use" src="use.gif" style="width:75%; height:auto;" />
</div>

---
<h2 id="5">Help doc</h2>

More help about popset please see [popset.txt](doc/popset.txt) and [popc.txt](https://github.com/yehuohan/popc/blob/master/doc/popc.txt)
