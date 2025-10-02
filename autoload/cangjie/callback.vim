function! cangjie#callback#initialize(result) abort
    echom 'Cangjie LSP Server initialized.'
endfunction


function! cangjie#callback#completion(result) abort
    if empty(a:result)
        return
    endif
    let s:complete_content = []
    for s:item in a:result
        let s:word = s:item.insertText
        if s:item.insertTextFormat == 1 && index(s:complete_content, s:word) == -1
            call add(s:complete_content, s:word)
        endif
    endfor
    call complete(col('.'), s:complete_content)
endfunction


function! cangjie#callback#definition(result) abort
    if empty(a:result) || !has_key(a:result, 'range') || !has_key(a:result.range,'start')
        return
    endif
    let s:start = a:result.range.start
    let s:lin = s:start.line + 1
    let s:col = s:start.character + 1
    normal! m'
    if mode() == 'i'
        stopinsert
        call cursor(s:lin, s:col)
        startinsert
    else
        call cursor(s:lin, s:col)
    endif
endfunction


function! cangjie#callback#references(result) abort
    if empty(a:result)
        return
    endif
    let s:ref_list = []
    for s:item in a:result
        let s:path = cangjie#util#uri_to_path(s:item.uri)
        if bufadd(s:path) < 0
            continue
        endif
        let s:str_line = getbufline(s:path, s:item.range.start.line + 1)
        if empty(s:str_line)
            if g:CJ_lsp_refer_current_file
                continue
            endif
            let s:str_line = ['']
        endif
        let s:ref_item = {
            \ 'filename': s:path,
            \ 'lnum': s:item.range.start.line + 1,
            \ 'col': s:item.range.start.character + 1,
            \ 'text': s:str_line[0]
            \ }
        call add(s:ref_list, s:ref_item)
    endfor
    call setqflist(s:ref_list, 'r')
    if g:CJ_lsp_refer_open_qflist
        copen
    endif
endfunction


function! cangjie#callback#publishDiagnostics(result) abort
    if !exists('g:cj_diagnostics_by_buf')
        let g:cj_diagnostics_by_buf = {}
    endif
    if !has_key(a:result, 'diagnostics')
        return
    endif
    let s:bufnum = bufnr('%')
    if has_key(g:cj_diagnostics_by_buf, s:bufnum)
        for s:old_diag in g:cj_diagnostics_by_buf[s:bufnum]
            if has_key(s:old_diag, 'match_id')
                call matchdelete(s:old_diag.match_id)
            endif
        endfor
    endif

    let g:cj_diagnostics_by_buf[s:bufnum] = []
    let s:diagnostics = a:result.diagnostics
    let s:loclist_items = []

    for diag in s:diagnostics
        let s:groups = ['', 'CJ_Error', 'CJ_Warning', '', 'CJ_Hint']
        let s:group = get(s:groups, diag.severity, 'CJ_Error')
        let s:win_id = win_getid()
        let s:oid = cangjie#util#highlight(s:group,
            \ diag.range['start'].line, diag.range['start'].character,
            \ diag.range['end'].line, diag.range['end'].character)
        if s:oid == -1
            continue
        endif
        let s:diag_entry = {
            \ 'message': diag.message,
            \ 'range': diag.range,
            \ 'severity': diag.severity,
            \ 'match_id': s:oid,
            \ 'win_id': s:win_id,
            \ }
        call add(g:cj_diagnostics_by_buf[s:bufnum], s:diag_entry)
        let s:types = ['E', 'E', 'W', 'I', 'I']
        let s:loclist_item = {
            \ 'bufnr': s:bufnum,
            \ 'lnum': diag.range.start.line + 1,
            \ 'col': diag.range.start.character + 1,
            \ 'text': diag.message,
            \ 'type': get(s:types, diag.severity, 'E'),
            \ }
        call add(s:loclist_items, s:loclist_item)
    endfor
    if !empty(s:loclist_items)
        call setloclist(0, s:loclist_items, 'r')
        if g:CJ_lsp_auto_open_loclist
            lopen
        endif
    else
        call setloclist(0, [], 'r')
    endif
endfunction


function! cangjie#callback#hover(result) abort
    if empty(a:result) || !has_key(a:result, 'contents') || !has_key(a:result.contents, 'value')
        return
    endif
    let l:msg = a:result.contents.value
    call cangjie#util#popup(l:msg)
endfunction


function! cangjie#callback#signatureHelp(result) abort
    if empty(a:result) || empty(a:result.signatures)
        return
    endif

    let s:total_sigs = len(a:result.signatures)
    let s:active_sig_index = get(a:result, 'activeSignature', 0)
    let s:active_signature = a:result.signatures[s:active_sig_index]
    let s:signature_label = s:active_signature.label

    let s:display_lines = []
    call add(s:display_lines, s:signature_label)
    if s:total_sigs > 1
        call add(s:display_lines, printf("(%d/%d)", s:active_sig_index + 1, s:total_sigs))
    endif

    call cangjie#util#popup(join(s:display_lines, "\n"))
endfunction


function! cangjie#callback#rename(result) abort
    if empty(a:result) || !has_key(a:result, 'documentChanges') || empty(a:result.documentChanges)
        return
    endif

    let s:all_edits_by_uri = {}
    let s:total_edits = 0
    for s:doc_edit in a:result.documentChanges
        let s:uri = s:doc_edit.textDocument.uri
        let s:edits = s:doc_edit.edits
        let s:all_edits_by_uri[s:uri] = s:edits
        let s:total_edits += len(s:edits)
    endfor
    let s:file_count = len(keys(s:all_edits_by_uri))

    for [s:uri, s:edits] in items(s:all_edits_by_uri)
        let s:path = cangjie#util#uri_to_path(s:uri)
        let s:bufnr = bufnr(s:path)

        if s:bufnr > 0 && bufloaded(s:bufnr)
            let s:lines = getbufline(s:bufnr, 1, '$')
            for s:edit in reverse(s:edits)
                let s:start_line = s:edit.range.start.line
                let s:start_byte = byteidx(s:lines[s:start_line], s:edit.range.start.character)
                let s:end_byte = byteidx(s:lines[s:edit.range.start.line], s:edit.range.end.character)
                let s:line_content = s:lines[s:start_line]
                let s:lines[s:start_line] = s:line_content[:s:start_byte-1] . s:edit.newText . s:line_content[s:end_byte:]
            endfor
            call setbufline(s:bufnr, 1, s:lines)
        else
            if !filereadable(s:path) | continue | endif " 安全檢查
            let s:lines = readfile(s:path)
            for s:edit in reverse(s:edits)
                let s:start_line = s:edit.range.start.line
                let s:start_byte = byteidx(s:lines[s:start_line], s:edit.range.start.character)
                let s:end_byte = byteidx(s:lines[s:edit.range.start.line], s:edit.range.end.character)
                let s:line_content = s:lines[s:start_line]
                let s:lines[s:start_line] = s:line_content[:s:start_byte-1] . s:edit.newText . s:line_content[s:end_byte:]
            endfor
            call writefile(s:lines, s:path)
        endif
    endfor
endfunction


function! cangjie#callback#noResponse(result) abort
endfunction
