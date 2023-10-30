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

"Plug 'vim-autoformat/vim-autoformat'
Plug 'preservim/nerdtree'
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

" NerdTree configs
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
" Start NERDTree. If a file is specified, move the cursor to its window.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif
" Exit Vim if NERDTree is the only window remaining in the only tab.
"autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" Close the tab if NERDTree is the only window remaining in it.
"autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" Open the existing NERDTree on each new tab.
autocmd BufWinEnter * if &buftype != 'quickfix' && getcmdwintype() == '' | silent NERDTreeMirror | endif
let NERDTreeShowHidden=1
:let g:NERDTreeWinSize=60

" Other configs
set mouse=a
set shiftwidth=4 smarttab
set expandtab
set tabstop=8 softtabstop=0
set number
set termwinsize=15x0
" open terminal below all splits
cabbrev bterm bel term
" Colorscheme
syntax on
set termguicolors
set background=dark
colorscheme catppuccin_macchiato
