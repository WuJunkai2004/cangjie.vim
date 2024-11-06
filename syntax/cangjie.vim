" ---------------------------------------------------------
" CJ_.vim: Syntax highlighting for the CJ_ language
" ---------------------------------------------------------

" 1. 定义关键字
" ---------------------------------------------------------
syntax keyword CJ_keyword break
syntax keyword CJ_keyword class
syntax keyword CJ_keyword const
syntax keyword CJ_keyword continue
syntax keyword CJ_keyword do
syntax keyword CJ_keyword else
syntax keyword CJ_keyword enum
syntax keyword CJ_keyword extend
syntax keyword CJ_keyword false
syntax keyword CJ_keyword for
syntax keyword CJ_keyword func
syntax keyword CJ_keyword if
syntax keyword CJ_keyword in
syntax keyword CJ_keyword init
syntax keyword CJ_keyword interface
syntax keyword CJ_keyword let
syntax keyword CJ_keyword operator
syntax keyword CJ_keyword package
syntax keyword CJ_keyword private
syntax keyword CJ_keyword public
syntax keyword CJ_keyword return
syntax keyword CJ_keyword true
syntax keyword CJ_keyword var
syntax keyword CJ_keyword where
syntax keyword CJ_keyword while
highlight CJ_keyword ctermfg=Red guifg=Red


" 2. 定义标识符
" ---------------------------------------------------------
syntax match CJ_Identifier /\v[a-zA-Z_][a-zA-Z0-9_]*/
syntax match CJ_Identifier /\v`[a-zA-Z_][a-zA-Z0-9_]*`/
highlight CJ_Identifier ctermfg=Yellow guifg=Yellow


" 3. 高亮主函数和函数
" ---------------------------------------------------------
syntax match CJ_Function /\vmain\(\)/
syntax match CJ_Function /\vfunc\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(/
highlight CJ_Function ctermfg=Magenta guifg=Magenta


" 4. 定义类型
" ---------------------------------------------------------
syntax keyword CJ_keyword Array
syntax keyword CJ_keyword Bool
syntax keyword CJ_keyword Float16
syntax keyword CJ_keyword Float32
syntax keyword CJ_keyword Float64
syntax keyword CJ_keyword Int16
syntax keyword CJ_keyword Int32
syntax keyword CJ_keyword Int64
syntax keyword CJ_keyword Int8
syntax keyword CJ_keyword IntNative
syntax keyword CJ_keyword Range
syntax keyword CJ_keyword Rune
syntax keyword CJ_keyword String
syntax keyword CJ_keyword UInt16
syntax keyword CJ_keyword UInt32
syntax keyword CJ_keyword UInt64
syntax keyword CJ_keyword UInt8
syntax keyword CJ_keyword UIntNative
syntax keyword CJ_keyword Unit
syntax keyword CJ_keyword nothing
highlight CJ_Type ctermfg=LightBlue guifg=LightBlue


" 5. 定义数字
" ---------------------------------------------------------
syntax match CJ_Number /\v(0b|0B)[0-1]+|(0o|0O)[0-7]+|0x[0-9A-Fa-f]+|\d+/
syntax match CJ_Number /\v\d+\.\d+/
highlight CJ_Number ctermfg=Blue guifg=Blue


" 6. 字符串, 字符, 注释
" ---------------------------------------------------------
syntax match CJ_Rune /\vr'.'/
highlight CJ_Rune ctermfg=Cyan guifg=Cyan

syntax match CJ_String /".*"/
highlight CJ_String ctermfg=Green guifg=Green

syntax match CJ_RawString /\v#('.*')+#/
highlight CJ_RawString ctermfg=Yellow guifg=Yellow
