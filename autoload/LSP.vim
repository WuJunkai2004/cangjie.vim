" Set up the LSP client

let s:NoIdMethods = ['initialized', 
                   \ 'exit', 
                   \ 'textDocument/didOpen']

let g:lsp_workspace = ''
let g:lsp_id = 0

let g:lsp_history = ''

function! s:ch_send(method, params) abort
    let s:req = {}
    let s:req.method = a:method
    let s:req.jsonrpc = '2.0'
    let s:req.params = a:params
    if(index(s:NoIdMethods, a:method) == -1)
        let g:lsp_id = g:lsp_id + 1
        let s:req.id = g:lsp_id
    endif
    let s:json_req = json_encode(s:req)
    let s:header = 'Content-Length: ' . len(s:json_req) . "\r\n\r\n"
    call ch_sendraw(g:lsp_client, s:header . s:json_req)
endfunction


function! LSP#on_exit(channel, msg) abort
    unlet g:lsp_client
    let g:lsp_workspace = ''
endfunction


function! LSP#did_open() abort
    call s:ch_send('textDocument/didOpen',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \     'languageId': 'Cangjie',
                \     'version': 1,
                \     'text': join(getline(1, '$'), "\n")
                \   }
                \ })
endfunction


function! LSP#status() abort
    if !exists('g:lsp_client')
        return 'dead'
    endif
    return job_status(g:lsp_client)
endfunction

function! LSP#init() abort
    " Check if the client is already running
    if exists('g:lsp_client')
        return
    endif

    let g:lsp_workspace = expand('%:p:h')

    " Start the client
    let s:cmd = 'LSPServer'
    let s:opts = {}
    let s:opts['in_io']    = 'pipe'
    let s:opts['out_io']   = 'pipe'
    let s:opts['err_io']   = 'pipe'
    let s:opts['out_cb']   = function('s:output')
    let g:lsp_client = job_start(s:cmd, s:opts)
    
    let s:init_params = {
                \ 'processId': getpid(),
                \ 'rootUri': 'file://' . expand(g:lsp_workspace),
                \ 'capabilities': {
                \   'textDocument': {
                \     'completion': v:true,
                \     'definition': v:true,
                \     }
                \   }
                \ }
    call s:ch_send('initialize', s:init_params)
    
    " sleep 5000ms for the server to initialize
    call timer_start(5000, {-> s:ch_send('initialized', {})})
endfunction


function! LSP#cmdFileClose() abort
    call s:ch_send('textDocument/didClose',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   }
                \ })
endfunction


function! LSP#add_workspace(workspace) abort
    let s:old_workspace = g:lsp_workspace
    let g:lsp_workspace = a:workspace
    if s:old_workspace == g:lsp_workspace
        return
    endif
    call s:ch_send('workspace/didChangeWorkspaceFolders',
                \ {
                \   'event': {
                \     'added': [{
                \         'uri': 'file://' . expand(g:lsp_workspace),
                \       }
                \     ],
                \     'removed': [{
                \         'uri': 'file://' . expand(s:old_workspace),
                \       }
                \     ]
                \   }
                \ })
endfunction


function! LSP#open_document() abort
    call LSP#did_open()
endfunction


function! LSP#change_document() abort
    return
    call s:ch_send('textDocument/didChange',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \     'version': 2
                \   },
                \   'contentChanges': [{
                \     'text': join(getline(1, '$'), "\n")
                \   }]
                \ })
endfunction


function! LSP#complete() abort
    call LSP#did_open()
    call s:ch_send('textDocument/completion',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   },
                \   'position': {
                \     'line': line('.') - 1,
                \     'character': col('.'),
                \   }
                \ })
endfunction


function! LSP#stop() abort
    if exists('g:lsp_client')
        call job_stop(g:lsp_client)
    endif
endfunction


function! LSP#receive() abort
    let s:history = g:lsp_history
    let g:lsp_history = ''
    if ch_canread(g:lsp_client)
        return s:history . ch_read(g:lsp_client)
    else
        let s:history = g:lsp_history
        let g:lsp_history = ''
        return s:history
    endif
endfunction

function! LSP#can_receive() abort
    if LSP#status() == 'dead'
        return 0
    endif
    if len(g:lsp_history) > 0
        return 1
    endif
    return ch_canread(g:lsp_client)
endfunction


" 定义一个回调函数来处理任务的输出
function! s:output(channel, msg) abort
    if len(a:msg) != 0
        let g:lsp_history = g:lsp_history . a:msg
        return
    endif
    if !ch_canread(g:lsp_client)
        return
    endif
    let g:get = ch_readraw(g:lsp_client)
endfunction
