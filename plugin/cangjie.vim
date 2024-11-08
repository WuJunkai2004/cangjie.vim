" plugin/cangjie.vim

" 确保插件只加载一次，避免重复
if exists("g:loaded_cangjie_syntax")
    finish
endif
let g:loaded_cangjie_syntax = 1

" 自动设置 `.cj` 文件为 cangjie 文件类型，并启用语法高亮
augroup cangjie_syntax
    autocmd!
    autocmd BufRead,BufNewFile *.cj set filetype=cangjie
augroup END

" 其他需要在 Vim 启动时加载的插件设置

if v:version < 900
    finish
endif

if !has('job')
    finish
endif

augroup cangjie_lsp
    autocmd!
    " 当读取或新建一个 cangjie 文件时，初始化 LSP 客户端
    autocmd BufRead,BufNewFile *.cj call LSP#init()
augroup END