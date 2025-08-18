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

let g:cj_file_version = {}
let g:cj_chat_response = {}

let g:cj_lsp_cache_dir = []

let g:cj_lsp_buffer = ''

function! LSP#mainloop() abort
    if empty(s:MethodPostQueue)
        let s:MethodPostAwait = 0
        return
    endif
    if s:MethodPostAwait
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
    
    " Save work directory
    let s:work_dir = getcwd()
    " Change to the $home/.cache/cangjie/
    if !isdirectory($HOME . '/.cache/cangjie/')
        call mkdir($HOME . '/.cache/cangjie/', 'p')
    endif
    call chdir($HOME . '/.cache/cangjie/')

    " Start the client
    let s:cmd = 'LSPServer'
    let s:opts = {}
    let s:opts['in_io']   = 'pipe'
    let s:opts['out_io']  = 'pipe'
    let s:opts['err_io']  = 'pipe'
    let s:opts['out_cb']  = function('s:lsp_callback')
    let s:opts['exit_cb'] = function('LSP#on_exit')
    let s:opts['out_mode'] = 'raw'
    let g:cj_lsp_client = job_start(s:cmd, s:opts)

    " Restore work directory
    call chdir(s:work_dir)
    
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

function! LSP#check() abort
    " Check if the type is cangjie
    if &filetype != 'cangjie'
        echoerr 'Not a cangjie file.'
        return
    endif
    " just post the didChange message
    call LSP#change_document()
    " Post the textDocument/publishDiagnostics message
    call s:ch_send('textDocument/publishDiagnostics',
                \ {
                \   'textDocument': {
                \     'uri': 'file://' . expand('%:p'),
                \   },
                \   'diagnostics': [],
                \ })
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


function! LSP#jump_to_definition() abort
    call LSP#change_document()
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
    let s:response_json = json_decode(s:response_text)
    if has_key(s:response_json, 'id')
        let s:method = g:cj_chat_response[s:response_json.id]
        if s:method == 'textDocument/completion'
            call s:complete_callback(s:response_json.result)
        elseif s:method == 'textDocument/definition'
            call s:jump_to_definition_callback(s:response_json.result)
        endif
        call remove(g:cj_chat_response, s:response_json.id)
    elseif has_key(s:response_json, 'method')
        let s:method = s:response_json.method
        if s:method == 'textDocument/publishDiagnostics'
            call s:diagnostics_callback(s:response_json.params)
        endif
    endif
endfunction

function s:complete_callback(result) abort
    let s:complete_content = []
    for s:item in a:result
        let s:word = s:item.insertText
        if s:item.detail == '' && index(s:complete_content, s:word) == -1
            call add(s:complete_content, s:word)
        endif
    endfor
    call complete(col('.'), s:complete_content)
endfunction

function s:jump_to_definition_callback(result) abort
    if !has_key(a:result, 'range')
        return
    endif
    let s:range = a:result.range
    if !has_key(s:range, 'start')
        return
    endif
    let s:start = s:range.start
    let s:lin = s:start.line + 1
    let s:col = s:start.character + 1
    " check if in normal mode
    if mode() == 'i'
        execute 'normal! \<Esc>'
        call cursor(s:lin, s:col)
        execute 'startinsert'
    else
        call cursor(s:lin, s:col)
    endif
endfunction

function s:diagnostics_callback(result) abort
    if !has_key(a:result, 'diagnostics')
        return
    endif
    let s:diagnostics = a:result.diagnostics
    
    if !exists('g:cj_lsp_diagnostics')
        let g:cj_lsp_diagnostics = []
    else
        for ids in g:cj_lsp_diagnostics
            call matchdelete(ids)
        endfor
        let g:cj_lsp_diagnostics = []
    endif

    for diag in s:diagnostics
        let s:groups = ['', 'CJ_Error', 'CJ_Warning', '', 'CJ_Hint']
        let s:group = get(s:groups, diag.severity, 'CJ_Error')
        let s:oid = s:highlight(s:group,
            \ diag.range['start'].line, diag.range['start'].character,
            \ diag.range['end'].line, diag.range['end'].character)
    endfor
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


" util functions
function! s:highlight(group, start_line, start_char, end_line, end_char) abort
    let positions = []
    
    " 循环处理每一行，从起始行到结束行
    for the_line in range(a:start_line, a:end_line)
        let vim_lnum = the_line + 1 " LSP 行号转 Vim 行号
        let line_text = getline(vim_lnum)

        let current_start_char = (the_line == a:start_line) ? a:start_char : 0
        let current_end_char = (the_line == a:end_line) ? a:end_char + 1 : strchars(line_text)

        if current_start_char >= strchars(line_text) || current_start_char >= current_end_char
            continue
        endif

        " 将字符列转换为字节列
        let start_byte_col = byteidx(line_text, current_start_char) + 1
        let end_byte_col = byteidx(line_text, current_end_char)

        if start_byte_col < 0 || end_byte_col < 0
            continue
        endif
        
        let byte_len = end_byte_col - (start_byte_col - 1)
        if byte_len > 0
            call add(positions, [vim_lnum, start_byte_col, byte_len])
        endif
    endfor

    " 如果有有效的位置，就调用 matchaddpos
    if !empty(positions)
        return matchaddpos(a:group, positions)
    else
        return -1
    endif
endfunction
