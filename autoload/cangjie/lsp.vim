let s:NoIdMethods = ['initialized', 
                   \ 'exit', 
                   \ 'textDocument/didOpen',
                   \ 'textDocument/didChange']

let g:cj_lsp_workspace = ''
let g:cj_lsp_id = 0

let g:cj_file_version = {}
let g:cj_chat_response = {}

let g:cj_lsp_cache_dir = []

let g:cj_lsp_buffer = ''

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
    call ch_sendraw(g:cj_lsp_client, s:raw)
endfunction


function! cangjie#lsp#available() abort
    if v:version < 820 || !has('job') || !executable('LSPServer')
        return v:false
    endif
    return v:true
endfunction


function! cangjie#lsp#did_open() abort
    let s:file = 'file://' . expand('%:p')
    if g:cj_lsp_cache_dir == []
        let g:cj_lsp_cache_dir = [expand('%:p:h').'/.cache']
    else
        call add(g:cj_lsp_cache_dir, expand('%:p:h').'/.cache')
    endif
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


function! cangjie#lsp#status() abort
    if !exists('g:cj_lsp_client')
        return 'dead'
    endif
    return job_status(g:cj_lsp_client)
endfunction

function! cangjie#lsp#start_server() abort
    " Check if the client is already running
    if exists('g:cj_lsp_client')
        return
    endif

    let g:cj_lsp_workspace = expand('%:p:h')

    let s:log_dir = $HOME . '/.cache/cangjie/'
    if !isdirectory(s:log_dir)
        call mkdir(s:log_dir, 'p')
    endif

    " Start the client
    let s:cmd = ['LSPServer', '--enable-log=false']
    let s:opts = {}
    let s:opts['cwd']     = s:log_dir
    let s:opts['in_io']   = 'pipe'
    let s:opts['out_io']  = 'pipe'
    let s:opts['err_io']  = 'pipe'
    let s:opts['out_cb']  = function('s:lsp_callback')
    let s:opts['exit_cb'] = function('cangjie#lsp#on_exit')
    let s:opts['out_mode'] = 'raw'
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
endfunction

function! cangjie#lsp#check() abort
    " Check if the type is cangjie
    if &filetype != 'cangjie'
        echoerr 'Not a cangjie file.'
        return
    endif
    " just post the didChange message
    call cangjie#lsp#change_document()
endfunction


function! cangjie#lsp#add_workspace(workspace) abort
    if g:cj_lsp_workspace == a:workspace
        return
    endif
    let s:old_workspace = g:cj_lsp_workspace
    let g:cj_lsp_workspace = a:workspace
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


function! cangjie#lsp#jump_to_definition() abort
    call cangjie#lsp#change_document()
    call s:ch_send('textDocument/definition',
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


function! cangjie#lsp#change_document() abort
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


function! cangjie#lsp#complete() abort
    call cangjie#lsp#change_document()
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


function! cangjie#lsp#stop_server() abort
    if exists('g:cj_lsp_client')
        call job_stop(g:cj_lsp_client)
    endif
endfunction


function! s:lsp_callback(channel, msg) abort
    if empty(a:msg)
        return
    endif
    let g:cj_lsp_buffer .= a:msg
    " Get the length of the header
    let s:length_str = matchstr(g:cj_lsp_buffer, '\zs\d\+\r\n\r\n')[:-4]
    let s:length = str2nr(s:length_str)
    let s:response_text = split(g:cj_lsp_buffer, "\r\n\r\n")[1]
    if  len(s:response_text) < s:length
        " Not enough data, wait for more
        return
    else
        " Remove the processed part
        let g:cj_lsp_buffer = s:response_text[s:length:]
        let s:response_text = s:response_text[:s:length - 1]
    endif
    if exists('g:cj_lsp_debug') && g:cj_lsp_debug
        call writefile([s:response_text], $HOME . '/.cache/cangjie/lsp.log', 'a')
    endif
    let s:response_json = json_decode(s:response_text)
    if has_key(s:response_json, 'id')
        let s:method = g:cj_chat_response[s:response_json.id]
        if s:method == 'textDocument/completion'
            call s:complete_callback(s:response_json.result)
        elseif s:method == 'textDocument/definition'
            call s:jump_to_definition_callback(s:response_json.result)
        else
            echom 'LSP response for method ' . s:method . ' is not handled.'
        endif
        call remove(g:cj_chat_response, s:response_json.id)
    elseif has_key(s:response_json, 'method')
        let s:method = s:response_json.method
        if s:method == 'textDocument/publishDiagnostics'
            call s:diagnostics_callback(s:response_json.params)
        else
            echom 'LSP notification for method ' . s:method . ' is not handled.'
        endif
    endif
endfunction

function! cangjie#lsp#on_exit(channel, msg) abort
    if exists('g:cj_lsp_client')
        unlet g:cj_lsp_client
    endif

    let g:cj_lsp_workspace = ''
    let g:cj_lsp_id = 0
    let g:cj_file_version = {}
    let g:cj_chat_response = {}

    for s:dir in g:cj_lsp_cache_dir
        if isdirectory(s:dir)
            if isdirectory(s:dir . '/astdata')
                call delete(s:dir . '/astdata', 'rf')
            endif
            if isdirectory(s:dir . '/index')
                call delete(s:dir . '/index', 'rf')
            endif
            if len(glob(s:dir . '/*')) == 0
                call delete(s:dir, 'rf')
            endif
        endif
    endfor
endfunction