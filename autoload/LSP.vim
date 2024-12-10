let s:NoIdMethods = ['initialized', 
                   \ 'exit', 
                   \ 'textDocument/didOpen',
                   \ 'textDocument/didChange']

let s:MethodInterval = {
  \ 'initialize': 10,
  \ 'initialized': 1,
  \ 'textDocument/didOpen': 1,
  \ 'textDocument/didChange': 0,
\}

let s:MethodPostQueue = []
let s:MethodPostAwait = 0

let g:cj_lsp_mainloop_id = v:null

let g:cj_lsp_workspace = ''
let g:cj_lsp_id = 0

let g:cj_lsp_history = ''

let g:cj_file_version = {}
let g:cj_chat_response = {}

let g:cj_lsp_log_path = ''

function! LSP#mainloop() abort
    if len(s:MethodPostQueue) == 0
        let s:MethodPostAwait = 0
        return
    endif
    if s:MethodPostAwait != 0
        let s:MethodPostAwait = s:MethodPostAwait - 1
        return
    endif
    let s:post = remove(s:MethodPostQueue, 0)
    call ch_sendraw(g:cj_lsp_client, s:post.raw)
    let s:MethodPostAwait = s:post.interval
endfunction


function! s:ch_send(method, params) abort
    let s:req = {}
    let s:req.method = a:method
    let s:req.jsonrpc = '2.0'
    let s:req.params = a:params
    if(index(s:NoIdMethods, a:method) == -1)
        let g:cj_lsp_id = g:cj_lsp_id + 1
        let s:req.id = g:cj_lsp_id
        let g:cj_chat_response[s:req.id] = a:method
    endif
    let s:json_req = json_encode(s:req)
    let s:header = 'Content-Length: ' . len(s:json_req) . "\r\n\r\n"
    let s:raw = s:header . s:json_req
    " find the interval for the method
    let s:interval = get(s:MethodInterval, a:method, 3)
    " add to the queue
    call add(s:MethodPostQueue, {'raw': s:raw, 'interval': s:interval})
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

    " 在vim的运行目录下创建一个log.txt文件
    let g:cj_lsp_log_path = getcwd() . '/log.txt'

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
    
    " Post the initialize and initialized messages
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
    call s:ch_send('initialized', {})

    " Start the main loop
    let g:cj_lsp_mainloop_id = timer_start(500, { -> LSP#mainloop()}, {'repeat': -1})
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
    let s:response_text = ch_readraw(g:cj_lsp_client)
    let s:response_json = json_decode(s:response_text)
    if has_key(s:response_json, 'id')
        let s:method = g:cj_chat_response[s:response_json.id]
        if s:method == 'textDocument/completion'
            call s:complete_callback(s:response_json.result)
        endif
        call remove(g:cj_chat_response, s:response_json.id)
    endif
endfunction

function s:complete_callback(result) abort
    let s:complete_content = []
    for s:item in a:result
        let s:word = s:item.filterText
        if index(s:complete_content, s:word) == -1
            call add(s:complete_content, s:word)
        endif
    endfor
    call complete(col('.'), s:complete_content)
endfunction


function! LSP#on_exit(channel, msg) abort
    if exists('g:cj_lsp_client')
        unlet g:cj_lsp_client
    endif

    let g:cj_lsp_workspace = ''
    let g:cj_lsp_id = 0
    let g:cj_file_version = {}
    let g:cj_chat_response = {}

    if g:cj_lsp_mainloop_id != v:null
        call timer_stop(g:cj_lsp_mainloop_id)
        let g:cj_lsp_mainloop_id = v:null
    endif

    if !empty(g:cj_lsp_log_path)
        call delete(g:cj_lsp_log_path)
    endif
endfunction
