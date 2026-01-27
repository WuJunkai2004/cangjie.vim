function! cangjie#callback#initialize(result) abort
    echom 'Cangjie LSP Server initialized.'
endfunction


function! cangjie#callback#completion(result) abort
    if empty(a:result)
        return
    endif
    let l:line_str = getline('.')
    let l:col = col('.')
    let l:start = l:col
    while l:start > 1 && l:line_str[l:start - 2] =~ '\k'
        let l:start -= 1
    endwhile
    let l:prefix = l:line_str[l:start - 1 : l:col - 1]
    let l:ctx_has_front = (l:start > 1 && l:line_str[l:start - 2] == '`')
    let l:ctx_has_back  = (l:col <= len(l:line_str) && l:line_str[l:col - 1] == '`')
    let l:search_prefix = substitute(l:prefix, '`', '', 'g')
    let l:complete_content = []
    let l:complete_content_dict = {}
    for l:item in a:result
        let l:raw_word = l:item.insertText
        let l:search_word = substitute(l:raw_word, '`', '', 'g')
        if stridx(l:search_word, l:search_prefix) != 0
            continue
        endif
        let l:insert_word = l:raw_word
        if l:ctx_has_front && l:insert_word[0] == '`'
             let l:insert_word = l:insert_word[1:]
        endif
        if l:ctx_has_back && l:insert_word[len(l:insert_word)-1] == '`'
             let l:insert_word = l:insert_word[:-2]
        endif
        if l:item.insertTextFormat == 1 && !has_key(l:complete_content_dict, l:insert_word)
            call add(l:complete_content, {
            \   "word": l:insert_word,
            \   "abbr": l:item.label,
            \   'menu': get(l:item, 'detail', ''),
            \})
            let l:complete_content_dict[l:insert_word] = 1
        endif
    endfor
    call complete(l:start, l:complete_content)
endfunction


function! cangjie#callback#definition(result) abort
    if empty(a:result) || !has_key(a:result, 'range') || !has_key(a:result.range,'start')
        return
    endif
    let l:start = a:result.range.start
    let l:lin = l:start.line + 1
    let l:col = l:start.character + 1
    normal! m'
    if mode() == 'i'
        stopinsert
        call cursor(l:lin, l:col)
        startinsert
    else
        call cursor(l:lin, l:col)
    endif
endfunction


function! cangjie#callback#references(result) abort
    if empty(a:result)
        return
    endif
    let l:ref_list = []
    for l:item in a:result
        let l:path = cangjie#util#uri_to_path(l:item.uri)
        if bufadd(l:path) < 0
            continue
        endif
        let l:str_line = getbufline(l:path, l:item.range.start.line + 1)
        if empty(l:str_line)
            if g:CJ_lsp_refer_current_file
                continue
            endif
            let l:str_line = ['']
        endif
        let l:ref_item = {
            \ 'filename': l:path,
            \ 'lnum': l:item.range.start.line + 1,
            \ 'col': l:item.range.start.character + 1,
            \ 'text': l:str_line[0]
            \ }
        call add(l:ref_list, l:ref_item)
    endfor
    call setqflist(l:ref_list, 'r')
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
    let l:bufnum = bufnr('%')
    if has_key(g:cj_diagnostics_by_buf, l:bufnum)
        for l:old_diag in g:cj_diagnostics_by_buf[l:bufnum]
            if has_key(l:old_diag, 'match_id')
                call matchdelete(l:old_diag.match_id)
            endif
        endfor
    endif

    let g:cj_diagnostics_by_buf[l:bufnum] = []
    let l:diagnostics = a:result.diagnostics
    let l:loclist_items = []

    let l:groups = ['', 'CJ_Error', 'CJ_Warning', '', 'CJ_Hint']
    for l:diag in l:diagnostics
        let l:group = get(l:groups, l:diag.severity, 'CJ_Error')
        let l:win_id = win_getid()
        let l:oid = cangjie#util#highlight(l:group,
            \ l:diag.range['start'].line, l:diag.range['start'].character,
            \ l:diag.range['end'].line, l:diag.range['end'].character)
        if l:oid == -1
            continue
        endif
        let l:diag_entry = {
            \ 'message': l:diag.message,
            \ 'range': l:diag.range,
            \ 'severity': l:diag.severity,
            \ 'match_id': l:oid,
            \ 'win_id': l:win_id,
            \ }
        call add(g:cj_diagnostics_by_buf[l:bufnum], l:diag_entry)
        let l:types = ['E', 'E', 'W', 'I', 'I']
        let l:loclist_item = {
            \ 'bufnr': l:bufnum,
            \ 'lnum': l:diag.range.start.line + 1,
            \ 'col': l:diag.range.start.character + 1,
            \ 'text': l:diag.message,
            \ 'type': get(l:types, l:diag.severity, 'E'),
            \ }
        call add(l:loclist_items, l:loclist_item)
    endfor
    if !empty(l:loclist_items)
        call setloclist(0, l:loclist_items, 'r')
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

    let l:total_sigs = len(a:result.signatures)
    let l:active_sig_index = get(a:result, 'activeSignature', 0)
    let l:active_signature = a:result.signatures[l:active_sig_index]
    let l:signature_label = l:active_signature.label

    let l:display_lines = []
    call add(l:display_lines, l:signature_label)
    if l:total_sigs > 1
        call add(l:display_lines, printf("(%d/%d)", l:active_sig_index + 1, l:total_sigs))
    endif

    call cangjie#util#popup(join(l:display_lines, "\n"))
endfunction


function! cangjie#callback#rename(result) abort
    if empty(a:result) || !has_key(a:result, 'documentChanges') || empty(a:result.documentChanges)
        return
    endif

    let l:all_edits_by_uri = {}
    let l:total_edits = 0
    for l:doc_edit in a:result.documentChanges
        let l:uri = l:doc_edit.textDocument.uri
        let l:edits = l:doc_edit.edits
        let l:all_edits_by_uri[l:uri] = l:edits
        let l:total_edits += len(l:edits)
    endfor
    let l:file_count = len(keys(l:all_edits_by_uri))

    for [l:uri, l:edits] in items(l:all_edits_by_uri)
        let l:path = cangjie#util#uri_to_path(l:uri)
        let l:bufnr = bufnr(l:path)

        if l:bufnr > 0 && bufloaded(l:bufnr)
            let l:lines = getbufline(l:bufnr, 1, '$')
            for l:edit in reverse(l:edits)
                let l:start_line = l:edit.range.start.line
                let l:start_byte = byteidx(l:lines[l:start_line], l:edit.range.start.character)
                let l:end_byte = byteidx(l:lines[l:edit.range.start.line], l:edit.range.end.character)
                let l:line_content = l:lines[l:start_line]
                let l:lines[l:start_line] = l:line_content[:l:start_byte-1] . l:edit.newText . l:line_content[l:end_byte:]
            endfor
            call setbufline(l:bufnr, 1, l:lines)
        else
            if !filereadable(l:path) | continue | endif " 安全檢查
            let l:lines = readfile(l:path)
            for l:edit in reverse(l:edits)
                let l:start_line = l:edit.range.start.line
                let l:start_byte = byteidx(l:lines[l:start_line], l:edit.range.start.character)
                let l:end_byte = byteidx(l:lines[l:edit.range.start.line], l:edit.range.end.character)
                let l:line_content = l:lines[l:start_line]
                let l:lines[l:start_line] = l:line_content[:l:start_byte-1] . l:edit.newText . l:line_content[l:end_byte:]
            endfor
            call writefile(l:lines, l:path)
        endif
    endfor
endfunction


function! cangjie#callback#noResponse(result) abort
endfunction
