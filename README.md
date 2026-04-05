# rikai.nvim

A Neovim plugin for looking up Japanese dictionary definitions at the cursor position. Port of [Rikaikun](https://github.com/melink14/rikaikun) by melink14.

<img width="778" height="524" alt="1775379457_" src="https://github.com/user-attachments/assets/bc92848a-c421-4552-a202-c8b7116915df" />

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
    relative = 'cursor', -- 'editor' | 'win' | 'cursor' | 'mouse'
    row = 1, -- vertical offset
    col = 0, -- horizontal offset
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
