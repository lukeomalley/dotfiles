call plug#begin('~/.vim/plugged')
" General Plugins
Plug 'sainnhe/gruvbox-material'
Plug 'jdhao/better-escape.vim'
Plug 'tpope/vim-commentary'

" LSP Plugins
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer', {'branch': 'main'}
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'onsails/lspkind-nvim'

" Nvim Tree
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'

" Prettier - post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'sbdchd/neoformat'

" Snippets
Plug 'hrsh7th/vim-vsnip'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Indent Blankline
Plug 'lukas-reineke/indent-blankline.nvim'
"Plug 'Yggdroot/indentLine'

" Smooth Scroll
Plug 'terryma/vim-smooth-scroll'

" Git Fugitive
Plug 'tpope/vim-fugitive'

call plug#end()

" Disable the python provider
let g:loaded_python3_provider = 0

" Disable the ruby provider
let g:loaded_ruby_provider = 0

" Disable the perl provider
let g:loaded_perl_provider = 0

" Color Theme
syntax enable
set termguicolors
set background=dark
highlight Normal guibg=none guifg=#fffaf0
let g:gruvbox_material_background = 'hard'
let g:gruvbox_material_transparent_background = 1
colorscheme gruvbox-material

" Hide the ~ character at the end of buffers
set fillchars=fold:\ ,vert:\│,eob:\ ,msgsep:‾

" Required for nvim completion
set completeopt=menu,menuone,noinsert

inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

"Split Configuration
nnoremap <C-j> :vertical resize -10<CR>
nnoremap <C-k> :vertical resize +10<CR>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
set splitbelow
set splitright

" Quick Fix List Mappings
nnoremap [q :cprev<cr>
nnoremap ]q :cnext<cr>


" Disable the auto comment when inserting new line
au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

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
set tabstop=2
set shiftwidth=2
set nu
" set relativenumber
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
set updatetime=100

let mapleader = " "
inoremap jk <ESC>
nnoremap <Leader>w :w<CR>

" Neoformat
let g:neoformat_try_node_exe = 1
autocmd BufWritePre *.js,*.ts,*.css,*.scss,*.graphql,*.html,*.tsx Neoformat

" Nvim Tree a list of groups can be found at `:help nvim_tree_highlight`
highlight NvimTreeFolderIcon guibg=none

" Lua
lua require 'config'
