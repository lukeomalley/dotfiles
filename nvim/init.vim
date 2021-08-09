" Plugins
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'gruvbox-community/gruvbox'
Plug 'tpope/vim-commentary'
Plug 'vim-airline/vim-airline'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'evanleck/vim-svelte', {'branch': 'main'}
Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'Xuyuanp/nerdtree-git-plugin'

call plug#end()

" Nerdtree Configuration
let g:NERDTreeGitStatusUseNerdFonts = 1

" CoC Prettier Configuration
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" General Config
colorscheme gruvbox
highlight Normal ctermbg=none

"Set Options 
set encoding=UTF-8
set guifont=Iosevka
set smarttab
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

" Remaps
let mapleader = " "
inoremap jk <ESC>
nnoremap <leader>w :w<cr>

" Ignore for ctrl-p
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'
