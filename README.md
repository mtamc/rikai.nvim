# rikai.nvim

A Neovim plugin for looking up Japanese dictionary definitions at the cursor position. Port of [Rikaikun](https://github.com/melink14/rikaikun) by melink14.

## Installation

Install just like any other plugin e.g. using vim-plug:

```vim
Plug 'mtamc/rikai.nvim'
```

## Usage

- `<leader>rk` - Look up Japanese word at cursor (normal mode)
- `:Rikai` - Look up Japanese word at cursor

## Configuration

```lua
lua << EOF
require('rikai').setup({
  -- Maximum number of dictionary entries to show
  max_entries = 7,

  -- Visually select the longest match
  select_match = true,

  -- Floating window options
  float_opts = {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = 60,
    height = 20,
    style = 'minimal', -- currently no other value supported
    border = 'rounded', -- 'none', 'single', 'double', 'rounded', 'solid', 'shadow'
  }
})
EOF
```

To use a different keybinding:

```vim
" Unset the default <leader>rk binding
nunmap <leader>rk

" Set your own keybinding
nnoremap <your-key> :Rikai<CR>
```
