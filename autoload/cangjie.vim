let s:cangjie_mainloop_id = v:null

function! cangjie#cmd(option) abort
    if a:option == 'start'
        call cangjie#init()
    elseif a:option == 'stop'
        call cangjie#stop()
    elseif a:option == 'check'
        call LSP#check()
    elseif a:option == 'status'
        echo LSP#status()
    else
        echoerr 'Unknown option: ' . a:option
    endif
endfunction


function! cangjie#init() abort
    if LSP#status() == 'stopped'
        call LSP#init()
        call timer_start(7000, {-> cangjie#init()})
        return
    endif
    call LSP#add_workspace(expand('%:p:h'))
    call LSP#open_document(expand('%:p'))

    " Start the main loop
    let s:cangjie_mainloop_id = timer_start(200, {-> cangjie#mainloop()})
endfunction


function! cangjie#stop() abort
    if s:cangjie_mainloop_id != v:null
        call timer_stop(s:cangjie_mainloop_id)
        let s:cangjie_mainloop_id = v:null
    endif
    call LSP#stop()
endfunction


function! cangjie#mainloop() abort
    if LSP#can_receive() == v:false
        return
    endif
    let response = LSP#receive()
endfunction