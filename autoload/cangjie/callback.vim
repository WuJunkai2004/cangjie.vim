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
        stopinsert
        call cursor(s:lin, s:col)
        startinsert
    else
        call cursor(s:lin, s:col)
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
    endfor
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
