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
> 当前正在修改`cangjie.vim`的语法高亮规则，以期并入`vim`主分支。  
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
- [ ] 待补充
#### 不喜欢某些高亮？
可以通过在`.vimrc`中添加如下如下代码来关闭某些高亮。
```vim
let g:cangjie_keyword_color=0
```
示例代码中关闭了关键字的高亮。
可以被关闭的高亮有：
```vim
let g:cangjie_keyword_color    = 0
let g:cangjie_type_color       = 0
let g:cangjie_string_color     = 0
let g:cangjie_number_color     = 0
let g:cangjie_comment_color    = 0
let g:cangjie_builtin_color    = 0
let g:cangjie_package_color    = 0
```


### LSP Server
仅在高于`vim8.2`的版本中支持。  
> 目前正在开发中, 若有需求请联系我。  
#### todolist
| status | description | shortcut key | working function
| ------ | --- | --- | ---
| √ | 补全 | vim default shortcut, or after dot | LSP#complete
| √ | 跳转定义 | F12 | LSP#jump_to_definition
|   | 浏览定义 | | 
| √ | 语法检查 | :CangjieLPS check | LSP#check
| √ | 代码格式化 | vim default shortcut gg=G | outer script `/plugin/fmt.py` 
|   | 重命名符号 | | 
|   | 浮窗显示提示 | |

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

##### 配置命令
```vim
CangjieLPS start        " 无视配置项，强制开启LSP
CangjieLPS stop         " 无视配置项，强制关闭LSP
CangjieLPS status       " 查看当前LSP状态
CangjieLPS check        " 对当前文件进行语法检查
```
