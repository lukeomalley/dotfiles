call plug#begin('~/.vim/plugged')
" General Plugins
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'sainnhe/gruvbox-material'
Plug 'jdhao/better-escape.vim'
Plug 'tpope/vim-commentary'

" LSP Plugins
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer', {'branch': 'main'}
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}

" Nvim Tree
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'

" Code Formatter
Plug 'sbdchd/neoformat'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'BurntSushi/ripgrep'

" Indent Blankline
Plug 'lukas-reineke/indent-blankline.nvim'

" Smooth Scroll
Plug 'terryma/vim-smooth-scroll'

" Git Fugitive
Plug 'tpope/vim-fugitive'

call plug#end()

" Color Theme
syntax enable
set termguicolors
set background=dark
highlight Normal guibg=none guifg=#fffaf0

let g:gruvbox_material_background = 'hard'
let g:gruvbox_material_foreground = 'material'
let g:gruvbox_material_transparent_background = 1
let g:gruvbox_material_better_performance = 1
let g:airline_theme = 'gruvbox_material'
colorscheme gruvbox-material

" Hide the ~ character at the end of buffers
set fillchars=fold:\ ,vert:\│,eob:\ ,msgsep:‾

" Split Configuration
set splitbelow
set splitright
" nnoremap <C-j> :vertical resize -10<CR>
" nnoremap <C-k> :vertical resize +10<CR>
nnoremap <C-l> <C-W><C-L>
nnoremap <C-h> <C-W><C-H>

" Highlight on yank
au TextYankPost * silent! lua vim.highlight.on_yank()

" Quick Fix List Mappings
nnoremap [q :cprev<cr>
nnoremap ]q :cnext<cr>

" Disable the auto comment when inserting new line
au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Icons for LSP
sign define LspDiagnosticsSignError text=
sign define LspDiagnosticsSignWarning text=
sign define LspDiagnosticsSignInformation text=כֿ
sign define LspDiagnosticsSignHint text=

"Set Options
set encoding=UTF-8
set guifont=InconsolataNerdFontMono
set smarttab
set expandtab
set smartindent
set ignorecase " Make search case in-sensitive
set tabstop=2
set shiftwidth=2
set nu
set relativenumber
set nohlsearch
set hidden " Keep unsaved buffers in memory
set nowrap
set expandtab " always uses spaces instead of tab characters
set signcolumn=yes " always show signcolumns
set undodir=~/.vim/undodir
set noswapfile
set undofile
set nobackup
set incsearch
set scrolloff=8
set clipboard+=unnamedplus
set updatetime=100

let mapleader = " "
inoremap jk <ESC>
nnoremap <Leader>w :w<CR>

" Nvim Tree a list of groups can be found at `:help nvim_tree_highlight`
highlight NvimTreeFolderIcon guibg=none

" Disable the python, ruby and perl provider
let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0
let g:loaded_perl_provider = 0

" Lua
lua require 'config'
