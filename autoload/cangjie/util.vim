function! cangjie#util#cmd(option) abort
    if a:option == 'start'
        call cangjie#util#start_lsp()
    elseif a:option == 'stop'
        call cangjie#lsp#stop_server()
    elseif a:option == 'status'
        echo cangjie#lsp#status()
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
        call timer_start(7000, {-> cangjie#util#start_lsp()})
        return
    endif
    " bind shortcut
    inoremap <buffer><silent> . .<Cmd>:call cangjie#lsp#complete()<CR>
    inoremap <buffer><silent> ` `<Cmd>:call cangjie#lsp#complete()<CR>
    nnoremap <buffer><silent> K :call cangjie#lsp#hover()<CR>

    call cangjie#lsp#add_workspace(expand('%:p:h'))
    call cangjie#lsp#did_open()
endfunction


function! cangjie#util#hover() abort
    if !exists('g:cj_diagnostics_by_buf')
        let g:cj_diagnostics_by_buf = {}
    endif
    let s:bufnum = bufnr('%')
    if !has_key(g:cj_diagnostics_by_buf, s:bufnum) || empty(g:cj_diagnostics_by_buf[s:bufnum])
        return ''
    endif

    let s:line_text = getline(v:beval_lnum)

    " 3. 遍历当前缓冲区的所有诊断信息
    let s:found_messages = []
    for s:diag in g:cj_diagnostics_by_buf[s:bufnum]
        let s:start = s:diag.range.start
        let s:end = s:diag.range.end

        " check if the current line is within the diagnostic range
        if (v:beval_lnum - 1) >= s:start.line && (v:beval_lnum - 1) <= s:end.line
            let s:start_char = ((v:beval_lnum - 1) == s:start.line) ? s:start.character : 0
            let s:end_char = ((v:beval_lnum - 1) == s:end.line) ? s:end.character : strchars(s:line_text)

            " 将LSP的 0-based 字符列 转换为 Vim 的 1-based 字节列
            let s:start_byte_col = byteidx(s:line_text, s:start_char) + 1
            " LSP 的 end 是 exclusive (不包含), byteidx 正好需要这个值来获取结束位置
            let s:end_byte_col = byteidx(s:line_text, s:end_char) + 1

            " 如果结束位置超出本行，byteidx 返回 -1，我们将其修正到行尾
            if s:end_byte_col <= 0
                let s:end_byte_col = len(s:line_text) + 2
            endif

            " 判断悬停的字节列是否在诊断的字节范围内 [start, end)
            if v:beval_col >= s:start_byte_col && v:beval_col <= s:end_byte_col
                call add(s:found_messages, s:diag.message)
            endif
        endif
    endfor

    return join(s:found_messages, "\n")
endfunction


function! cangjie#util#popup(text) abort
    if empty(a:text)
        return
    endif
    let s:lines = split(a:text, "\n", 1)
    let s:max_width = max(map(s:lines, 'strwidth(v:val)'))
    let s:lines = split(a:text, "\n", 1)
    let s:opts = {
                \ 'line': 'cursor+1',
                \ 'col': 'cursor',
                \ 'minwidth': s:max_width,
                \ 'padding': [1, 1, 1, 1],
                \ 'border':  [0, 0, 0, 0],
                \ 'zindex': 200,
                \ 'wrap': 0,
                \ 'moved': 'WORD',
                \ 'close': 'click',
                \ }
    let s:popup_id = popup_create(s:lines, s:opts)
    return s:popup_id
endfunction