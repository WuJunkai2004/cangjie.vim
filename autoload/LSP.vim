" Set up the LSP client

let s:NoIdMethods = ['initialized', 'exit', 'textDocument/didOpen']

let g:lsp_workspace = ''

function! LSP#chat(method, params) abort
    let g:lsp_id += 1
    let message_json = {
                \ 'jsonrpc': '2.0',
                \ 'id': g:lsp_id,
                \ 'method': a:method,
                \ 'params': a:params
                \ }
    if(index(s:NoIdMethods, a:method) != -1)
        let message_json = {
                \ 'jsonrpc': '2.0',
                \ 'method': a:method,
                \ 'params': a:params
                \ }
    endif
    let message_str = json_encode(message_json)
    let headers = printf("Content-Length: %d\r\n\r\n", len(message_str))
    call ch_sendraw(g:lsp_client, headers . message_str)
endfunction


function! LSP#on_exit(job_id, data, event) abort
    unlet g:lsp_client
    let g:lsp_id = 0
endfunction


function! LSP#did_open() abort
    call LSP#chat('textDocument/didOpen',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \     'languageId': 'Cangjie',
                \     'version': 1,
                \     'text': join(getline(1, '$'), "\n")
                \   }
                \ })
endfunction


function! LSP#did_change_workspace_folders() abort
    call LSP#chat('workspace/didChangeWorkspaceFolders',
                \ {
                \   'event': {
                \     'added': [{
                \         'uri': 'file://' . expand(g:lsp_workspace),
                \       }
                \     ]
                \   }
                \ })
endfunction


function LSP#status() abort
    if exists('g:lsp_client')
        return 'running'
    else
        return 'stopped'
    endif
endfunction

function! LSP#init() abort
    " Check if the client is already running
    if exists('g:lsp_client')
        return
    endif

    " Start the client
    let g:lsp_client = job_start('LSPServer', {
                \ 'in_io': 'pipe',
                \ 'out_io': 'pipe',
                \ 'err_io': 'pipe',
                \ 'exit_cb': 'LSP#on_exit',
                \ })
    let g:lsp_id = 0
    
    call LSP#chat('initialize',
                \ {
                \   'processId': getpid(),
                \   'rootUri': 'file://' . expand('%:p:h'),
                \   'capabilities': {
                \     'textDocument': {
                \       'completion': v:true,
                \       'definition': v:true,
                \     }
                \   }
                \ })
    
    " sleep 5000ms for the server to initialize
    call timer_start(5000, {-> LSP#chat('initialized', {})})
endfunction


function! LSP#cmdFileOpen() abort
    " Check if the client is not running
    if !exists('g:lsp_client')
        call LSP#init()
        call timer_start(7000, {-> LSP#FileOpen()})
        return
    endif
    call LSP#did_change_workspace_folders()
    call LSP#did_open()
endfunction


function! LSP#cmdFileClose() abort
    call LSP#chat('textDocument/didClose',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   }
                \ })
endfunction


function! LSP#add_workspace(workspace) abort
    let g:lsp_workspace = a:workspace
    call LSP#did_change_workspace_folders()
endfunction


function! LSP#open_document() abort
    call LSP#did_open()
endfunction


function! LSP#stop() abort
    if exists('g:lsp_client')
        call job_stop(g:lsp_client)
        unlet g:lsp_client
        let g:lsp_id = 0
        let g:lsp_workspace = ''
    endif
endfunction