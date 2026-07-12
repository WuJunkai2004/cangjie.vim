let s:NoIdMethods = ['initialized', 
                   \ 'exit', 
                   \ 'textDocument/didOpen',
                   \ 'textDocument/didChange',
                   \ 'textDocument/didSave',
                   \]

let s:CallbackFuns = {
    \ 'initialize': function('cangjie#callback#initialize'),
    \ 'textDocument/completion': function('cangjie#callback#completion'),
    \ 'textDocument/definition': function('cangjie#callback#definition'),
    \ 'textDocument/publishDiagnostics': function('cangjie#callback#publishDiagnostics'),
    \ 'textDocument/hover': function('cangjie#callback#hover'),
    \ 'textDocument/signatureHelp': function('cangjie#callback#signatureHelp'),
    \ 'textDocument/references': function('cangjie#callback#references'),
    \ 'textDocument/semanticTokens/full': function('cangjie#callback#noResponse'),
    \ 'textDocument/rename': function('cangjie#callback#rename'),
\}

let g:cj_lsp_workspace = ''
let g:cj_lsp_id = 0

let g:cj_file_version = {}
let g:cj_chat_response = {}

let g:cj_lsp_cache_dir = []

let g:cj_lsp_buffer = ''

function! s:ch_send(method, params) abort
    let l:req = {}
    let l:req.method = a:method
    let l:req.jsonrpc = '2.0'
    let l:req.params = a:params
    if(index(s:NoIdMethods, a:method) == -1)
        let g:cj_lsp_id = g:cj_lsp_id + 1
        let l:req.id = g:cj_lsp_id
        let g:cj_chat_response[l:req.id] = a:method
    endif
    let l:json_req = json_encode(l:req)
    if exists('g:CJ_lsp_debug') && g:CJ_lsp_debug
        call writefile(["==> Server", l:json_req], $HOME . '/.cache/cangjie/lsp.log', 'a')
    endif
    let l:header = 'Content-Length: ' . len(l:json_req) . "\r\n\r\n"
    let l:raw = l:header . l:json_req
    call ch_sendraw(g:cj_lsp_client, l:raw)
endfunction


function! cangjie#lsp#available() abort
    if v:version < 820 || !has('job') || !executable('LSPServer')
        return v:false
    endif
    return v:true
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

    let l:log_dir = $HOME . '/.cache/cangjie/'
    if !isdirectory(l:log_dir)
        call mkdir(l:log_dir, 'p')
    endif

    " Start the client
    if exists('g:CJ_lsp_cmd')
        let l:cmd = g:CJ_lsp_cmd
        " If g:CJ_lsp_cmd is a string, split it into a list
        if type(l:cmd) == type('')
            let l:cmd = split(l:cmd)
        endif
        if type(l:cmd) != type([]) || empty(l:cmd)
            echoerr 'g:CJ_lsp_cmd must be a non-empty String or List'
            echoerr 'fallback to default command: LSPServer --enable-log=false'
            let l:cmd = ['LSPServer', '--enable-log=false']
        endif
    else
        let l:cmd = ['LSPServer', '--enable-log=false']
    endif
    let l:opts = {}
    let l:opts['cwd']     = l:log_dir
    let l:opts['in_io']   = 'pipe'
    let l:opts['out_io']  = 'pipe'
    let l:opts['err_io']  = 'pipe'
    let l:opts['out_cb']  = function('s:lsp_callback')
    let l:opts['exit_cb'] = function('cangjie#lsp#on_exit')
    let l:opts['out_mode'] = 'raw'
    let g:cj_lsp_client = job_start(l:cmd, l:opts)

    " Post the initialize and initialized messages
    let l:init_params = {
                \  'processId': getpid(),
                \  'rootUri': 'file://' . expand(g:cj_lsp_workspace),
                \  'capabilities': {
                \    'workspace': {
                \      'symbol': {}
                \    },
                \    'textDocument': {
                \      'synchronization': {
                \        'didSave': v:true
                \      },
                \      'completion': {
                \        'completionItem': {
                \          'documentationFormat': ['plaintext']
                \        }
                \      },
                \      'definition': {},
                \      'references': {},
                \      'documentSymbol': {},
                \      'formatting': {},
                \      'rename': {},
                \      'hover': {
                \        'contentFormat': ['plaintext']
                \      },
                \      'signatureHelp': {
                \        'signatureInformation': {
                \          'documentationFormat': ['plaintext']
                \        }
                \      }
                \    }
                \  }
                \}
    call s:ch_send('initialize', l:init_params)
    call s:ch_send('initialized', {})
endfunction


function! cangjie#lsp#stop_server() abort
    if exists('g:cj_lsp_client')
        call job_stop(g:cj_lsp_client)
    endif
endfunction


function! cangjie#lsp#didOpen() abort
    let l:file = 'file://' . expand('%:p')
    call add(g:cj_lsp_cache_dir, expand('%:p:h').'/.cache')
    if !has_key(g:cj_file_version, l:file)
        let g:cj_file_version[l:file] = 1
    else
        return
    endif
    call s:ch_send('textDocument/didOpen',
                \ {
                \   'textDocument': {
                \     'uri': l:file,
                \     'languageId': 'Cangjie',
                \     'version': g:cj_file_version[l:file],
                \     'text': join(getline(1, '$'), "\n")
                \   }
                \ })
endfunction


function! cangjie#lsp#didChange() abort
    let l:file = 'file://' . expand('%:p')
    if !has_key(g:cj_file_version, l:file)
        let g:cj_file_version[l:file] = 1
    else
        let g:cj_file_version[l:file] = g:cj_file_version[l:file] + 1
    endif
    call s:ch_send('textDocument/didChange',
                \ {
                \   'textDocument': {
                \     'uri': l:file,
                \     'version': g:cj_file_version[l:file]
                \   },
                \   'contentChanges': [{
                \     'text': join(getline(1, '$'), "\n")
                \   }]
                \ })
endfunction


function! cangjie#lsp#didSave() abort
    let l:file = 'file://' . expand('%:p')
    call s:ch_send('textDocument/didSave',
                \ {
                \   'textDocument': {
                \     'uri': l:file
                \   },
                \   'text': join(getline(1, '$'), "\n")
                \ })
endfunction


function! cangjie#lsp#definition() abort
    call cangjie#lsp#didChange()
    call s:ch_send('textDocument/definition',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   },
                \   'position': {
                \     'line': line('.') - 1,
                \     'character': virtcol('.') - 1,
                \   }
                \ })
endfunction


function! cangjie#lsp#references() abort
    call cangjie#lsp#didChange()
    call s:ch_send('textDocument/references',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   },
                \   'position': {
                \     'line': line('.') - 1,
                \     'character': virtcol('.') - 1,
                \   },
                \   'context': {
                \     'includeDeclaration': v:false
                \   }
                \ })
endfunction


function! cangjie#lsp#completion(trigger_kind) abort
    call cangjie#lsp#didChange()
    call s:ch_send('textDocument/completion',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   },
                \   'context': {
                \     'triggerKind': a:trigger_kind
                \   },
                \   'position': {
                \     'line': line('.') - 1,
                \     'character': virtcol('.') - 1,
                \   }
                \ })
endfunction

function! cangjie#lsp#omnifunc(findstart, base) abort
    if a:findstart
        return col('.') - 1
    else
        call cangjie#lsp#completion(1)
        return ['Loading...']
    endif
endfunction


function! cangjie#lsp#hover() abort
    call cangjie#lsp#didChange()
    call s:ch_send('textDocument/hover',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   },
                \   'position': {
                \     'line': line('.') - 1,
                \     'character': virtcol('.') - 1,
                \   }
                \ })
endfunction


function! cangjie#lsp#signatureHelp(char) abort
    call cangjie#lsp#didChange()
    call s:ch_send('textDocument/signatureHelp',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   },
                \   'position': {
                \     'line': line('.') - 1,
                \     'character': virtcol('.') - 1,
                \   },
                \   'context': {
                \     'triggerCharacter': a:char,
                \     'isRetrigger': v:true,
                \     'triggerKind': 1,
                \   }
                \ })
endfunction


function! cangjie#lsp#semanticTokens_full() abort
    call cangjie#lsp#didChange()
    call s:ch_send('textDocument/semanticTokens/full',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   }
                \ })
endfunction


function! cangjie#lsp#rename(new_name) abort
    call cangjie#lsp#didChange()
    call s:ch_send('textDocument/rename',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   },
                \   'position': {
                \     'line': line('.') - 1,
                \     'character': virtcol('.') - 1,
                \   },
                \   'newName': a:new_name
                \ })
endfunction


function! s:lsp_callback(channel, msg) abort
    if empty(a:msg)
        return
    endif
    let g:cj_lsp_buffer .= a:msg
    " Get the length of the header
    let l:length_str = matchstr(g:cj_lsp_buffer, '\zs\d\+\r\n\r\n')[:-4]
    let l:length = str2nr(l:length_str)
    let l:response_text = split(g:cj_lsp_buffer, "\r\n\r\n")[1]
    if  len(l:response_text) < l:length
        " Not enough data, wait for more
        return
    else
        " Remove the processed part
        let g:cj_lsp_buffer = l:response_text[l:length:]
        let l:response_text = l:response_text[:l:length - 1]
    endif
    let l:response_json = json_decode(l:response_text)
    if has_key(l:response_json, 'id')
        let l:method = g:cj_chat_response[l:response_json.id]
        let l:params = l:response_json.result
        call remove(g:cj_chat_response, l:response_json.id)
    elseif has_key(l:response_json, 'method')
        let l:method = l:response_json.method
        let l:params = l:response_json.params
    endif
    if exists('g:cj_lsp_debug') && g:cj_lsp_debug
        call writefile([l:method, "  " . l:response_text], $HOME . '/.cache/cangjie/lsp.log', 'a')
    endif
    if has_key(s:CallbackFuns, l:method)
        call s:CallbackFuns[l:method](l:params)
    else
        echoerr 'LSP response for method ' . l:method . ' is not handled.'
        echoerr 'response => ' . l:response_text
    endif
endfunction

function! cangjie#lsp#on_exit(channel, msg) abort
    if exists('g:cj_lsp_client')
        unlet g:cj_lsp_client
    endif

    for l:dir in g:cj_lsp_cache_dir
        if isdirectory(l:dir)
            if isdirectory(l:dir . '/astdata')
                call delete(l:dir . '/astdata', 'rf')
            endif
            if isdirectory(l:dir . '/index')
                call delete(l:dir . '/index', 'rf')
            endif
            if len(glob(l:dir . '/*')) == 0
                call delete(l:dir, 'rf')
            endif
        endif
    endfor

    let g:cj_lsp_workspace = ''
    let g:cj_lsp_id = 0
    let g:cj_lsp_cache_dir = []
    let g:cj_file_version = {}
    let g:cj_chat_response = {}
endfunction
