function! cangjie#util#cmd(option) abort
    if a:option == 'start'
        call cangjie#util#start_lsp()
    elseif a:option == 'stop'
        call cangjie#util#stop_lsp()
    elseif a:option == 'status'
        echo cangjie#lsp#status()
    else
        echoerr 'Unknown option: ' . a:option
    endif
endfunction


function! cangjie#util#indent() abort
    " 获取当前行号
    let lnum = v:lnum

    if lnum == 1
        return 0
    endif

    let prev_lnum = prevnonblank(lnum - 1)
    if prev_lnum == 0
        return 0
    endif

    let indent = indent(prev_lnum)
    let prev_line = getline(prev_lnum)

    " 规则1: 如果上一行以 '{' 或 '(' 结尾，则增加缩进
    if prev_line =~# '[({]\s*$'
        let indent += &shiftwidth
    endif

    " 规则2: 如果当前行以 '}' 或 ')' 开头，则减少缩进
    let current_line = getline(lnum)
    if current_line =~# '^\s*[})]'
        let indent -= &shiftwidth
    endif

    " 确保缩进不会小于0
    if indent < 0
        let indent = 0
    endif

    return indent
endfunction


function! cangjie#util#start_lsp() abort
    if cangjie#lsp#status() == 'dead'
        call cangjie#lsp#start_server()
        call timer_start(7000, {-> cangjie#util#start_lsp()})
        return
    endif
    " bind shortcut
    inoremap . .<Cmd>:call cangjie#lsp#complete()<CR>

    inoremap <leader>] <Cmd>:call cangjie#lsp#jump_to_definition()<CR>
    inoremap <leader>t <Cmd>:call cangjie#lsp#jump_back()<CR>

    " use F12 to jump to definition
    noremap <F12> :call cangjie#lsp#jump_to_definition()<CR>

    call cangjie#lsp#add_workspace(expand('%:p:h'))
    call cangjie#lsp#did_open()
endfunction
