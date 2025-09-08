" plugin/cangjie.vim

" 确保插件只加载一次，避免重复
if exists("g:loaded_cangjie_plugin")
    finish
endif
let g:loaded_cangjie_plugin = 1

" 过滤掉无法使用的 Vim 版本和缺少的特性
if !cangjie#lsp#available()
    finish
endif

" CangjieLSP has the 3 options above:
" - start: Start the LSP server, whatever the configuration is.
" - stop: Stop the LSP server.
" - status: Get the status of the LSP server.
command! -nargs=1 -complete=customlist,s:CJcmd CangjieLSP call cangjie#util#cmd(<f-args>)
function! s:CJcmd(base, line, cur)
    let commands = ['check', 'kill', 'rename', 'start', 'status']
    return filter(commands, 'v:val =~ "^' . a:base . '"')
endfunction

" Cangjie LSP configure has the 3 options above:
" - always: Always run the LSP server.
" - intime: Only run in the file type is cangjie. default value.
" - never: Never run the LSP server.
let g:CJ_lsp_config = get(g:, 'CJ_lsp_config', 'intime')
let g:CJ_lsp_config = tolower(g:CJ_lsp_config)

" The configurations of Cangjie's syntax check
let g:CJ_lsp_auto_check         = get(g:, 'CJ_lsp_auto_check', 0)
let g:CJ_lsp_auto_open_loclist  = get(g:, 'CJ_lsp_auto_open_loclist', 0)

" The configurations of Cangjie's refereces finding
let g:CJ_lsp_refer_open_qflist  = get(g:, 'CJ_lsp_refer_open_qflist', 1)
let g:CJ_lsp_refer_current_file = get(g:, 'CJ_lsp_refer_current_file', 0)

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
