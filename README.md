
**Popset** is a vim plugin to `Pop selections for vim option settings`, which will be convinient for setting vim options.

**Popset** is inspired bySzymon Wrozynski plugin [vim-CtrlSpapce](https://github.com/vim-ctrlspace/vim-ctrlspace) and some plugin code of popset is based on vim-ctrlspace and Thanks a lot.


---
## Installation

For vim-plug, add to your `.vimrc`:

```vim
Plug 'yehuohan/popset'
```

---
## Settings

 - Set `nocompatible` options:

```vim
set nocompatible
```

---
## Usage

There is only one command `PSet`, which is similar to `set` command, in popset.
Example for `foldmethod`:
```
:PSet foldmethod
```
![PopsetEx](popset1.gif)

Example for `colorscheme`:
```
:PSet colorscheme
```
![PopsetEx](popset2.gif)


In popset view, you can use following command:

```    
q       : Quit pop selection
j       : Move the selection bar down
k       : Move the selection bar up
<C-j>   : Move the selection bar one screen down
<C-k>   : Move the selection bar one screen up
<CR>    : Load the selection
<Space> : Preview the selection
?       : Show Help
```

 - Set Completion of `PSet` by `g:Popset_CompleteAll`:

```vim
let g:Popset_CompleteAll = 1    " auto complete all command of vim
let g:Popset_CompleteAll = 0    " auto complete commands surpported by popset
```

 - Add your own selections by adding the following example code to `.vimrc`:

```vim
    let g:Popset_SelectionData = [
        \{
            \ "opt" : ["filetype", "ft"],
            \ "lst" : ["cpp", "c", "python", "vim", "markdown", "text"],
            \ "dic" : {
                    \ "python" : "python script file",
                    \ "vim": "Vim script file",
                    \ },
            \ "cmd" : "g:SetEqual",
        \},
        \]
    function! g:SetEqual(sopt, arg)
        execute "set " . a:sopt . "=" . a:arg
    endfunction
```

The key `opt` is the option name list to add, `lst` is the selections of the `opt`, `dic` is simple description of `lst` and `dic` can be empty, and `cmd` is the function that should be called with `opt` and `lst` args. In the example code, for example, the `g:SetEqual` will function as `set filtype=cpp` if you choose the selenction `cpp` for `lst`. Of course, the `arg` can be any type(string, list, dictetory and so on) if you want.

If the `opt` your add had been existed in popset, popset will append the `lst` and `dic` (no `cmd`) but not override the existed one. Hence, the `opt` of options you add must be different to other `opt` of options, or you'll mix up the `lst` and `dic` of different options.

 - Show all the surpported options of popset:

```vim
:PSet popset
```

- More help about popset please see [popset.txt](https://github.com/yehuohan/popset/blob/master/doc/popset.txt)

---
## Contributor
 - yehuohan, yehuohan@qq.com, yehuohan@gmail.com


