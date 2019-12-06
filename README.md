
 - [Installation](#1)
 - [Command Usage](#3)
    - [PopSet](#3.1)
 - [Function Usage](#4)
    - [PopSelection](#4.1)
 - [Help doc](#5)
 - [Contributor](#6)

---

**Popset** is a vim plugin to `Pop selections for operation`, which will be convinient for setting vim options, executing some function and so on.

**Popset** is a new implementation with [popc](https://github.com/yehuohan/popc). (The old implementation is in old-master branch)


---
<h2 id="1">Installation</h2>

For vim-plug, add to your `.vimrc`:

```vim
Plug 'yehuohan/popset'
Plug 'yehuohan/popc'
```

---
<h2 id="3">Command Usage</h2>

<h3 id="3.1">PopSet</h3>

There is only one command `PopSet`, which is similar to `set` command, in popset. What can be set by `PopSet` is all in `popset internal data`.

Example for `foldmethod`:
```
:PopSet foldmethod
```
![PopsetEx](popset1.gif)

Example for `colorscheme`:
```
:PopSet colorscheme
```
![PopsetEx](popset2.gif)

 - Add selections to `g:Popset_SelectionData` as `popset internal data`:

```vim
let g:Popset_SelectionData = [
    \{
        \ "opt" : ["filetype", "ft"],
        \ "lst" : ["cpp", "c", "python", "vim", "markdown", "text"],
        \ "dsr" : 'When this option is set, the FileType autocommand event is triggered.',
        \ "dic" : {
                \ "python" : "python script file",
                \ "vim": "Vim script file",
                \ },
        \ "cmd" : "g:SetEqual",
    \}
    \]
function! g:SetEqual(sopt, arg)
    execute "set " . a:sopt . "=" . a:arg
endfunction
```

**`opt`(necessary):** 

`opt` is the option name list. `opt[0]` should be fullname of the option, and `opt[1:-1]` can be the shortname for opt[0] if existed. Popset will think two options as the same option when "opt[0]" is equal. If the `opt` your add had been existed in popset, popset will append the `lst` and `dic` (no `cmd`) but not override the existed one. Hence, the `opt` of options you add must be different to other `opt` of options, or you'll mix up the `lst` and `dic` of different options.

**`lst`(necessary):**

`lst` is the selection list of the `opt`.

**`dic`(not necessary):**

`dic` is description of `lst` and `dic` can be empty.

**`cmd`(necessary):**

`cmd` is the function which must execute with `opt` and `lst` args. In the example code, for example, the `g:SetEqual` will function as `set filtype=cpp` if you choose the selenction `cpp` from `lst`. Of course, the `arg` can be any type(string, list, dictetory and so on) you want.

**`dsr`(not necessary):**

`dsr` is the description of `opt`, which will be taken as the `lst` of the popset option.


 - Show all the surpported options of popset:

```vim
:PopSet popset
```

All the surpported options is according to help-doc of vim8.0.

- Set `cmd` to `popset#set#SubPopSet` make sub selection:

All selection in the `lst` must be the `popset internal data`.

```vim
" This is the loop-selection
let g:Popset_SelectionData = [
    \{
        \ 'opt' : ['example'],
        \ 'lst' : ['example'],
        \ 'cmd' : 'popset#set#SubPopSet',
    \}
    \]
```

---
<h2 id="4">Function Usage</h2>

<h3 id="4.1">PopSelection</h3>

`PopSelection(dict)` is used to pop selections with given `dict`. The `dict` is similar to g:Popset_SelectionData, but belong to `popset external data`.

`dict` must be in the format:

```vim
let l:dict = {
    \ 'opt' : [],
    \ 'lst' : [],
    \ 'dic' : {},
    \ 'sub' : {},
    \ 'cmd' : '',
    \ 'arg' : []
    \ }
```

**`opt`(necessary):** 

Similar to `opt` in `popset internal data`.

**`lst`(necessary):**

Similar to `lst` in `popset internal data`.

**`dic`(not necessary):**

Similar to `dic` in `popset internal data`.

**`sub`(not necessary):**

`sub` is sub selection with key from `lst`. It's necessary if `cmd` is `popset#set#PopSelection`.

**`cmd`(necessary):**

Similar to `cmd` in `popset internal data`. Set `cmd` to `popset#set#SubPopSet` make sub selection. The sub selection is from `sub`.

**`arg`(not necessary):**

`arg` is the extra-args-list append to `cmd`. If `cmd` doesn't need extra-args-list, the `dict` must NOT contain the `arg` key.

A sub selection example:

```vim
let s:m_nf = {
    \ "opt" : ["menu new file"],
    \ "lst" : ["a.py", "b.vim"],
    \ "cmd" : {sopt, arg -> execute(":e " . arg)}
    \ }
let s:m_of = {
    \ "opt" : ["menu open file"],
    \ "lst" : ["c.py", "d.vim"],
    \ "cmd" : {sopt, arg -> execute(":e " . arg)}
    \ }
let s:menu = {
    \ "opt" : ["Which action to execute?"],
    \ "lst" : ["new file", "open file"],
    \ "dic" : {
            \ "new file" : "create new file",
            \ "open file" : "open existed file"
            \ },
    \ "sub" : {
            \ "new file" : s:m_nf,
            \ "open file" : s:m_of
            \ },
    \ "cmd" : "popset#set#SubPopSelection"
    \ }
call PopSelection(s:menu)
```

---
<h2 id="5">Help doc</h2>

More help about popset please see [popset.txt](https://github.com/yehuohan/popset/blob/master/doc/popset.txt) and [popc.txt](https://github.com/yehuohan/popc/blob/master/doc/popc.txt)

---
<h2 id="6">Contributor</h2>

 - yehuohan, yehuohan@qq.com, yehuohan@gmail.com


