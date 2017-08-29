
**PopSet** is just a vim plugin for popping selections of vim option, which will be convinient for setting vim options.

**Popset** is inspired bySzymon Wrozynski plugin [vim-CtrlSpapce](https://github.com/vim-ctrlspace/vim-ctrlspace) and some plugin code of popset is based on vim-ctrlspace and Thanks a lot.

---

## Installation

For vim-plug, add to your `.vimrc`:

```VimL
Plug 'yehuohan/popset'
```

## Settings

 - Please set `nocompatible` and `hidden` options:

```VimL
set nocompatible
set hidden
```

 - Adjust plugin colors by the following code:

```VimL
hi link PopsetNormal   PMenu
hi link PopsetSelected PMenuSel
```

 - Add your own selections by adding the following example-code to `.vimrc`:

```VimL
    let g:Popset_SelectionData = [
        \{
            \ "opt" : ["filetype", "ft"],
            \ "lst" : ["cpp", "c", "python", "vim", "markdown", "text"],
            \ "cmd" : "g:SetEqual",
        \},
        \]
    function! g:SetEqual(sopt, arg)
        execute "set " . a:sopt . "=" . a:arg
    endfunction
```


## Usage

There is only one command `PSet`, which is similar to `set` command, in popset.
For example:
```
:PSet foldmethod
```
![popset](popset.png)

In popset view, you can use following command:

```    
q       : Quit pop selection
j       : Move the selection bar down
k       : Move the selection bar up
<C-j>   : Move the selection bar one screen up
<C-k>   : Move the selection bar one screen down
<CR>    : Load the selection
<Space> : Previous the selection
?       : Show Help
```

 - Set Compeltion of `PSet` by `g:Popset_CompleteAll`:

```VimL
let g:Popset_CompleteAll = 1    " auto complete all command of vim
let g:Popset_CompleteAll = 0    " auto complete commands surpported by popset
```


## Contributor
 - yehuohan, yehuohan@qq.com, yehuohan@gmail.com

---
## TODO
 - write doc
