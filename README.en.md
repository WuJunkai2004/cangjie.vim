# cangjie.vim

`vim` support for `cangjie` syntax.
If this helps, please give it a `star`~

- [x] Syntax highlighting
- [x] Language Server Protocol (LSP) support

[简体中文](./README.md) | English

## Usage
### Using a Plugin Manager
```vim
Plug 'https://gitcode.com/Neila/cangjie.vim.git'
or
Plugin 'https://gitcode.com/Neila/cangjie.vim.git'
```

### Syntax Highlighting
Currently supports basic highlighting for `types, keywords, symbols`, and a large amount of advanced highlighting.
The syntax highlighting file `syntax/cangjie.vim` of this project is built-in to `vim` starting from `vim 9.2`.
It has also been synchronized in `neovim`.
> If there is missing highlighting, please submit an `issue` or `PR`.
#### todolist
- [x] Numbers
- [x] Strings
- [x] Raw strings
- [x] Multi-line strings
- [x] Interpolated strings
- [x] Comments
- [x] Hints in comments
- [x] Information in comments (e.g. @brief @author @date)
- [x] Imported package names
- [x] Macros
- [x] Numbers with exponents
- [x] Identifiers wrapped in backticks
- [x] Escape characters in strings
- [x] Rune literals wrapped in double quotes
- [x] Syntax-level code folding support
- [x] Functions, classes, and interfaces in `std.core`
- [ ] To be added
#### Don't like some highlights?
You can disable certain highlights by adding the following code to your `.vimrc`.
```vim
let g:cangjie_keyword_color = 0
```
The example code disables keyword highlighting.
Highlights that can be disabled are:
```vim
let g:cangjie_builtin_color = 0
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
Only supported in versions higher than `vim8.2`.
> If you need more features, please submit an `issue` or `PR`.
#### todolist
| status | description | shortcut key
| ------ | --- | ---
| √ | Code completion | vim default completion key `<C-x><C-o>`, or auto-complete after typing `.`
| √ | Go to definition | `gd`
| √ | Hover definition | Used with hover tips and signature help
| √ | Syntax check | Use command `:CangjieLSP check`, or enable auto-check; use `:lopen` to view error list
| √ | Code formatting | vim default formatting key (e.g., `gg=G`)
| √ | Rename symbol | Use command `:CangjieLSP rename [new]`
| √ | Hover tips | `K` to view details; hover mouse to view syntax error tips
| √ | Find references | `gr`; use `:popen` to view reference list
|   | Document symbols | No plan yet, might be implemented in the future
|   | Workspace symbols | No plan yet
| √ | Signature help | Automatically pop up signature help when typing `(` or `,`
|   | Error signs in sign column | In planning
| √ | Auto-format on save | Enable by configuration, runs automatically before save

#### Configuration Options and Commands
##### Startup Configuration
```vim
" Always enable LSP
let g:CJ_lsp_config = 'always'
```
Option | Description
--- | ---
`always` | Always enable
`intime` | Only enable when opening cj files
`never` | Never enable

The default configuration is `intime`.

##### Custom LSP Command
```vim
" Customize the LSPServer startup command, accepts String or List
" Default command is: ['LSPServer', '--enable-log=false']
let g:CJ_lsp_cmd = 'LSPServer --enable-log=false'

" When the command or path contains spaces, use the List form to avoid ambiguity
let g:CJ_lsp_cmd = ['/path with spaces/LSPServer', '--enable-log=false']
```

###### Using with cangjie-lsp-wrapper
[cangjie-lsp-wrapper](https://github.com/ystyle/cangjie-lsp-wrapper) is a Cangjie LSP wrapper that automatically parses `cjpm.toml` / `cjpm.lock` to generate LSP initialization parameters, saving you from maintaining the environment manually.

Refer to its repository for installation and usage. Once ready, point `g:CJ_lsp_cmd` at it:
```vim
let g:CJ_lsp_cmd = ['cangjie-lsp-wrapper', '-V']

" Use an absolute path if it is not on your PATH
let g:CJ_lsp_cmd = ['/absolute/path/to/cangjie-lsp-wrapper', '-V']
```

##### Syntax Check Configuration
```vim
" Automatically trigger syntax check after the cursor is idle for 5 seconds
" Disabled by default due to performance reasons, set to 1 to enable
let g:CJ_lsp_auto_check = 1

" Whether to automatically open the loclist window during syntax check
" Disabled by default, set to 1 to enable
let g:CJ_lsp_auto_open_loclist = 1
```

##### Formatting Configuration
```vim
" Auto-format on save
" Disabled by default, set to 1 to enable
let g:CJ_lsp_auto_format_on_save = 1
```

##### Reference Find Configuration
```vim
" Automatically open quickfix window when finding references
" Enabled by default, set to 0 to disable
let g:CJ_lsp_refer_open_qflist = 0

" Only show references in the current file when finding references
" Affects the content displayed in the quickfix window
" Disabled by default, set to 1 to enable
let g:CJ_lsp_refer_current_file = 0
```

##### Configuration Commands
```vim
CangjieLSP start        " Ignore configuration, forcibly enable LSP
CangjieLSP kill         " Ignore configuration, forcibly disable LSP
CangjieLSP status       " View current LSP status
CangjieLSP check        " Syntax check
CangjieLSP rename [new] " Rename symbol, rename the symbol at the current cursor to [new]
```
