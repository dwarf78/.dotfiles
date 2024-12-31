set nocompatible 	"Use Vim settings, rather than Vi settings
set softtabstop=2	"Indent by 2 spaces when hitting tab
set shiftwidth=4	"Indent by 4 spaces when auto-indenting
set tabstop=4		"Show existing tab with 3 spaces width
syntax on			"Enable syntax highlighting
filetype indent on	"Enable indenting for files
set autoindent		"Enable auto indenting
set number			"Enable line numbers
colorscheme industry "Set nice looking colorscheme
set nobackup		"Disable backup files
set laststatus=2	"Show status line
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)
set wildmenu 		"Display command line's tab complete options as a menu.

