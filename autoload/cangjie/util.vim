function! cangjie#util#cmd(option) abort
    if a:option == 'start'
        call cangjie#util#start_lsp()
    elseif a:option == 'kill'
        call cangjie#lsp#stop_server()
    elseif a:option == 'status'
        echo cangjie#lsp#status()
    elseif a:option == 'check'
        call cangjie#lsp#semanticTokens_full()
    elseif a:option =~# '^rename\s'
        let l:opts = split(a:option)
        if len(l:opts) != 2
            echoerr 'Invalid option: '. a:option
        endif
        call cangjie#lsp#rename(l:opts[1])
    else
        echoerr 'Unknown option: ' . a:option
    endif
endfunction


function! cangjie#util#indent() abort
    " 获取当前行号
    let lnum = v:lnum
    if lnum == 1
        return 0
    endif

    let prev_lnum = prevnonblank(lnum - 1)
    if prev_lnum == 0
        return 0
    endif
    let indent = indent(prev_lnum)
    let prev_line = getline(prev_lnum)

    " 规则1: 如果上一行以 '{' 或 '(' 结尾，则增加缩进
    if prev_line =~# '[({]\s*$'
        let indent += &shiftwidth
    endif

    " 规则2: 如果当前行以 '}' 或 ')' 开头，则减少缩进
    let current_line = getline(lnum)
    if current_line =~# '^\s*[})]'
        let indent -= &shiftwidth
    endif

    " 确保缩进不会小于0
    if indent < 0
        let indent = 0
    endif
    return indent
endfunction


function! cangjie#util#start_lsp() abort
    if cangjie#lsp#status() == 'dead'
        call cangjie#lsp#start_server()
    endif
endfunction


function! cangjie#util#setup_for_buffer() abort
    nnoremap <buffer><silent> K :call cangjie#lsp#hover()<CR>
    nnoremap <buffer><silent> gd :call cangjie#lsp#definition()<CR>
    nnoremap <buffer><silent> gr :call cangjie#lsp#references()<CR>
    nnoremap <buffer><silent> <C-T> <C-O>

    augroup cangjie_lsp_cmd
        autocmd!
        autocmd InsertCharPre <buffer> call cangjie#util#trigger_shortkey()
        autocmd BufWritePre <buffer> call cangjie#util#auto_format()
        autocmd BufWritePost <buffer> call cangjie#lsp#didSave()
    augroup END

    call cangjie#util#open()
endfunction

function! cangjie#util#auto_format() abort
    if !exists('g:CJ_lsp_auto_format_on_save') || g:CJ_lsp_auto_format_on_save == 0
        return
    endif
    if empty(&l:equalprg)
        return
    endif
    silent! undojoin | normal! gg=G
endfunction

function! cangjie#util#open() abort
    if cangjie#lsp#status() == 'dead'
        call cangjie#lsp#start_server()
        call timer_start(1000, {-> cangjie#util#open()})
        return
    endif
    call cangjie#lsp#didOpen()
endfunction


function! cangjie#util#trigger_shortkey() abort
    let l:char = v:char
    if l:char == '.' || l:char == '`'
        call timer_start(0, { -> cangjie#lsp#completion(2) })
    elseif l:char == '(' || l:char == ','
        call timer_start(0, { -> cangjie#lsp#signatureHelp(l:char) })
    endif

    call cangjie#util#auto_diag()
endfunction


function! cangjie#util#auto_diag() abort
    if !exists('g:CJ_lsp_auto_check') || g:CJ_lsp_auto_check == 0
        return
    endif
    if exists('g:cj_delay_diagnostics_timer')
        call timer_stop(g:cj_delay_diagnostics_timer)
    endif
    let g:cj_delay_diagnostics_timer = timer_start(5000, {-> cangjie#lsp#semanticTokens_full()})
endfunction


function! cangjie#util#hover() abort
    if !exists('g:cj_diagnostics_by_buf')
        let g:cj_diagnostics_by_buf = {}
    endif
    let l:bufnum = bufnr('%')
    if !has_key(g:cj_diagnostics_by_buf, l:bufnum) || empty(g:cj_diagnostics_by_buf[l:bufnum])
        return ''
    endif

    let l:line_text = getline(v:beval_lnum)

    let l:found_messages = []
    for l:diag in g:cj_diagnostics_by_buf[l:bufnum]
        let l:start = l:diag.range.start
        let l:end = l:diag.range.end

        " check if the current line is within the diagnostic range
        if (v:beval_lnum - 1) >= l:start.line && (v:beval_lnum - 1) <= l:end.line
            let l:start_char = ((v:beval_lnum - 1) == l:start.line) ? l:start.character : 0
            let l:end_char = ((v:beval_lnum - 1) == l:end.line) ? l:end.character : strchars(l:line_text)

            " 将LSP的 0-based 字符列 转换为 Vim 的 1-based 字节列
            let l:start_byte_col = byteidx(l:line_text, l:start_char) + 1
            " LSP 的 end 是 exclusive (不包含), byteidx 正好需要这个值来获取结束位置
            let l:end_byte_col = byteidx(l:line_text, l:end_char) + 1

            " 如果结束位置超出本行，byteidx 返回 -1，我们将其修正到行尾
            if l:end_byte_col <= 0
                let l:end_byte_col = len(l:line_text) + 2
            endif

            " 判断悬停的字节列是否在诊断的字节范围内 [start, end)
            if v:beval_col >= l:start_byte_col && v:beval_col <= l:end_byte_col
                call add(l:found_messages, l:diag.message)
            endif
        endif
    endfor

    return join(l:found_messages, "\n")
endfunction


function! cangjie#util#popup(text) abort
    if empty(a:text)
        return
    endif
    let l:lines = split(a:text, "\n", 1)
    let l:max_width = max(map(copy(l:lines), 'strwidth(v:val)'))
    let l:opts = {
                \ 'line': 'cursor+1',
                \ 'col': 'cursor',
                \ 'minwidth': l:max_width,
                \ 'padding': [1, 1, 1, 1],
                \ 'border':  [0, 0, 0, 0],
                \ 'zindex': 200,
                \ 'wrap': 0,
                \ 'moved': 'WORD',
                \ 'close': 'click',
                \ }
    let l:popup_id = popup_create(l:lines, l:opts)
    return l:popup_id
endfunction


function! cangjie#util#highlight(group, start_line, start_char, end_line, end_char) abort
    let positions = []

    for the_line in range(a:start_line, a:end_line)
        let vim_lnum = the_line + 1
        let line_text = getline(vim_lnum)

        let current_start_char = (the_line == a:start_line) ? a:start_char : 0

        " 我们需要将结束位置视为 end + 1 (即不包含的位置)，以便计算长度。
        let current_end_char = (the_line == a:end_line) ? a:end_char + 1 : strchars(line_text)

        if current_start_char >= strchars(line_text) || current_start_char >= current_end_char
            continue
        endif

        " 将字符列转换为字节列
        let start_byte_index = byteidx(line_text, current_start_char)
        let end_byte_index = byteidx(line_text, current_end_char)

        if start_byte_index < 0
            continue
        endif
        if end_byte_index < 0
            let end_byte_index = len(line_text)
        endif

        let start_byte_col = start_byte_index + 1
        let byte_len = end_byte_index - start_byte_index

        if byte_len > 0
            call add(positions, [vim_lnum, start_byte_col, byte_len])
        endif
    endfor

    if !empty(positions)
        return matchaddpos(a:group, positions)
    else
        return -1
    endif
endfunction


function cangjie#util#clear_highlight(bufnum) abort
    if !exists('g:cj_diagnostics_by_buf') || !has_key(g:cj_diagnostics_by_buf, a:bufnum)
        return
    endif
    
    for diag in g:cj_diagnostics_by_buf[a:bufnum]
        if has_key(diag, 'match_id') && diag.match_id > 0 && has_key(diag, 'win_id')
            call matchdelete(diag.match_id, diag.win_id)
        endif
        silent! unlet diag.match_id
        silent! unlet diag.win_id
    endfor
endfunction


function! cangjie#util#redraw_highlight() abort
    let l:bufnum = bufnr('%')
    if !exists('g:cj_diagnostics_by_buf') || !has_key(g:cj_diagnostics_by_buf, l:bufnum)
        return
    endif

    let l:groups = ['', 'CJ_Error', 'CJ_Warning', '', 'CJ_Hint']
    for diag in g:cj_diagnostics_by_buf[l:bufnum]
        if has_key(diag, 'match_id')
            continue
        endif
        let l:group = get(l:groups, diag.severity, 'CJ_Error')
        let l:win_id = win_getid()
        let l:oid = cangjie#util#highlight(l:group,
            \ diag.range['start'].line, diag.range['start'].character,
            \ diag.range['end'].line, diag.range['end'].character)
        let diag.match_id = l:oid
        let diag.win_id = l:win_id
    endfor
endfunction


function! cangjie#util#uri_to_path(uri) abort
    let l:path = a:uri
    if l:path =~# '^file://'
        let l:path = l:path[7:]
        if has('win32') && l:path =~# '/\a:'
            let l:path = l:path[1:]
        endif
    endif
    return fnamemodify(l:path, ':.')
endfunction
