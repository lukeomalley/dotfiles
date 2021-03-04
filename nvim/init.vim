" Plugins
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'gruvbox-community/gruvbox'
Plug 'tpope/vim-commentary'

call plug#end()
set encoding=UTF-8

"Set Options set smarttab
set expandtab
set smartindent
set tabstop=2
set shiftwidth=2
set nu
set relativenumber
set nohlsearch
set hidden " Keep unsaved buffers in memory
set nowrap
set smartcase
set expandtab " always uses spaces instead of tab characters
set signcolumn=yes " always show signcolumns
set undodir=~/.vim/undodir
set noswapfile
set undofile
set nobackup
set incsearch
set scrolloff=8
set clipboard+=unnamedplus
set signcolumn=yes

colorscheme gruvbox
highlight Normal ctermbg=none
set guifont=Iosevka

" Remaps
let mapleader = " "
inoremap jj <ESC>
nnoremap <leader>w :w<cr>

" Ignore for ctrl-p
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'
