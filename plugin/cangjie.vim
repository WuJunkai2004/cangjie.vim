" plugin/cangjie.vim

" 确保插件只加载一次，避免重复
if exists("g:loaded_cangjie_plugin")
    finish
endif
let g:loaded_cangjie_plugin = 1

" 过滤掉无法使用的 Vim 版本和缺少的特性
if v:version < 820
    finish
endif

if !has('job')
    finish
endif

if !executable('LSPServer')
    finish
endif

" CangjieLSP has the 4 options above:
" - start: Start the LSP server, whatever the configuration is.
" - stop: Stop the LSP server.
" - status: Get the status of the LSP server.
command! -nargs=1 -complete=customlist,s:CJcmd CangjieLSP call cangjie#util#cmd(<f-args>)
function! s:CJcmd(base, line, cur)
    let commands = ['start', 'stop', 'status']
    return filter(commands, 'v:val =~ "^' . a:base . '"')
endfunction

" Cangjie LSP configure has the 3 options above:
" - always: Always run the LSP server.
" - intime: Only run in the file type is cangjie. default value.
" - never: Never run the LSP server.
let g:CJ_lsp_config = get(g:, 'CJ_lsp_config', 'intime')
let g:CJ_lsp_config = tolower(g:CJ_lsp_config)

if g:CJ_lsp_config == 'always'
    call cangjie#util#start_lsp()
    augroup cangjie_lsp
        autocmd!
        autocmd BufRead,BufNewFile *.cj call cangjie#util#setup_for_buffer()
        autocmd VimLeavePre * call cangjie#lsp#on_exit(0, 'exit')
    augroup END
endif

if g:CJ_lsp_config == 'intime'
    augroup cangjie_lsp
        autocmd!
        autocmd BufRead,BufNewFile *.cj call cangjie#util#start_lsp()
        autocmd BufRead,BufNewFile *.cj call cangjie#util#setup_for_buffer()
        autocmd VimLeavePre * call cangjie#lsp#on_exit(0, 'exit')
    augroup END
endif
