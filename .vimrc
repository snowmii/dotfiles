call plug#begin()

"color schemes
Plug 'dracula/vim',{'as':'dracula'}
Plug 'joshdick/onedark.vim'
Plug 'drewtempelmeyer/palenight.vim'

Plug 'Valloric/YouCompleteMe' "YCM

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

let g:airline_powerline_fonts = 1
let g:airline#extensions#hunks#enabled=1
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#enabled = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

syntax on
set background=dark
colorscheme dracula
