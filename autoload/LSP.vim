" Set up the LSP client

function! LSP#chat(method, params) abort
    let g:lsp_id += 1
    let message_json = {
                \ 'jsonrpc': '2.0',
                \ 'id': g:lsp_id,
                \ 'method': a:method,
                \ 'params': a:params
                \ }
    let message_str = json_encode(message_json)
    let headers = printf("Content-Length: %d\r\n\r\n", len(message_str))
    call chansend(g:lsp_client, headers . message_str)
endfunction


function! LSP#on_exit(job_id, data, event) abort
    unlet g:lsp_client
    let g:lsp_id = 0
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
                \       'completion': {
                \         'completionItem': {
                \           'snippetSupport': v:true
                \         }
                \       }
                \     }
                \   }
                \ })
    
    call LSP#chat('initialized',
                \ {})
    " Send the initialization message
endfunction