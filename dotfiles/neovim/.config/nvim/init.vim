if exists('g:vscode')
else

"======================================="
"            Load plugins               "
"======================================="

call plug#begin('~/.config/nvim/plugged')
  " use built-in LSP and treesitter features
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/nvim-treesitter-textobjects'
  Plug 'neovim/nvim-lspconfig'
  " auto completion and LSP codeAction alert
  Plug 'hrsh7th/nvim-compe'
  Plug 'kosayoda/nvim-lightbulb'
  " preview markdown in web browser using pandoc
  Plug 'davidgranstrom/nvim-markdown-preview'
  " fuzzy find
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  " zen mode
  Plug 'folke/zen-mode.nvim'
call plug#end()

"======================================="
"         Load colour scheme            "
"======================================="

colorscheme codedark

"======================================="
"           Setup zen-mode              "
"======================================="

lua << EOF
  require("zen-mode").setup {
  window = {
    width = 80, -- width of the Zen window
    },
  }
EOF

"======================================="
"          Setup treesitter             "
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

" load general LSP config from external file
lua require("lsp")

" gutter space for lsp info on left
set signcolumn=yes

" increased for lsp code actions
set updatetime=100

" needed for nvim-compe
set completeopt=menu,menuone,noselect

"=================="
"  nvim-lightbulb  "
"=================="

augroup lightbulb
  autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
augroup END

"=================="
"    nvim-compe    "
"=================="

let g:compe = {}
let g:compe.enabled = v:true
let g:compe.source = {'path': v:true, 'buffer': v:true, 'nvim_lsp': v:true, 'spell': v:true }

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

"======================================="
"         General Settings              "
"======================================="

" ignore file types
set wildignore+=*.png,*.jpg,*.gif,*.ico,*.svg
set wildignore+=*.wav,*.mp4,*.mp3,*.flac
set wildignore+=*.odt,*.ods,*.ott,*.doc,*.docx,*.pdf
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz

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

" automatically enter insert mode on new neovim terminals
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
let g:markdown_fenced_languages = ['bash=sh', 'javascript', 'js=javascript', 'json=javascript', 'typescript', 'ts=typescript', 'php', 'html', 'css', 'rust', 'sql']

" enable markdown folding
let g:markdown_folding = 1

" all folds start open, and bold/italic syntax hidden in markdown buffers
augroup markdown
  au FileType markdown setlocal foldlevel=99 conceallevel=2
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
"       (also see LSP mappings)             "
"                                           "
"          jk = escape                      "
"      ctrl-s = save                        "
"         ESC = search highlighting off     "
"                                           "
"  <leader>f  = format (formatprg or LSP)   "
"  <leader>l  = lint using shellcheck       "
"  <leader>cd = working dir to current file "
"  <leader>c  = edit init.vim config        "
"                                           "
"  <leader>cc = toggle colorcolumn          "
"  <leader>n  = toggle line numbers         "
"  <leader>s  = toggle spell check          "
"  <leader>w  = toggle whitespaces          "
"  <leader>z  = toggle zen mode             "
"                                           "
"  fzf.vim                                  "
"  -------                                  "
"  ctrl-p     = open file explorer          "
"  <leader>b  = open buffers                "
"  <leader>h  = open file history           "
"  <leader>rg = ripgrep search results      "
"                                           "
"  <leader>gs = git status                  "
"  <leader>gc = git commits history         "
"  <leader>gl = git files (git ls-files)    "
"                                           " 
"  text objects                             "
"  ------------                             "
"  b  = entire buffer                       "
"  ]m = @function.outer                     "
"  ]] = @class.outer                        "
"  ]M = @function.outer                     "
"  ][ = @class.outer                        "
"  [m = @function.outer                     "
"  [[ = @class.outer                        "
"  [M = @function.outer                     "
"  [] = @class.outer                        "
"==========================================="

" set leader key
let mapleader = "\<Space>"

" toggle zen mode
 nnoremap <silent><leader>z :ZenMode<CR>

" lint current buffer using shellcheck
nnoremap <leader>l :vsplit term://shellcheck %<CR>

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

" map jk to escape
inoremap jk <Esc>
tnoremap jk <C-\><C-n>

" ctrl-s to save (add stty -ixon to ~/.bashrc required)
nnoremap <silent><c-s> :<c-u>update<cr>
inoremap <silent><c-s> <c-o>:update<cr>
vnoremap <silent><c-s> <c-c>:update<cr>gv

" esc to turn off search highlighting
nnoremap <silent><esc> :noh<cr>

"=================="
"       fzf        "
"=================="

let g:fzf_preview_window = ['right:60%', 'ctrl-/']
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
" line without new line character
onoremap l :silent normal 0vg_<CR>

lua <<EOF
require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
       move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
  },
}
EOF

"======================================="
"             Functions                 "
"======================================="

function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

"======================================="
"            Status Line                "
"======================================="

set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{StatuslineGit()}
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
