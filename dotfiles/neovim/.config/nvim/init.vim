"======================================="
"            Load plugins               "
"======================================="

call plug#begin('~/.config/nvim/plugged')
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/nvim-compe'
  Plug 'kosayoda/nvim-lightbulb'
  Plug 'davidgranstrom/nvim-markdown-preview'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'tpope/vim-fugitive'
call plug#end()

"======================================="
"         Load colour scheme            "
"======================================="

colorscheme codedark

"======================================="
"          Enable treesitter            "
"======================================="

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "bash", "css", "html", "javascript", "json", "jsonc", "lua", "rust", "typescript" },
  highlight = {
    enable = true,
  },
}
EOF

"======================================="
"              Setup LSP                "
"======================================="

lua require("lsp")

augroup lightbulb
  autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
augroup END

"=================="
"    nvim-compe    "
"=================="

" https://github.com/hrsh7th/nvim-compe#vim-script-config
let g:compe = {}
let g:compe.enabled = v:true
let g:compe.autocomplete = v:true
let g:compe.debug = v:false
let g:compe.min_length = 1
let g:compe.preselect = 'enable'
let g:compe.throttle_time = 80
let g:compe.source_timeout = 200
let g:compe.incomplete_delay = 400
let g:compe.max_abbr_width = 100
let g:compe.max_kind_width = 100
let g:compe.max_menu_width = 100
let g:compe.documentation = v:true

let g:compe.source = {}
let g:compe.source.path = v:true
let g:compe.source.buffer = v:true
let g:compe.source.calc = v:true
let g:compe.source.vsnip = v:true
let g:compe.source.nvim_lsp = v:true
let g:compe.source.nvim_lua = v:true
let g:compe.source.spell = v:true
let g:compe.source.tags = v:true
let g:compe.source.snippets_nvim = v:true
let g:compe.source.treesitter = v:true
let g:compe.source.omni = v:true

" https://github.com/hrsh7th/nvim-compe#mappings
inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

" add TAB autocomplete
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

"======================================="
"              Settings                 "
"======================================="

" ignore file types
set wildignore+=*.png,*.jpg,*.gif,*.ico,*.svg
set wildignore+=*.wav,*.mp4,*.mp3,*.flac
set wildignore+=*.odt,*.ods,*.ott,*.doc,*.docx,*.pdf
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz

" increased for lsp code actions
set updatetime=100

" needed for nvim-compe
set completeopt=menu,menuone,noselect

" gutter space for lsp info on left
set signcolumn=yes

" use system clipboard by default
set clipboard=unnamedplus

" no swap files
set noswapfile

" scroll when x chars from top/bottom
set scrolloff=4

" wrap at word boundaries rather than right at the terminal edge
set linebreak

" set spell checking language
set nospell spelllang=en_us

" automatically enter insert mode on new terminals
augroup terminal
  au TermOpen * startinsert
augroup END

" improve default splitting, ctrl + w = normalize split sizes
set splitright
set splitbelow

" keep buffer window open, esp the terminal, toggle buffers without saving
set hidden

" live substitution
set inccommand=split

" highlights yanked text
augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END

"=================="
"  Tabs / spaces   "
"=================="

" converts tabs to spaces
set expandtab

" insert 2 spaces for a tab
set tabstop=2

" number of space characters inserted for indentation
set shiftwidth=2

"=================="
"  Host terminal   "
"=================="

" set to true color
set termguicolors

" set cursor to blink
set guicursor+=n-v-c:blinkon1

" change terminal title to name of file
set title

"=================="
"     Markdown     "
"=================="

" set markdown language fencing
let g:markdown_fenced_languages = ['bash=sh', 'javascript', 'js=javascript', 'json=javascript', 'typescript', 'ts=typescript', 'php', 'html', 'css', 'rust']

" enable markdown folding, toggle headings with za, zR & zM toggle all
let g:markdown_folding = 1

" all folds start open in markdown buffers
augroup markdown
  au FileType markdown setlocal foldlevel=99
augroup END

"=================="
"    Formatting    "
"=================="

augroup formatting 
  autocmd!
  autocmd FileType sh setlocal formatprg=shfmt\ -i\ 4
  autocmd FileType markdown setlocal formatprg=prettier\ --parser\ markdown
  autocmd FileType css setlocal formatprg=prettier\ --parser\ css
  autocmd FileType html setlocal formatprg=prettier\ --parser\ html
  autocmd FileType json setlocal formatprg=prettier\ --parser\ json
" use deno LSP for formatting these instead
"  autocmd FileType javascript setlocal formatprg=prettier\ --parser\ typescript
"  autocmd FileType javascript.jsx setlocal formatprg=prettier\ --parser\ typescript
"  autocmd FileType typescript setlocal formatprg=prettier\ --parser\ typescript
augroup END

"==========================================="
"         Custom Key Mappings               "
"                                           "
"          jk = escape                      "
"         TAB = cycle buffers               "
"      ctrl-s = save                        "
"      ctrl-p = open fzf file explorer      "
"         ESC = search highlighting off     "
"
"  <leader>f  = format buffer (formatprg)   "
"  <leader>l  = lint using shellcheck       "
"                                           "
"  <leader>cc = toggle colorcolumn          "
"  <leader>n  = toggle line numbers         "
"  <leader>s  = toggle spell check          "
"  <leader>w  = toggle whitespaces          "
"                                           "
"  <leader>t  = new terminal                "
"  <leader>cd = working dir to current file "
"  <leader>c  = edit init.vim config        "
"                                           "
"  <leader>b   = open buffers               "
"  <leader>h   = open file history          "
"  <leader>rg  = ripgrep search results     "
"                                           "
"  <leader>gl  = git files (git ls-files)   "
"  <leader>gs  = git files (git status)     "
"  <leader>gc  = git commits current buffer "
"  <leader>G   = git fugitive status        "
"                                           "
"==========================================="

" set leader key
let mapleader = "\<Space>"

" lint current buffer using shellcheck
nnoremap <leader>l :vsplit term://shellcheck %<CR>

" git fugitive status
nnoremap <leader>G :G<CR>

" change working directory to the location of the current file
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>

" format entire buffer and keep cursor position with mark
nnoremap <silent><leader>f mxgggqG'x<CR>

" open init.vim file
nnoremap <silent><leader>c :e $MYVIMRC<CR>

" toggle colorcolumn
nnoremap <silent><leader>cc :execute "set colorcolumn=" . (&colorcolumn == "" ? "81" : "")<CR>

" toggle line numbers
nnoremap <silent><leader>n :set invnumber<CR>

" toggle spell checking
nnoremap <silent><leader>s :set invspell<cr>

" toggle showing white spaces
set lcs+=space:.
nnoremap <silent><leader>w :set list!<cr>

" open terminal
nnoremap <silent><leader>t :terminal<CR>

" map jk to escape
inoremap jk <Esc>
tnoremap jk <C-\><C-n>

" tab to cycle buffers
nnoremap <silent><Tab> :bnext<CR> 
nnoremap <silent><S-Tab> :bprevious<CR>

" ctrl-s to save (add stty -ixon to ~/.bashrc required)
nnoremap <silent><c-s> :<c-u>update<cr>
inoremap <silent><c-s> <c-o>:update<cr>
vnoremap <silent><c-s> <c-c>:update<cr>gv

" esc to turn off search highlighting
nnoremap <silent><esc> :noh<cr>

"=================="
"       fzf        "
"=================="

nnoremap <silent><c-p> :Files!<CR>
nnoremap <silent><leader>b :Buffers!<CR>
nnoremap <silent><leader>h :History!<CR>
nnoremap <silent><leader>gl :GFiles!<CR>
nnoremap <silent><leader>gs :GFiles?<CR>
nnoremap <silent><leader>gc :BCommits!<CR>
nnoremap <silent><leader>rg :Rg!<CR>

"=================="
"   Disable keys   "
"=================="

" disable accidentally pressing ctrl-z and suspending
nnoremap <c-z> <Nop>

" disable recording
nnoremap q <Nop>

" disable arrow keys
noremap  <Up>    <Nop>
noremap  <Down>  <Nop>
noremap  <Left>  <Nop>
noremap  <Right> <Nop>
inoremap <Up>    <Nop>
inoremap <Down>  <Nop>
inoremap <Left>  <Nop>
inoremap <Right> <Nop>

"======================================="
"        Movement Mappings              "
"======================================="

" entire buffer
onoremap b :silent normal ggVG<CR>
xnoremap b :<c-u>silent normal ggVG<CR>

"======================================="
"             Functions                 "
"======================================="

"======================================="
"            Status Line                "
"======================================="

set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{FugitiveStatusline()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 
