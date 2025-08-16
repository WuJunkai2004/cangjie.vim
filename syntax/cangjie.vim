" Vim syntax file
" Language: Cangjie
" Maintainer: Wu Junkai <wu.junkai@qq.com>
" Last Change: 2025 Aug 16
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

" 0. check the user's settings
" use let g:cangjie_<item>_color to enable/disable syntax highlighting
function! s:enabled(item) abort
    return get(g:, 'cangjie_' . a:item . '_color', 1)
endfunction

syn case match

" 1. comments
syn keyword cjTodo	TODO FIXME XXX NOTE BUG contained
syn match   cjComment /\v\/\/.*/				contains=cjTodo
syn region  cjComment start=/\/\*/ end=/\*\//	contains=cjTodo,@Spell
syn cluster cjCommentCluster contains=cjComment,cjTodo
if s:enabled('comment')
    hi def link cjComment Comment
endif

" 2. keywords
syn keyword cjDeclaration	abstract class enum extend func macro foreign
syn keyword cjDeclaration	interface open operator override private prop protected
syn keyword cjDeclaration	public redef static struct type
syn keyword cjStatement		as break case catch continue do else finally for in
syn keyword cjStatement		if in is match quote return spawn super synchronized
syn keyword cjStatement		throw try unsafe where while
syn keyword cjIdentlike	    false init main this true
syn keyword cjVariable		const let var
syn keyword cjOption		Option Some None
syn cluster cjKeywordCluster	contains=cjDeclaration,cjStatement,cjIdentlike,cjVariable,cjOption
if s:enabled('keyword')
    hi def link cjKeywordCluster Keyword
endif

" 3. specail identifiers
syn region cjSP_Identifier start=/[`]/ end=/[`]
if s:enabled('identifier')
    hi def link cjSP_Identifier Identifier
endif

" 4. types
syn keyword cjSpType		Any Nothing Range Unit Iterable
syn keyword cjArrayType		Array ArrayList VArray
syn keyword cjHashType		HashMap HashSet
syn keyword cjCommonType	Bool Byte Rune String
syn keyword cjFloatType		Float16 Float32 Float64
syn keyword cjIntType		Int8 Int16 Int32 Int64 IntNative
syn keyword cjUIntType		UInt8 UInt16 UInt32 UInt64 UIntNative
syn cluster cjTypeCluster contains=cjSpType,cjArrayType,cjHashType,cjCommonType,cjFloatType,cjIntType,cjUIntType
if s:enabled('type')
    hi def link cjTypeCluster Type
endif


" 5. number
syn match cjBinaryNumber	/\v(0b|0B)[0-1]+/
syn match cjOctalNumber		/\v(0o|0O)[0-7]+/
syn match cjHexNumber		/\v0x[0-9A-Fa-f]+/
syn match cjDecimalNumber	/\v\d+/
syn match cjFloatNumber		/\v\d+\.\d+/
syn cluster cjNumberCluster contains=cjBinaryNumber,cjOctalNumber,cjHexNumber,cjDecimalNumber,cjFloatNumber
if s:enabled('number')
    hi def link cjNumber Number
endif


" 6. package and import
syn match cjPackageKeyword /^\s*package/ contained
syn match cjImportKeyword  /^\s*import/  contained
syn region cjPackage start=/\s*package\s\+/ end=/$/ contains=cjPackageKeyword
syn region cjPackage start=/\s*import\s\+/  end=/$/ contains=cjImportKeyword
syn cluster cjPackageCluster contains=cjPackageKeyword,cjImportKeyword,cjPackage
if s:enabled('keyword')
    hi def link cjPackageKeyword Keyword
    hi def link cjImportKeyword  Keyword
endif
if s:enabled('package')
    hi def link cjPackage  PreProc
endif


" 6. character and strings, the interpolated string is a difficult part
syn cluster cjInterpolatedPart contains=cjCommentCluster,cjKeywordCluster,cjSP_Identifier,cjTypeCluster,cjNumberCluster,cjPackageCluster
syn region  cjInterpolation contained keepend start=/\${/ end=/}/ contains=@cjInterpolatedPart matchgroup=cjInterpolationDelimiter
syn match cjRune /\vr'.'/
syn region cjString start=/"/ skip=/\\\\\|\\"/ end=/"/ oneline contains=cjInterpolation
syn region cjString start=/'/ skip=/\\\\\|\\'/ end=/'/ oneline contains=cjInterpolation
syn region cjString start=/"""/ skip=/\\\\\|\\"/ end=/"""/ contains=cjInterpolation
syn region cjString start=/'''/ skip=/\\\\\|\\'/ end=/'''/ contains=cjInterpolation
syn region cjRawString start='\z(#*\)#"'  end='"#\z1'
syn region cjRawString start='\z(#*\)#\'' end='\'#\z1'
if s:enabled('string')
    hi def link cjRune		Character
    hi def link cjString	String
    hi def link cjRawString	String
	hi def link cjInterpolationDelimiter	Delimiter
endif

let b:current_syntax = "cangjie"

let &cpo = s:save_cpo
unlet s:save_cpo
