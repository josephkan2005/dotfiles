let mapleader = " "
nnoremap <leader>ev :Explore<CR>
nnoremap <leader>so :so ~/.vimrc<CR>
nnoremap <leader>sv :e ~/.vimrc<CR>

set nocompatible
filetype on
filetype plugin on
filetype indent on 

syntax on
set number
set relativenumber
set cursorline
let &t_SI = "\e[5 q"
let &t_EI = "\e[2 q"

set expandtab 
set shiftwidth=4
set tabstop=4
set nobackup

set autoindent 
set smartindent

set nowrap
set incsearch 
set ignorecase
set smartcase
set showmode 
set showmatch 
set hlsearch 

:set backspace=2

set wildmenu
set wildmode=list:longest

set background=dark

set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile

call plug#begin()

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'nanotech/jellybeans.vim'
Plug 'jiangmiao/auto-pairs'

call plug#end()

nnoremap <leader>u :UndotreeToggle<CR>
let undotree_SetFocusWhenToggle=1

nnoremap <leader>sf :Files<CR>
nnoremap <leader>sg :GFiles<CR>
nnoremap <leader><leader> :Buffers<CR>
nnoremap <leader>s/ :Lines<CR>
nnoremap <leader>/ :BLines<CR>
nnoremap <leader>sp :Tags<CR>
nnoremap <leader>sb :BTags<CR>

colorscheme jellybeans
