" Rikai.nvim - Japanese dictionary lookup for Neovim
" Author: mtamc
" License: GPL-3.0

if exists('g:loaded_rikai')
  finish
endif
let g:loaded_rikai = 1

lua << EOF
  -- Load and setup rikai
  require('rikai').setup()
EOF
