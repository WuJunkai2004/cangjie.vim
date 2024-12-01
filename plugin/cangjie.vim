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

" 过滤掉无法使用的 Vim 版本和缺少的特性
if v:version < 820
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
command! -nargs=1 -complete=customlist,s:CJcmd CangjieLSP call cangjie#cmd(<f-args>)
function! s:CJcmd(base, line, cur)
    let commands = ['start', 'stop', 'check', 'status']
    return filter(commands, 'v:val =~ "^' . a:base . '"')
endfunction

" Cangjie LSP configure has the 3 options above:
" - always: Always run the LSP server.
" - intime: Only run in the file type is cangjie. default value.
" - never: Never run the LSP server.
if !exists('g:CJ_lsp_config')
    let g:CJ_lsp_config = 'intime'
endif

if g:CJ_lsp_config == 'always'
    call cangjie#init()
endif

if g:CJ_lsp_config == 'intime'
    augroup cangjie_lsp
        autocmd!
        " When read or create a cangjie file, initialize the LSP client
        autocmd BufRead,BufNewFile *.cj call cangjie#init()
    augroup END
endif

" 当关闭vim时，手动调用回调函数
autocmd VimLeavePre * call LSP#on_exit(0, 'exit')