function! <SID>SaveSession(...)
    let l:fname = (a:0 >= 1) ? a:1 : "session.vim"
    let l:fname = fnamemodify(l:fname, ":p")

    let l:sess_dict = {}
    let l:sess_dict.home_dir = getcwd()
    let l:sess_dict.cur_tab = tabpagenr()

    let l:tablist = range(1, tabpagenr("$"))
    for tabnumber in l:tablist
        let l:buflist = tabpagebuflist(tabnumber)
        let l:tab_file_list = []
        for bufid in l:buflist
            if (bufloaded(bufid) && buflisted(bufid))
                let l:expand_str = "#" . bufid . ":p"
                call add(l:tab_file_list, expand(l:expand_str))
            endif
        endfor
        let l:sess_dict[tabnumber] = l:tab_file_list
    endfor

    let l:serialized = string(l:sess_dict)
    call writefile([l:serialized], l:fname)
    echo "session saved in " . l:fname
endfunction


function! s:compare(lhs, rhs)
    return str2nr(a:lhs[0]) - str2nr(a:rhs[0])
endfunctio

function! <SID>LoadSession(...)
    let l:fname = (a:0 >= 1) ? a:1 : "session.vim"
    let l:fname = fnamemodify(l:fname, ":p")

    if (!filereadable(l:fname))
        echoerr "cannot read file " . l:fname
        return
    endif

    let l:serialized = readfile(l:fname)[0]
    execute "let l:sess_dict = " . l:serialized

    let l:home_dir = remove(l:sess_dict, "home_dir")
    execute "cd " . l:home_dir
    execute "CD " . l:home_dir

    let l:cur_tab = remove(l:sess_dict, "cur_tab")

    let l:sess_list = items(l:sess_dict)
    call sort(l:sess_list, "s:compare")

    let l:is_first = 1
    for tab_item in l:sess_list
        if (l:is_first)
            let l:is_first = 0
        else
            tabe
        endif
        let l:tab_buf_list = tab_item[1]
        let l:is_first_buf = 1
        for filename in l:tab_buf_list
            if (l:is_first_buf)
                let l:is_first_buf = 0
                execute "e " . fnamemodify(filename, ":.")
            else
                execute "vs " . fnamemodify(filename, ":.")
            endif
        endfor
    endfor

    execute "normal! " . l:cur_tab . "gt"
endfunction

command -nargs=* -complete=file Ss call <SID>SaveSession(<f-args>)
command -nargs=* -complete=file Ls call <SID>LoadSession(<f-args>)

