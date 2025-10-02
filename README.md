# cangjie.vim

使 `vim` 支持 `cangjie` 语法  
如果有帮助的话，请点个`star`吧~

- [x] 语法高亮
- [x] 简单的LSP Server

## 使用方法
### 使用插件管理器
```vim
Plug 'https://gitcode.com/Neila/cangjie.vim.git'
or
Plugin 'https://gitcode.com/Neila/cangjie.vim.git'
```

### 语法高亮
目前已经支持`类型、关键字、符号`等基础高亮。  
本项目的语法高亮文件`syntax/cangjie.vim`，于 `vim 9.1.1647` 版本开始在`vim`中内置。  
稍后应该会在`neovim`中进行同步。  
> 本项目的语法高亮文件将暂停更新，除非有错误。
#### todolist
- [x] 数字
- [x] 字符串
- [x] 原始字符串
- [x] 多行字符串
- [x] 插值字符串
- [x] 注释
- [x] 注释中的提示
- [x] 导入的包名
- [x] 宏
- [ ] 带指数的数字
- [ ] 被``包裹的标识符
- [ ] 字符串内的转义字符
- [ ] 由双引号包裹的Rune字面量
- [ ] 在语法层面的代码折叠支持
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
| status | description | shortcut key | working function
| ------ | --- | --- | ---
| √ | 代码补全 | vim default shortcut, or after dot | cangjie#lsp#completion
| √ | 跳转到定义 | gd | cangjie#lsp#definition
| √ | 浏览定义 | work with 悬浮提示和签名帮助 | 
| √ | 语法检查 | use `CangjieLSP check`, can view loclist for details |
| √ | 代码格式化 | vim default shortcut | outer script `/plugin/fmt.py` 
| √ | 重命名符号 | :CangjieLSP rename [new] | 
| √ | 悬浮提示 | K, 鼠标悬浮 | cangjie#lsp#hover, cangjie#util#hover
| √ | 查找引用 | gr | 
|   | 文档符号 | not in plan, but may be supported in future |
|   | 工作区符号 | not in plan |
| √ | 签名帮助 | auto |

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
