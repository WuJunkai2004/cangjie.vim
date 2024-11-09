" ---------------------------------------------------------
" CJ_.vim: Syntax highlighting for the CJ_ language
" ---------------------------------------------------------

" 0. 查询设置
function! s:Setting(item) abort
    return get(g:, 'cangjie_' . a:item . '_color', 1)
endfunction


" 1. 定义关键字
" ---------------------------------------------------------
syntax keyword CJ_Keyword abstract
syntax keyword CJ_Keyword as
syntax keyword CJ_Keyword break
syntax keyword CJ_Keyword case
syntax keyword CJ_Keyword catch
syntax keyword CJ_Keyword class
syntax keyword CJ_Keyword const
syntax keyword CJ_Keyword continue
syntax keyword CJ_Keyword do
syntax keyword CJ_Keyword else
syntax keyword CJ_Keyword enum
syntax keyword CJ_Keyword extend
syntax keyword CJ_Keyword false
syntax keyword CJ_Keyword finally
syntax keyword CJ_Keyword for
syntax keyword CJ_Keyword foreign
syntax keyword CJ_Keyword func
syntax keyword CJ_Keyword if
syntax keyword CJ_Keyword import
syntax keyword CJ_Keyword in
syntax keyword CJ_Keyword init
syntax keyword CJ_Keyword interface
syntax keyword CJ_Keyword is
syntax keyword CJ_Keyword let
syntax keyword CJ_Keyword macro
syntax keyword CJ_Keyword main
syntax keyword CJ_Keyword match
syntax keyword CJ_Keyword mut
syntax keyword CJ_Keyword open
syntax keyword CJ_Keyword operator
syntax keyword CJ_Keyword override
syntax keyword CJ_Keyword package
syntax keyword CJ_Keyword private
syntax keyword CJ_Keyword prop
syntax keyword CJ_Keyword protected
syntax keyword CJ_Keyword public
syntax keyword CJ_Keyword quote
syntax keyword CJ_Keyword redef
syntax keyword CJ_Keyword return
syntax keyword CJ_Keyword spawn
syntax keyword CJ_Keyword static
syntax keyword CJ_Keyword struct
syntax keyword CJ_Keyword super
syntax keyword CJ_Keyword synchronized
syntax keyword CJ_Keyword this
syntax keyword CJ_Keyword throw
syntax keyword CJ_Keyword true
syntax keyword CJ_Keyword try
syntax keyword CJ_Keyword type
syntax keyword CJ_Keyword unsafe
syntax keyword CJ_Keyword var
syntax keyword CJ_Keyword where
syntax keyword CJ_Keyword while
highlight link CJ_Keyword Keyword


" 2. 定义标识符
" ---------------------------------------------------------
syntax match CJ_Identifier /\v[a-zA-Z_][a-zA-Z0-9_]*/
" 特殊标识符 1，用``包裹的标识符 2，用``包裹的关键字
syntax region CJ_SP_Identifier start=/[`]/ end=/[`]/ contains=@CJ_Identifier
syntax region CJ_SP_Identifier start=/[`]/ end=/[`]/ contains=@CJ_Keyword
if s:Setting('identifier')
    highlight link CJ_Identifier    Identifier
    highlight link CJ_SP_Identifier Identifier
endif


" 3. 定义类型
" ---------------------------------------------------------
syntax keyword CJ_Type Any
syntax keyword CJ_Type Array
syntax keyword CJ_Type Bool
syntax keyword CJ_Type Rune
syntax keyword CJ_Type Float16
syntax keyword CJ_Type Float32
syntax keyword CJ_Type Float64
syntax keyword CJ_Type Int8
syntax keyword CJ_Type Int16
syntax keyword CJ_Type Int32
syntax keyword CJ_Type Int64
syntax keyword CJ_Type IntNative
syntax keyword CJ_Type Nothing
syntax keyword CJ_Type String
syntax keyword CJ_Type This
syntax keyword CJ_Type Unit
syntax keyword CJ_Type UInt8
syntax keyword CJ_Type UInt16
syntax keyword CJ_Type UInt32
syntax keyword CJ_Type UInt64
syntax keyword CJ_Type UIntNative
syntax keyword CJ_Type VArray
highlight link CJ_Type Type


" 4. 定义注释
" ---------------------------------------------------------
syntax match CJ_Comment /\v\/\/.*/
syntax region CJ_Comment start=/\/\*/ end=/\*\//
highlight link CJ_Comment Comment


" 5. 定义数字
" ---------------------------------------------------------
syntax match CJ_Number /\v(0b|0B)[0-1]+|(0o|0O)[0-7]+|0x[0-9A-Fa-f]+|\d+/
syntax match CJ_Number /\v\d+\.\d+/
highlight link CJ_Number Number


" 6. 字符串, 字符
" ---------------------------------------------------------
syntax match CJ_Rune /\vr'.'/
syntax match CJ_String /".*"/
syntax match CJ_RawString /\v#('.*')+#/
highlight link CJ_Rune      String
highlight link CJ_String    String
highlight link CJ_RawString String


" 7. Option 相关
" ---------------------------------------------------------
syntax keyword CJ_Builtin Option
syntax keyword CJ_Builtin Some
syntax keyword CJ_Builtin None
highlight link CJ_Builtin Structure
