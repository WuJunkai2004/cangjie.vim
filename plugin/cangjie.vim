" plugin/cangjie.vim

" 确保插件只加载一次，避免重复
if exists("g:loaded_cangjie_syntax")
    finish
endif
let g:loaded_cangjie_syntax = 1

" 设置插件初始化命令

" 自动设置 `.cj` 文件为 cangjie 文件类型，并启用语法高亮
augroup cangjie_syntax
    autocmd!
    autocmd BufRead,BufNewFile *.cj set filetype=cangjie
augroup END

" 其他需要在 Vim 启动时加载的插件设置

