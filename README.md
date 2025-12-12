# cangjie.vim

使 `vim` 支持 `cangjie` 语法  
如果有帮助的话，请点个`star`吧~

- [x] 语法高亮
- [x] Language Server Protocol (LSP) 支持

## 使用方法
### 使用插件管理器
```vim
Plug 'https://gitcode.com/Neila/cangjie.vim.git'
or
Plugin 'https://gitcode.com/Neila/cangjie.vim.git'
```

### 语法高亮
目前已经支持`类型、关键字、符号`等基础高亮，和大量进阶高亮。  
本项目的语法高亮文件`syntax/cangjie.vim`，于 `vim 9.1.1647` 版本开始在`vim`中内置。  
并已经在`neovim`中被同步。  
> 若有高亮缺失，请提交`issue`或`PR`。
#### todolist
- [x] 数字
- [x] 字符串
- [x] 原始字符串
- [x] 多行字符串
- [x] 插值字符串
- [x] 注释
- [x] 注释中的提示
- [x] 注释中的信息(e.g. @brief @author @date)
- [x] 导入的包名
- [x] 宏
- [x] 带指数的数字
- [x] 被``包裹的标识符
- [x] 字符串内的转义字符
- [x] 由双引号包裹的Rune字面量
- [x] 在语法层面的代码折叠支持
- [ ] 在`std.core`中的函数（这些函数默认导入）
- [ ] 待补充
#### 不喜欢某些高亮？
可以通过在`.vimrc`中添加如下如下代码来关闭某些高亮。
```vim
let g:cangjie_keyword_color = 0
```
示例代码中关闭了关键字的高亮。
可以被关闭的高亮有：
```vim
let g:cangjie_comment_color = 0
let g:cangjie_identifier_color = 0
let g:cangjie_keyword_color = 0
let g:cangjie_macro_color = 0
let g:cangjie_number_color = 0
let g:cangjie_operator_color = 0
let g:cangjie_string_color = 0
let g:cangjie_type_color = 0
```


### LSP Server
仅在高于`vim8.2`的版本中支持。  
#### todolist
| status | description | shortcut key
| ------ | --- | ---
| √ | 代码补全 | vim 默认补全键 `<C-x><C-o>`, 或输入`.`后自动补全
| √ | 跳转到定义 | `gd`
| √ | 浏览定义 | 配合悬浮提示和签名帮助使用
| √ | 语法检查 | 使用命令 `:CangjieLSP check`，或开启自动检查功能; 使用 `:lopen` 查看错误列表
| √ | 代码格式化 | vim 默认格式化键(如`gg=G`)
| √ | 重命名符号 | 使用命令 `:CangjieLSP rename [new]`
| √ | 悬浮提示 | `K`键查看详情; 鼠标悬浮查看语法错误提示
| √ | 查找引用 | `gr`; 使用 `:popen` 查看引用列表
|   | 文档符号 | 暂无计划，或许会在未来实现
|   | 工作区符号 | 暂无计划
| √ | 签名帮助 | 输入`(`或`,`时自动弹出签名帮助
|   | sign栏的错误提示 | 计划中
|   | 保存时自动格式化 | 计划中

#### 配置项与配置命令
##### 启动配置
```vim
" 总是开启LSP
let g:CJ_lsp_config = 'always'
```
可选配置 | 描述
--- | ---
`always` | 总是开启
`intime` | 仅在打开cj文件时开启
`never` | 从不开启

默认配置为`intime`。

##### 语法检查配置
```vim
" 在光标静止5秒后，自动触发语法检查
" 由于性能原因，默认关闭，1为开启
let g:CJ_lsp_auto_check = 1

" 语法检查时，是否自动打开loclist窗口
" 默认关闭，1为开启
let g:CJ_lsp_auto_open_loclist = 1
```

##### 引用查找配置
```vim
" 查找引用时自动打开quickfix窗口
" 默认开启，0为关闭
let g:CJ_lsp_refer_open_qflist = 0

" 查找引用时仅显示当前文件内的引用
" 会影响 quickfix 窗口的显示内容
" 默认关闭，1为开启
let g:CJ_lsp_refer_current_file = 0
```

##### 配置命令
```vim
CangjieLSP start        " 无视配置项，强制开启LSP
CangjieLSP kill         " 无视配置项，强制关闭LSP
CangjieLSP status       " 查看当前LSP状态
CangjieLSP check        " 语法检查
CangjieLSP rename [new] " 重命名符号，将当前光标所在符号重命名为[new]
```
