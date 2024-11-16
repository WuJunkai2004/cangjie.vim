" plugin/cangjie.vim

" 确保插件只加载一次，避免重复
if exists("g:loaded_cangjie_syntax")
    finish
endif
let g:loaded_cangjie_syntax = 1

" 自动设置 `.cj` 文件为 cangjie 文件类型，并启用缩进规则
augroup cangjie_syntax
    autocmd!
    autocmd BufRead,BufNewFile *.cj set filetype=cangjie
    autocmd FileType cangjie setlocal cindent cinoptions={:0,}:0
augroup END

" 其他需要在 Vim 启动时加载的插件设置

if v:version < 900
    finish
endif

if !has('job')
    finish
endif

" CangjieLSP has the 4 options above:
" - start: Start the LSP server, whatever the configuration is.
" - stop: Stop the LSP server.
" - check: Check the grammar of the cangjie file.
" - status: Get the status of the LSP server.
command! -nargs=1 CangjieLSP call cangjie#cmd(<f-args>)

" Cangjie LSP configure has the 3 options above:
" - always: Always run the LSP server.
" - intime: Only run in the file type is cangjie. default value.
" - never: Never run the LSP server.
if !exists('g:CJ_lsp_config')
    let g:CJ_lsp_config = 'intime'
endif

if g:CJ_lsp_config ==# 'always'
    call LSP#init()
endif

augroup cangjie_lsp
    autocmd!
    " 当读取或新建一个 cangjie 文件时，初始化 LSP 客户端
    autocmd BufRead,BufNewFile *.cj call cangjie#init()
augroup END
