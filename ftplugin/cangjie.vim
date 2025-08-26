if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

" LSP diagnostics support(error, warning, hint)
highlight CJ_Error   cterm=underline gui=undercurl guisp=red    ctermbg=red
highlight CJ_Warning cterm=underline gui=undercurl guisp=yellow ctermbg=yellow
highlight CJ_Hint    cterm=underline gui=underline guisp=blue   ctermbg=blue

" comment setting
setlocal commentstring=//\ %s
setlocal comments=sr:/*,mb:*,ex:*/,://,b:#,b:>,b:+,b:-

" format setting
setlocal formatoptions=tcqjro

" for completion (both omnifunc and keyword completion)
setlocal omnifunc=cangjie#lsp#completion
setlocal complete=.,w,t,i

setlocal completeopt=menuone

" formatting tools and commands
if executable('cjfmt') && ( executable('python3') || executable('python') )
    let s:ftplugin_path = expand('<sfile>:p')
    let s:plugin_root = fnamemodify(s:ftplugin_path, ':h:h')
    let s:formatter_path = s:plugin_root . '/plugin/fmt.py'
    if executable('python3')
        let s:python_cmd = 'python3'
    else
        let s:python_cmd = 'python'
    endif
    if filereadable(s:formatter_path)
        let &l:equalprg  = s:python_cmd . ' ' . shellescape(s:formatter_path)
        let &l:formatprg = s:python_cmd . ' ' . shellescape(s:formatter_path)
    endif
endif

" compile setting
setlocal makeprg=cjpm\ build

" cangjie indent settings
setlocal indentkeys=0{,0},0(,0),o,O
setlocal indentexpr=cangjie#util#indent()

" lsp settings
if cangjie#lsp#available()
    augroup cangjie_lsp_buffer_display
        autocmd!
        autocmd BufEnter <buffer> call cangjie#util#redraw_highlight()
        autocmd BufHidden <buffer> call cangjie#util#clear_highlight(str2nr(expand('<abuf>')))
    augroup END
endif

" lsp diagnostics hint
if cangjie#lsp#available() && ( has('balloon_eval') || has('balloon_eval_term') )
    setlocal ballooneval
    setlocal balloonevalterm
    setlocal balloonexpr=cangjie#util#hover()
endif
