" Set up the LSP client

let s:NoIdMethods = ['initialized', 
                   \ 'exit', 
                   \ 'textDocument/didOpen',
                   \ 'textDocument/didChange']

let g:cj_lsp_workspace = ''
let g:cj_lsp_id = 0

let g:cj_lsp_history = ''

let g:cj_file_version = {}


function! LSP#log(msg) abort
    " save to a file named lsp.log
    let s:log_file = expand('./lsp.log')
    call writefile([a:msg], s:log_file, 'a')
endfunction


function! s:ch_send(method, params) abort
    let s:req = {}
    let s:req.method = a:method
    let s:req.jsonrpc = '2.0'
    let s:req.params = a:params
    if(index(s:NoIdMethods, a:method) == -1)
        let g:cj_lsp_id = g:cj_lsp_id + 1
        let s:req.id = g:cj_lsp_id
    endif
    let s:json_req = json_encode(s:req)
    let s:header = 'Content-Length: ' . len(s:json_req) . "\r\n\r\n"
    call ch_sendraw(g:cj_lsp_client, s:header . s:json_req)
endfunction


function! LSP#did_open() abort
    let s:file = 'file://' . expand('%:p')
    if !has_key(g:cj_file_version, s:file)
        let g:cj_file_version[s:file] = 1
    else
        let g:cj_file_version[s:file] = g:cj_file_version[s:file] + 1
    endif
    call s:ch_send('textDocument/didOpen',
                \ {
                \   'textDocument': {
                \     'uri': s:file,
                \     'languageId': 'Cangjie',
                \     'version': g:cj_file_version[s:file],
                \     'text': join(getline(1, '$'), "\n")
                \   }
                \ })
endfunction


function! LSP#status() abort
    if !exists('g:cj_lsp_client')
        return 'dead'
    endif
    return job_status(g:cj_lsp_client)
endfunction

function! LSP#init() abort
    " Check if the client is already running
    if exists('g:cj_lsp_client')
        return
    endif

    let g:cj_lsp_workspace = expand('%:p:h')

    " Start the client
    let s:cmd = 'LSPServer'
    let s:opts = {}
    let s:opts['in_io']   = 'pipe'
    let s:opts['out_io']  = 'pipe'
    let s:opts['err_io']  = 'pipe'
    let s:opts['out_cb']  = function('s:lsp_callback')
    let s:opts['exit_cb'] = function('LSP#on_exit')
    let g:cj_lsp_client = job_start(s:cmd, s:opts)
    
    let s:init_params = {
                \ 'processId': getpid(),
                \ 'rootUri': 'file://' . expand(g:cj_lsp_workspace),
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


function! LSP#add_workspace(workspace) abort
    let s:old_workspace = g:cj_lsp_workspace
    let g:cj_lsp_workspace = a:workspace
    if s:old_workspace == g:cj_lsp_workspace
        return
    endif
    call s:ch_send('workspace/didChangeWorkspaceFolders',
                \ {
                \   'event': {
                \     'added': [{
                \         'uri': 'file://' . expand(g:cj_lsp_workspace),
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
    let s:file = 'file://' . expand('%:p')
    if !has_key(g:cj_file_version, s:file)
        let g:cj_file_version[s:file] = 1
    else
        let g:cj_file_version[s:file] = g:cj_file_version[s:file] + 1
    endif
    call s:ch_send('textDocument/didChange',
                \ {
                \   'textDocument': {
                \     'uri': s:file,
                \     'version': g:cj_file_version[s:file]
                \   },
                \   'contentChanges': [{
                \     'text': join(getline(1, '$'), "\n")
                \   }]
                \ })
endfunction


function! LSP#complete() abort
    call LSP#change_document()
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
    if exists('g:cj_lsp_client')
        call job_stop(g:cj_lsp_client)
    endif
endfunction


function! s:lsp_callback(channel, msg) abort
    if len(a:msg) != 0
        let g:cj_lsp_history = g:cj_lsp_history . a:msg
        return
    endif
    if !ch_canread(g:cj_lsp_client)
        return
    endif
    let g:get = ch_readraw(g:cj_lsp_client)
endfunction


function! LSP#on_exit(channel, msg) abort
    unlet g:cj_lsp_client
    let g:cj_lsp_workspace = ''
    let g:cj_lsp_id = 0
endfunction