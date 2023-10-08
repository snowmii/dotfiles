" Install vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin()

"Plug 'EdenEast/nightfox.nvim'
"Plug 'tomasiser/vim-code-dark'
Plug 'catppuccin/vim',{'as':'catppuccin'}
"Plug 'arcticicestudio/nord-vim'
"Plug 'dracula/vim',{'as':'dracula'}
"Plug 'joshdick/onedark.vim'
"Plug 'drewtempelmeyer/palenight.vim'

"Plug 'tpope/vim-surround'
"Plug 'Valloric/YouCompleteMe' "YCM

Plug 'tpope/vim-fugitive'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tribela/vim-transparent'
Plug 'junegunn/fzf.vim'

call plug#end()

" Airline configs
let g:airline_powerline_fonts = 1
let g:airline#extensions#hunks#enabled=1
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#enabled = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

set shiftwidth=4 smarttab
set expandtab
set tabstop=8 softtabstop=0
set number
" Colorscheme
syntax on
set termguicolors
set background=dark
colorscheme catppuccin_macchiato
