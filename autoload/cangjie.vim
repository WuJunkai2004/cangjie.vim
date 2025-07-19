function! cangjie#cmd(option) abort
    if a:option == 'start'
        call cangjie#init()
    elseif a:option == 'stop'
        call LSP#stop()
    elseif a:option == 'check'
        call LSP#check()
    elseif a:option == 'status'
        echo LSP#status()
    else
        echoerr 'Unknown option: ' . a:option
    endif
endfunction


function! cangjie#init() abort
    if LSP#status() == 'dead'
        call LSP#init()
        call timer_start(7000, {-> cangjie#init()})
        return
    endif
    " bind shortcut
    inoremap . .<C-O>:call LSP#complete()<CR>

    inoremap <leader>] <C-O>:call LSP#jump_to_definition()<CR>
    inoremap <leader>t <C-O>:call LSP#jump_back()<CR>

    " use F12 to jump to definition
    noremap <F12> :call LSP#jump_to_definition()<CR>

    call LSP#add_workspace(expand('%:p:h'))
    call LSP#open_document()
endfunction
