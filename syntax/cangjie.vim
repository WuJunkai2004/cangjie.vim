" Vim syntax file
" Language: Cangjie
" Maintainer: Wu Junkai <wu.junkai@qq.com>
" Last Change: 2025 Aug 14
"
" The Cangjie programming language is a new-generation programming
" language oriented to full-scenario intelligence. It features
" native intelligence, being naturally suitable for all scenarios,
" high performance and strong security. It is mainly applied in
" scenarios such as native applications and service applications
" of HarmonyOS NEXT, providing developers with a good programming
" experience.
"
" For more information, see:
" - https://cangjie-lang.cn/
" - https://gitcode.com/Cangjie

" quit when a syntax file was already loaded
if exists("b:current_syntax")
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

" 0. 查询设置
function! s:setting(item) abort
    return get(g:, 'cangjie_' . a:item . '_color', 1)
endfunction

syn case match

" 1. 定义关键字
" ---------------------------------------------------------
syn keyword cjKeyword abstract
syn keyword cjKeyword as
syn keyword cjKeyword break
syn keyword cjKeyword case
syn keyword cjKeyword catch
syn keyword cjKeyword class
syn keyword cjKeyword const
syn keyword cjKeyword continue
syn keyword cjKeyword do
syn keyword cjKeyword else
syn keyword cjKeyword enum
syn keyword cjKeyword extend
syn keyword cjKeyword false
syn keyword cjKeyword finally
syn keyword cjKeyword for
syn keyword cjKeyword foreign
syn keyword cjKeyword func
syn keyword cjKeyword if
syn keyword cjKeyword in
syn keyword cjKeyword init
syn keyword cjKeyword interface
syn keyword cjKeyword is
syn keyword cjKeyword let
syn keyword cjKeyword macro
syn keyword cjKeyword main
syn keyword cjKeyword match
syn keyword cjKeyword mut
syn keyword cjKeyword open
syn keyword cjKeyword operator
syn keyword cjKeyword override
syn keyword cjKeyword private
syn keyword cjKeyword prop
syn keyword cjKeyword protected
syn keyword cjKeyword public
syn keyword cjKeyword quote
syn keyword cjKeyword redef
syn keyword cjKeyword return
syn keyword cjKeyword spawn
syn keyword cjKeyword static
syn keyword cjKeyword struct
syn keyword cjKeyword super
syn keyword cjKeyword synchronized
syn keyword cjKeyword this
syn keyword cjKeyword throw
syn keyword cjKeyword true
syn keyword cjKeyword try
syn keyword cjKeyword type
syn keyword cjKeyword unsafe
syn keyword cjKeyword var
syn keyword cjKeyword where
syn keyword cjKeyword while
if s:setting('keyword')
    hi def link cjKeyword Keyword
endif


" 2. 定义标识符
" ---------------------------------------------------------
syn match cjIdentifier /\v[a-zA-Z_][a-zA-Z0-9_]*/
" 特殊标识符 1，用``包裹的标识符 2，用``包裹的关键字
syn region cjSP_Identifier start=/[`]/ end=/[`]/ contains=@cjIdentifier
syn region cjSP_Identifier start=/[`]/ end=/[`]/ contains=@cjKeyword
if s:setting('identifier')
    hi def link cjIdentifier    Identifier
    hi def link cjSP_Identifier Identifier
endif


" 3. 定义类型
" ---------------------------------------------------------
syn keyword cjType Any
syn keyword cjType Array
syn keyword cjType ArrayList
syn keyword cjType Bool
syn keyword cjType Byte
syn keyword cjType HashMap
syn keyword cjType HashSet
syn keyword cjType Float16
syn keyword cjType Float32
syn keyword cjType Float64
syn keyword cjType Int8
syn keyword cjType Int16
syn keyword cjType Int32
syn keyword cjType Int64
syn keyword cjType IntNative
syn keyword cjType Iterable
syn keyword cjType Nothing
syn keyword cjType Range
syn keyword cjType Rune
syn keyword cjType String
syn keyword cjType This
syn keyword cjType Unit
syn keyword cjType UInt8
syn keyword cjType UInt16
syn keyword cjType UInt32
syn keyword cjType UInt64
syn keyword cjType UIntNative
syn keyword cjType VArray
if s:setting('type')
    hi def link cjType Type
endif


" 4. 定义注释
" ---------------------------------------------------------
syn match cjComment /\v\/\/.*/
syn region cjComment start=/\/\*/ end=/\*\//
if s:setting('comment')
    hi def link cjComment Comment
endif


" 5. 定义数字
" ---------------------------------------------------------
syn match cjNumber /\v(0b|0B)[0-1]+|(0o|0O)[0-7]+|0x[0-9A-Fa-f]+|\d+/
syn match cjNumber /\v\d+\.\d+/
if s:setting('number')
    hi def link cjNumber Number
endif


" 6. 字符串, 字符
" ---------------------------------------------------------
syn match cjRune /\vr'.'/
syn region cjString start=/"/ skip=/\\\\\|\\"/ end=/"/ oneline
syn region cjString start=/'/ skip=/\\\\\|\\'/ end=/'/ oneline
syn region cjString start=/"""/ skip=/\\\\\|\\"/ end=/"""/
syn region cjString start=/'''/ skip=/\\\\\|\\'/ end=/'''/
syn region cjRawString start='\z(#*\)#"'  end='"#\z1'
syn region cjRawString start='\z(#*\)#\'' end='\'#\z1'
if s:setting('string')
    hi def link cjRune      String
    hi def link cjString    String
    hi def link cjRawString String
endif


" 7. Option 相关
" ---------------------------------------------------------
syn keyword cjBuiltin Option
syn keyword cjBuiltin Some
syn keyword cjBuiltin None
if s:setting('builtin')
    hi def link cjBuiltin Structure
endif


" 8. package 相关
" ---------------------------------------------------------
syn match cjPackageKeyword /^\s*package/ contained
syn match cjImportKeyword  /^\s*import/  contained
syn region cjPackage start=/\s*package\s\+/ end=/$/ contains=cjPackageKeyword
syn region cjPackage start=/\s*import\s\+/  end=/$/ contains=cjImportKeyword
if s:setting('keyword')
    hi def link cjPackageKeyword Keyword
    hi def link cjImportKeyword  Keyword
endif
if s:setting('package')
    hi def link cjPackage  PreProc
endif


let b:current_syntax = "cangjie"

let &cpo = s:save_cpo
unlet s:save_cpo
