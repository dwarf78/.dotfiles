" General configuration
set nocompatible 	"Use Vim settings, rather than Vi settings
set showmode		"Show current mode at the bottom
set showcmd			"Show incomplete commands at the bottom

" User interface option 
set laststatus=2	"Show status line
set wildmenu 		"Display command line's tab complete options as a menu.
set title			"Set the window's title, reflecting the file currenlty being edited
set wildmenu 		"Display command line's tab complete options as a menu.
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\ %P
set cursorline		"Highlit the line currently under cursor
colorscheme industry "Set nice looking colorscheme

"Swap and backup files
set nobackup		"Disable backup files

" Indentation options
set autoindent		"Enable auto indenting
set tabstop=4		"Show existing tab with 3 spaces width
set softtabstop=2	"Indent by 2 spaces when hitting tab
set shiftwidth=4	"Indent by 4 spaces when auto-indenting

" Numbers line
set number			"Enable line numbers
set relativenumber	"Show line number on the current line and relative numbers in all other lines. Works only if the option above is enabled

" Mouse on
set mouse=a			"Enable mpuser for scrolling and resizing

" Search options
set incsearch		"Find the next match as we type the search
set hlsearch		"Highlit searches by default
set ignorecase		"Ignore case when searching...
set smartcase		" ... unless you type a capital

" Text rendering option 
set encoding=utf-8	"Use and encoding that support Unicode
syntax on			"Enable syntax highlighting
filetype indent on	"Enable indenting for files

" Undo history
set undofile		"Maintain undo history between sessions
set undodir=~/.vim/undodir


