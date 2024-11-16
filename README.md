# cangjie.vim

使 `vim` 支持 `cangjie` 语法

- [ ] 语法高亮
- [ ] LSP Server

## 使用方法
### 使用插件管理器
```vim
Plug 'https://gitcode.com/Neila/cangjie.vim.git'
or
Plugin 'https://gitcode.com/Neila/cangjie.vim.git'
```

### 语法高亮
目前已经支持`类型、关键字、大部分标识符`的高亮。
#### todolist
- [ ] 带非英文字符的标识符
- [x] 字符串
- [x] 原始字符串
- [x] 多行字符串
- [x] 注释
- [ ] ......
#### 不喜欢某些高亮？
可以通过在`.vimrc`中添加如下如下代码来关闭某些高亮。
```vim
let g:cangjie_keyword_color=0
```
示例代码中关闭了关键字的高亮。
可以被关闭的高亮有：
- cangjie_keyword_color
- cangjie_type_color
- cangjie_identifier_color
- cangjie_string_color
- cangjie_number_color
- cangjie_comment_color
- cangjie_builtin_color

### LSP Server
目前正在开发中
#### todolist
- [ ] 补全 / completion
- [ ] 跳转定义 / definition
