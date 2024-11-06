" ---------------------------------------------------------
" cangjie.vim: Syntax highlighting for the Cangjie language
" ---------------------------------------------------------

" 1. Define basic syntax highlighting for the Cangjie language
" ---------------------------------------------------------

" Keywords (Core keywords, control flow, and others)
syntax keyword cangjieKeyword if else true false while do for in where break continue const func operator init enum class interface extend package
highlight cangjieKeyword ctermfg=Red guifg=Red

" ---------------------------------------------------------
" 2. Define identifiers: Normal and raw identifiers
" ---------------------------------------------------------

" Normal identifiers (variables, function names, etc.)
syntax match cangjieIdentifier /\v[a-zA-Z_][a-zA-Z0-9_]*/
highlight cangjieIdentifier ctermfg=Yellow guifg=Yellow

" Raw identifiers (with backticks, can be keywords)
syntax match cangjieRawIdentifier /\v`[a-zA-Z_][a-zA-Z0-9_]*`/
highlight cangjieRawIdentifier ctermfg=Green guifg=Green

" ---------------------------------------------------------
" 3. Highlight the main function definition
" ---------------------------------------------------------

" Main function definition (e.g. main())
syntax match cangjieMainFunction /\vmain\(\)/
highlight cangjieMainFunction ctermfg=Magenta guifg=Magenta

" ---------------------------------------------------------
" 4. Define variable declaration syntax highlighting
" ---------------------------------------------------------

" Variable modifiers (let, var, private, public, static)
syntax keyword cangjieVarModifier let var private public static
highlight cangjieVarModifier ctermfg=Blue guifg=Blue

" Data types (built-in types like Int8, Bool, etc.)
syntax keyword cangjieType Int8 Int16 Int32 Int64 IntNative UInt8 UInt16 UInt32 UInt64 UIntNative Float16 Float32 Float64 Bool Rune String Array Range Unit nothing
highlight cangjieType ctermfg=Purple guifg=Purple

" Variable declaration (including modifiers, name, and types)
syntax match cangjieVariable /\v(let|var|private|public|static)?\s+[a-zA-Z_][a-zA-Z0-9_]*(:\s*[a-zA-Z0-9]+)?\s*=\s*[^,;]*/
highlight cangjieVariable ctermfg=Green guifg=Green

" ---------------------------------------------------------
" 5. Function definition syntax highlighting
" ---------------------------------------------------------

" Function definition (including func keyword, function name, parameters, return type)
syntax match cangjieFuncDef /\vfunc\s+[a-zA-Z_][a-zA-Z0-9_]*\(\s*(.*)\)\s*(?::\s*[a-zA-Z_][a-zA-Z0-9_]*)?\s*\{/
highlight cangjieFuncDef ctermfg=Yellow guifg=Yellow

" ---------------------------------------------------------
" 6. Literal values (Numbers, Booleans, Strings, and more)
" ---------------------------------------------------------

" Integer literals (supporting binary, octal, decimal, hex)
syntax match cangjieInteger /\v(0b|0B)[0-1]+|(0o|0O)[0-7]+|0x[0-9A-Fa-f]+|\d+/
highlight cangjieInteger ctermfg=Blue guifg=Blue

" Floating-point literals
syntax match cangjieFloat /\v\d+\.\d+/
highlight cangjieFloat ctermfg=Magenta guifg=Magenta

" Boolean literals (true, false)
syntax keyword cangjieBool true false
highlight cangjieBool ctermfg=LightBlue guifg=LightBlue

" Rune literals (characters enclosed in single quotes)
syntax match cangjieRune /\vr'.'/
highlight cangjieRune ctermfg=Cyan guifg=Cyan

" String literals (normal strings)
syntax match cangjieString /".*"/
highlight cangjieString ctermfg=Green guifg=Green

" Multi-line raw string literals (using # and quotes)
syntax match cangjieRawString /\v#('.*')+#/
highlight cangjieRawString ctermfg=Yellow guifg=Yellow

" ---------------------------------------------------------
" 7. Special types (Array, Range, Unit, nothing)
" ---------------------------------------------------------

" Array type
syntax keyword cangjieArray Array
highlight cangjieArray ctermfg=LightYellow guifg=LightYellow

" Range type
syntax keyword cangjieRange Range
highlight cangjieRange ctermfg=LightGreen guifg=LightGreen

" Unit type (no side effects)
syntax keyword cangjieUnit Unit
highlight cangjieUnit ctermfg=Grey guifg=Grey

" nothing type
syntax keyword cangjieNothing nothing
highlight cangjieNothing ctermfg=Grey guifg=Grey

" ---------------------------------------------------------
" 8. Control flow statements (if, for, while, break, continue)
" ---------------------------------------------------------

" Control flow statements
syntax keyword cangjieControlFlow if else for while break continue
highlight cangjieControlFlow ctermfg=Red guifg=Red

" ---------------------------------------------------------
" End of syntax highlighting for Cangjie language
" ---------------------------------------------------------

