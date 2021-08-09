" Plugins
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'gruvbox-community/gruvbox'
Plug 'tpope/vim-commentary'
Plug 'vim-airline/vim-airline'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'evanleck/vim-svelte', {'branch': 'main'}
Plug 'ryanoasis/vim-devicons'
Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin'

call plug#end()

" Nerdtree Configuration
nnoremap <C-b> :NERDTreeClose<CR>
nnoremap <C-e> :NERDTreeFocus<CR>
let g:NERDTreeGitStatusUseNerdFonts = 1

" Split Configuration
nnoremap <C-j> :vertical resize -10<CR>
nnoremap <C-k> :vertical resize +10<CR>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
set splitbelow
set splitright

" CoC Configuration
command! -nargs=0 Prettier :CocCommand prettier.formatFile
inoremap <silent><expr> <c-space> coc#refresh()

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

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
