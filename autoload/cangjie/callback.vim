function! cangjie#callback#completion(result) abort
    if !a:result || empty(a:result)
        return
    endif
    let s:complete_content = []
    for s:item in a:result
        let s:word = s:item.insertText
        if s:item.detail == '' && index(s:complete_content, s:word) == -1
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
        if s:oid > 0
            call add(g:cj_lsp_diagnostics, s:oid)
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