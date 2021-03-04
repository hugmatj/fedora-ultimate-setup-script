#!/bin/bash

# Install Neovim 0.5 and setup in as minimal way as possible to be like Visual Studio Code with TypeScript/Bash/Rust LSP support
# On first run it will give an error as the plugins are not installed yet, type :PlugInstall and then restart
# Deno LSP needs "package.json", "tsconfig.json" or ".git" in the project root directory to run
# Deno can be used for frontend by adding /// <reference lib="dom" /> to every file that needs it

# Install Neovim 0.5 nightly (or stable if released)

curl -LOf https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
chmod u+x ./nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim

# Install vimplug

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Make directories

mkdir -p "$HOME/.config/nvim/after/indent"

# Install TypeScript formatprg fix - https://github.com/HerringtonDarkholme/yats.vim/issues/209

touch "$HOME/.config/nvim/after/indent/typescript.vim"
cat >"$HOME/.config/nvim/after/indent/typescript.vim" <<'EOL'
setlocal formatexpr=
EOL

# Create init.vim
# npm install -g prettier vscode-json-languageserver bash-language-server typescript typescript-language-server
# curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux -o ~/.local/bin/rust-analyzer
# chmod +x ~/.local/bin/rust-analyzer

mkdir -p "$HOME/.config/nvim/plugged"
cat >"$HOME/.config/nvim/init.vim" <<'EOL'
"======================================="
"            Load plugins               "
"======================================="

call plug#begin('~/.config/nvim/plugged')
  Plug 'tomasiser/vim-code-dark'
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/nvim-compe'
  Plug 'kosayoda/nvim-lightbulb'
  Plug 'davidgranstrom/nvim-markdown-preview'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
call plug#end()

"======================================="
"         Load colour scheme            "
"======================================="

colorscheme codedark

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

" search recursively with :find [*]part-of-filename [tab]
set path+=**

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
"  <leader>f  = format                      "
"  <leader>d  = delete to black hole        "
"  <leader>c  = edit init.vim config        "
"  <leader>cc = toggle colorcolumn          "
"  <leader>n  = toggle line numbers         "
"  <leader>s  = toggle spell check          "
"  <leader>w  = toggle whitespaces          "
"  <leader>t  = new terminal                "
"                                           "
"  <leader>b   = Open buffers               "
"  <leader>gl  = Git files (git ls-files)   "
"  <leader>gs  = Git files (git status)     "
"  <leader>gc  = Git commits current buffer "
"  <leader>rg  = ripgrep search results     "
"                                           "
"          jk = escape                      "
"         TAB = cycle buffers               "
"      ctrl-s = save                        "
"      ctrl-e = toggle netrw file explorer  "
"      ctrl-p = open fzf file explorer      "
"         ESC = search highlighting off     "
"==========================================="

" set leader key
let mapleader = "\<Space>"

" toggle file explorer
nnoremap <silent><C-E> :call ToggleVExplorer()<CR>

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

"=================="
"   Toggle netrw   "
"=================="

" netrw bug fix
augroup AutoDeleteNetrwHiddenBuffers
  au!
  au FileType netrw setlocal bufhidden=wipe
augroup end

" remove banner
let g:netrw_banner = 0
" use the tree list view
let g:netrw_liststyle = 3
" open in previous window
let g:netrw_browse_split = 4

function! ToggleVExplorer()
  Lexplore
  vertical resize 30
endfunction
EOL

mkdir -p "$HOME/.config/nvim/lua"
cat >"$HOME/.config/nvim/lua/lsp.lua" <<'EOL'
-- taken from https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
-- changed servers and ctermbg=237
-- added buf_set_keymap('n', 'ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)

local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead ctermbg=237 guibg=LightYellow
      hi LspReferenceText ctermbg=237 guibg=LightYellow
      hi LspReferenceWrite ctermbg=237 guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

-- Use a loop to conveniently both setup defined servers 
-- and map buffer local keybindings when the language server attaches
local servers = { "bashls", "rust_analyzer", "jsonls" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach }
end

require'lspconfig'.denols.setup{
  on_attach = on_attach,
  init_options = {
    lint = true,
  }
}
EOL
